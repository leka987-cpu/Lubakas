# Builds the web/PWA bundle (index.html + local fonts) from the published single-file game.
import re,sys,os
src,dst=sys.argv[1],sys.argv[2]
s=open(src).read()
s=re.sub(r'<link rel="(preconnect|stylesheet)" href="https://fonts\.g[^>]*>\n?','',s)
extra='<style>html{-webkit-text-size-adjust:100%}*{-webkit-tap-highlight-color:transparent}body{margin:0}img{max-width:100%}[hidden]{display:none!important}@media (hover:none){.fb .note{visibility:hidden}}</style>\n'
head='<!doctype html>\n<html lang="et">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1">\n<link rel="stylesheet" href="fonts.css">\n<link rel="manifest" href="manifest.webmanifest">\n<meta name="theme-color" content="#E39B12">\n<meta name="description" content="Lubakas: Eesti liikluseeskirja õppemäng ja eksamisimulatsioon.">\n<link rel="icon" href="icons/icon-192.png">\n<link rel="apple-touch-icon" href="icons/apple-touch-icon.png">\n<meta name="apple-mobile-web-app-capable" content="yes">\n<meta name="apple-mobile-web-app-title" content="Lubakas">\n'
# move <title> into head, rest into body
m=re.match(r'(<title>.*?</title>\n)',s)
s=s[m.end():]
sw='<script>if("serviceWorker" in navigator&&isSecureContext&&location.protocol!=="file:")addEventListener("load",()=>navigator.serviceWorker.register("sw.js"))</script>\n'
out=head+m.group(1)+extra+'</head>\n<body>\n'+s+'\n'+sw+'</body>\n</html>\n'
open(os.path.join(dst,'index.html'),'w').write(out)
