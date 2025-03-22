// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCBkZoAGe9WuaiUfGlQY2xDRihrMQw5xRw',
    appId: '1:912118387533:web:39db528e60c81fc3329d04',
    messagingSenderId: '912118387533',
    projectId: 'pregnancy-app-back-b96d4',
    authDomain: 'pregnancy-app-back-b96d4.firebaseapp.com',
    storageBucket: 'pregnancy-app-back-b96d4.appspot.com', // 🔴 FIXED storage bucket typo
    measurementId: 'G-1KNE9T15B7',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDRToCMCsNIoajvjWcNB-GIlFC4SrG70vU',
    appId: '1:912118387533:android:7ee17aeca7c06f50329d04',
    messagingSenderId: '912118387533',
    projectId: 'pregnancy-app-back-b96d4',
    storageBucket: 'pregnancy-app-back-b96d4.appspot.com', // 🔴 FIXED storage bucket typo
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC2yej4zmX9xi9oeToghRn7I6rZgXS8xTA',
    appId: '1:912118387533:ios:6f91084df1562dcb329d04',
    messagingSenderId: '912118387533',
    projectId: 'pregnancy-app-back-b96d4',
    storageBucket: 'pregnancy-app-back-b96d4.appspot.com', // 🔴 FIXED storage bucket typo
    iosBundleId: 'com.example.preg',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC2yej4zmX9xi9oeToghRn7I6rZgXS8xTA',
    appId: '1:912118387533:ios:6f91084df1562dcb329d04',
    messagingSenderId: '912118387533',
    projectId: 'pregnancy-app-back-b96d4',
    storageBucket: 'pregnancy-app-back-b96d4.appspot.com', // 🔴 FIXED storage bucket typo
    iosBundleId: 'com.example.preg',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCBkZoAGe9WuaiUfGlQY2xDRihrMQw5xRw',
    appId: '1:912118387533:web:ca4ad6217b682880329d04',
    messagingSenderId: '912118387533',
    projectId: 'pregnancy-app-back-b96d4',
    authDomain: 'pregnancy-app-back-b96d4.firebaseapp.com',
    storageBucket: 'pregnancy-app-back-b96d4.appspot.com', // 🔴 FIXED storage bucket typo
    measurementId: 'G-DR6NZ2C498',
  );
}
