// The Smit Household: shows phone notifications sent by the household's notify service.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', e => e.waitUntil(self.clients.claim()));

self.addEventListener('push', e => {
  let d = {};
  try { d = e.data ? e.data.json() : {}; } catch (err) { d = { body: e.data ? e.data.text() : '' }; }
  const tab = d.tab || 'home';
  e.waitUntil(self.registration.showNotification(d.title || 'The Smit Household', {
    body: d.body || 'Something changed',
    icon: 'icon-192.png',
    badge: 'badge-96.png',
    tag: 'smit-' + tab,
    renotify: true,
    data: { tab }
  }));
});

self.addEventListener('notificationclick', e => {
  e.notification.close();
  const tab = (e.notification.data && e.notification.data.tab) || 'home';
  const url = new URL('./#' + tab, self.registration.scope).href;
  e.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(list => {
    for (const c of list) {
      if ('focus' in c) { c.postMessage({ tab }); return c.focus(); }
    }
    return self.clients.openWindow(url);
  }));
});
