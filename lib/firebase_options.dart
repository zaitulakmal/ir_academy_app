// PLACEHOLDER — akan di-overwrite oleh: flutterfire configure
// Langkah setup:
//   1. Pergi console.firebase.google.com → create project "ir-academy"
//   2. dart pub global activate flutterfire_cli
//   3. flutterfire configure
// File ini akan di-generate semula secara automatik.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  // TODO: Replace with real values from flutterfire configure

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC0N2XkIVwfjFcOdxvrX74FFEp18EPmdyU',
    appId: '1:703871869110:web:69746bd89843db0c044617',
    messagingSenderId: '703871869110',
    projectId: 'ir-academy-53285',
    authDomain: 'ir-academy-53285.firebaseapp.com',
    storageBucket: 'ir-academy-53285.firebasestorage.app',
    measurementId: 'G-SC3EN441KD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD6eCBiSlQuoj0uIegOMGNnFcacr_v-T9E',
    appId: '1:703871869110:android:b5aaacb2227d6400044617',
    messagingSenderId: '703871869110',
    projectId: 'ir-academy-53285',
    storageBucket: 'ir-academy-53285.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_REAL_VALUE',
    appId: 'REPLACE_WITH_REAL_VALUE',
    messagingSenderId: 'REPLACE_WITH_REAL_VALUE',
    projectId: 'REPLACE_WITH_REAL_VALUE',
    storageBucket: 'REPLACE_WITH_REAL_VALUE',
    iosBundleId: 'com.example.irAcademyApp',
  );
}
