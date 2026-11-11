const V="bio61-v7";const CORE=["./","index.html","cke/data.js","manifest.webmanifest","icon-192.png","icon-512.png"];
self.addEventListener("install",e=>{e.waitUntil(caches.open(V).then(c=>c.addAll(CORE)).then(()=>self.skipWaiting()))});
self.addEventListener("activate",e=>{e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==V).map(k=>caches.delete(k)))).then(()=>self.clients.claim()))});
/* strona i dane: najpierw sieć (świeża wersja po pushu), offline z cache; obrazki: najpierw cache */
self.addEventListener("fetch",e=>{const r=e.request;if(r.method!=="GET")return;
 const nav=r.mode==="navigate",u=new URL(r.url),fresh=nav||u.pathname.endsWith(".js")||u.pathname.endsWith(".html");
 e.respondWith(caches.open(V).then(async c=>{const hit=await c.match(nav?"index.html":r,{ignoreSearch:nav});
  const net=fetch(r).then(res=>{if(res&&(res.ok||res.type==="opaque"))c.put(nav?"index.html":r,res.clone());return res});
  if(fresh)return net.catch(()=>hit);
  return hit||net}))});
