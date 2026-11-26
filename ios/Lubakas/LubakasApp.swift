import SwiftUI
import WebKit
import UserNotifications

/// Shows the bundled HTML game (web/index.html). Works offline.
/// The page talks to the app through `window.webkit.messageHandlers.lubakas`:
///   {reminder:true, lang:"et"|"ru", streak:Int, today:Bool}  -> schedules the daily streak reminder
///   {share:"text"}                                           -> opens the system share sheet
@main
struct LubakasApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .background(Color("Paper", bundle: nil).ignoresSafeArea())
        }
    }
}

struct GameView: UIViewRepresentable {
    func makeCoordinator() -> Bridge { Bridge() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.userContentController.add(context.coordinator, name: "lubakas")
        let web = WKWebView(frame: .zero, configuration: config)
        web.isOpaque = false
        web.backgroundColor = .clear
        web.scrollView.backgroundColor = .clear
        web.scrollView.bounces = false
        context.coordinator.web = web
        if let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "web") {
            web.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
        }
        return web
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

final class Bridge: NSObject, WKScriptMessageHandler {
    weak var web: WKWebView?
    private let reminderID = "lubakas.streak"
    private let hour = 18

    func userContentController(_ ucc: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else { return }
        if let text = body["share"] as? String { share(text) }
        if body["reminder"] as? Bool == true {
            let lang = body["lang"] as? String ?? "et"
            let streak = body["streak"] as? Int ?? 0
            let today = body["today"] as? Bool ?? false
            scheduleReminder(lang: lang, streak: streak, practicedToday: today)
        }
    }

    private func share(_ text: String) {
        guard let web = web, let root = web.window?.rootViewController else { return }
        let sheet = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        sheet.popoverPresentationController?.sourceView = web
        sheet.popoverPresentationController?.sourceRect = CGRect(x: web.bounds.midX, y: web.bounds.maxY - 40, width: 1, height: 1)
        root.present(sheet, animated: true)
    }

    /// One pending reminder at a time: today at 18:00 if not practised yet, otherwise tomorrow at 18:00.
    private func scheduleReminder(lang: String, streak: Int, practicedToday: Bool) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            center.removePendingNotificationRequests(withIdentifiers: [self.reminderID])
            let cal = Calendar.current
            var day = Date()
            let todayAt = cal.date(bySettingHour: self.hour, minute: 0, second: 0, of: day) ?? day
            if practicedToday || Date() >= todayAt { day = cal.date(byAdding: .day, value: 1, to: day) ?? day }
            var when = cal.dateComponents([.year, .month, .day], from: day)
            when.hour = self.hour
            let nextStreak = practicedToday ? streak : max(streak, 0)
            let content = UNMutableNotificationContent()
            content.title = "Lubakas"
            content.body = Bridge.text(lang: lang, streak: nextStreak)
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(dateMatching: when, repeats: false)
            center.add(UNNotificationRequest(identifier: self.reminderID, content: content, trigger: trigger))
        }
    }

    static func text(lang: String, streak: Int) -> String {
        if lang == "ru" {
            return streak > 0 ? "Твоя серия: \(streak) дн. Пара вопросов, и она не прервётся!" : "Пара вопросов в день, и права уже близко!"
        }
        return streak > 0 ? "Sinu seeria on \(streak) päeva. Paar küsimust ja see ei katke!" : "Paar küsimust päevas ja load on varsti käes!"
    }
}
