// Lubakas offline support: try the network first so updates arrive at once, fall back to the cached copy offline.
const CACHE="lubakas-v1";
const FILES=["./","index.html","fonts.css","manifest.webmanifest","icons/icon-192.png","icons/icon-512.png","privacy.html",
  "fonts/f0.woff2","fonts/f1.woff2","fonts/f2.woff2","fonts/f3.woff2","fonts/f4.woff2","fonts/f5.woff2","fonts/f6.woff2","fonts/f7.woff2"];
self.addEventListener("install",e=>{e.waitUntil(caches.open(CACHE).then(c=>c.addAll(FILES)).then(()=>self.skipWaiting()))});
self.addEventListener("activate",e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==CACHE).map(k=>caches.delete(k)))).then(()=>self.clients.claim()))});
self.addEventListener("fetch",e=>{
  if(e.request.method!=="GET"||new URL(e.request.url).origin!==location.origin) return;
  e.respondWith(fetch(e.request).then(r=>{ if(r.ok){const c=r.clone(); caches.open(CACHE).then(x=>x.put(e.request,c))} return r })
    .catch(()=>caches.match(e.request,{ignoreSearch:true}).then(r=>r||caches.match("index.html"))));
});
