importScripts('https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyC0N2XkIVwfjFcOdxvrX74FFEp18EPmdyU',
  authDomain: 'ir-academy-53285.firebaseapp.com',
  projectId: 'ir-academy-53285',
  storageBucket: 'ir-academy-53285.firebasestorage.app',
  messagingSenderId: '703871869110',
  appId: '1:703871869110:web:69746bd89843db0c044617',
  measurementId: 'G-SC3EN441KD',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  self.registration.showNotification(payload.notification.title, {
    body: payload.notification.body,
    icon: '/ir_academy_app/icons/Icon-192.png',
  });
});
