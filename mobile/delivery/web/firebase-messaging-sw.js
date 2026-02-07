importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyCrhkxUPnykyttiQuUJ1vgP2c4nOe4k3L8",
  authDomain: "drpharma-f9213.firebaseapp.com",
  projectId: "drpharma-f9213",
  storageBucket: "drpharma-f9213.firebasestorage.app",
  messagingSenderId: "866711466162",
  appId: "1:866711466162:web:7b061a37e651dea8e859ab",
  measurementId: "G-5DRRS3L1TB"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});