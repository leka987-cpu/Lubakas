# Lubakas

Eesti liikluseeskirja õppemäng B-kategooria teooriaeksamiks, eesti ja vene keeles. Üks HTML-fail, mis töötab brauseris ja iPhone'is.

| Kaust / fail | Sisu |
| --- | --- |
| `lubakas.html` | Mängu lähtefail (sama, mis avaldatud veebiversioon) |
| `web/` | Rakenduse jaoks ehitatud mäng (`index.html` + kohalikud fondid) |
| `tools/make_web.py` | Teeb `lubakas.html`-ist `web/index.html`-i |
| `ios/` | iPhone'i rakendus (App Store), ehitatakse GitHub Actionsis |

Mängu muutmisel: muuda `lubakas.html`, siis käivita `python3 tools/make_web.py lubakas.html web`.

iPhone'i rakendus saadab igapäevase meeldetuletuse kell 18, kui päevaseeria hakkab katkema, ja jagab eksami tulemust telefoni jagamismenüüga.

iPhone'i versiooni ehitab iga muudatuse peale GitHub Actions (vahekaart **Actions**, töövoog **iOS**). TestFlighti saatmiseks käivita töövoog käsitsi ja märgi "Saada TestFlighti". Selleks on vaja hoidla saladusi (Settings → Secrets and variables → Actions): `APPLE_TEAM_ID`, `ASC_KEY_ID`, `ASC_ISSUER_ID`, `ASC_KEY_P8` (kogu .p8-faili sisu). Need on samad, mis Nupuka hoidlas.

App Store Connectis tuleb enne esimest üleslaadimist luua uus rakendus paketi-ID-ga `ee.mangud.lubakas`.
