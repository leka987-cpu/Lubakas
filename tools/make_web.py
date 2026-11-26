# Builds the Android web bundle (index.html + local fonts) from the published single-file game.
import re,sys,os
src,dst=sys.argv[1],sys.argv[2]
s=open(src).read()
s=re.sub(r'<link rel="(preconnect|stylesheet)" href="https://fonts\.g[^>]*>\n?','',s)
extra='<style>html{-webkit-text-size-adjust:100%}*{-webkit-tap-highlight-color:transparent}body{margin:0}img{max-width:100%}[hidden]{display:none!important}@media (hover:none){.fb .note{visibility:hidden}}</style>\n'
head='<!doctype html>\n<html lang="et">\n<head>\n<meta charset="utf-8">\n<meta name="viewport" content="width=device-width, initial-scale=1">\n<link rel="stylesheet" href="fonts.css">\n'
# move <title> into head, rest into body
m=re.match(r'(<title>.*?</title>\n)',s)
s=s[m.end():]
out=head+m.group(1)+extra+'</head>\n<body>\n'+s+'\n</body>\n</html>\n'
open(os.path.join(dst,'index.html'),'w').write(out)
