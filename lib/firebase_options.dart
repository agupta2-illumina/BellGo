import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'YOUR_WEB_API_KEY',
    appId: '1:YOUR_APP_ID:web:YOUR_WEB_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'bellgo-dev',
    authDomain: 'bellgo-dev.firebaseapp.com',
    storageBucket: 'bellgo-dev.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: '1:YOUR_APP_ID:android:YOUR_ANDROID_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'bellgo-dev',
    storageBucket: 'bellgo-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: '1:YOUR_APP_ID:ios:YOUR_IOS_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'bellgo-dev',
    iosBundleId: 'com.bellgo.app',
    storageBucket: 'bellgo-dev.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: '1:YOUR_APP_ID:macos:YOUR_MACOS_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'bellgo-dev',
    iosBundleId: 'com.bellgo.app',
    storageBucket: 'bellgo-dev.appspot.com',
  );
}
