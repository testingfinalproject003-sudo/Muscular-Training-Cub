import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC-JfvFTn_Kl5Uh5uSCaN-F6lbsIC1gluI',
    appId: '1:464237838239:web:cf87cf6dd5993bb987c7aa',
    messagingSenderId: '464237838239',
    projectId: 'muscular-training-club',
    authDomain: 'muscular-training-club.firebaseapp.com',
    storageBucket: 'muscular-training-club.firebasestorage.app',
    measurementId: 'G-CE5V4SC9Q0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCy5o1Zsaa7vAcUmKYUCnE4oRaHVLsFv3o',
    appId: '1:464237838239:android:500b0143b4aa514f87c7aa',
    messagingSenderId: '464237838239',
    projectId: 'muscular-training-club',
    storageBucket: 'muscular-training-club.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDoE_PgLiHuQwY3iYJRmIiJSuyFJ3Nm0xQ',
    appId: '1:464237838239:ios:c868f146cd6117d787c7aa',
    messagingSenderId: '464237838239',
    projectId: 'muscular-training-club',
    storageBucket: 'muscular-training-club.firebasestorage.app',
    iosBundleId: 'com.example.muscularTrainingClub',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'YOUR_BUNDLE_ID',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC-JfvFTn_Kl5Uh5uSCaN-F6lbsIC1gluI',
    appId: '1:464237838239:web:d0790158cda7346287c7aa',
    messagingSenderId: '464237838239',
    projectId: 'muscular-training-club',
    authDomain: 'muscular-training-club.firebaseapp.com',
    storageBucket: 'muscular-training-club.firebasestorage.app',
    measurementId: 'G-CGYD51K58C',
  );

}