const V="bio61-v13",OFF="bio61-off";const CORE=["./","index.html","cke/data.js","manifest.webmanifest","icon-192.png","icon-512.png","https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.45.4/dist/umd/supabase.js"];
self.addEventListener("install",e=>{e.waitUntil(caches.open(V).then(c=>c.addAll(CORE)).then(()=>self.skipWaiting()))});
self.addEventListener("activate",e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==V&&k!==OFF).map(k=>caches.delete(k)))).then(()=>self.clients.claim()))});
/* strona i dane: najpierw sieć (świeża wersja po pushu), offline z cache; obrazki: najpierw cache (też pobrane działy z bio61-off) */
self.addEventListener("fetch",e=>{const r=e.request;if(r.method!=="GET")return;
 const u=new URL(r.url);if(u.hostname.endsWith("supabase.co"))return;/* dane z konta nie trafiają do cache */
 const nav=r.mode==="navigate",fresh=nav||u.pathname.endsWith(".js")||u.pathname.endsWith(".html");
 e.respondWith(caches.open(V).then(async c=>{const hit=nav?await c.match("index.html",{ignoreSearch:true}):await caches.match(r);
  const net=fetch(r).then(res=>{if(res&&(res.ok||res.type==="opaque"))c.put(nav?"index.html":r,res.clone());return res});
  if(fresh)return net.catch(()=>hit);
  return hit||net}))});
