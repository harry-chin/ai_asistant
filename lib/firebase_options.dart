// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyC-EUHMsXoKNXcOktYDquWIAPNTde6J_x0',
    appId: '1:296629836637:web:ab5ed0edbd66a32357e6b4',
    messagingSenderId: '296629836637',
    projectId: 'jins-ai-assistant',
    authDomain: 'jins-ai-assistant.firebaseapp.com',
    storageBucket: 'jins-ai-assistant.appspot.com',
    measurementId: 'G-1W7MP6CEKG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCr6vf4QHEREkNBfH8k-W4zupXOBa-iuhM',
    appId: '1:296629836637:android:01c1deeae6db9eb157e6b4',
    messagingSenderId: '296629836637',
    projectId: 'jins-ai-assistant',
    storageBucket: 'jins-ai-assistant.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC93y02LUr3mjsEEEHT_DBZ5Lvs3Uilhr8',
    appId: '1:296629836637:ios:85a285b96ab9d09257e6b4',
    messagingSenderId: '296629836637',
    projectId: 'jins-ai-assistant',
    storageBucket: 'jins-ai-assistant.appspot.com',
    iosBundleId: 'com.example.aiAssistant',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC93y02LUr3mjsEEEHT_DBZ5Lvs3Uilhr8',
    appId: '1:296629836637:ios:85a285b96ab9d09257e6b4',
    messagingSenderId: '296629836637',
    projectId: 'jins-ai-assistant',
    storageBucket: 'jins-ai-assistant.appspot.com',
    iosBundleId: 'com.example.aiAssistant',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC-EUHMsXoKNXcOktYDquWIAPNTde6J_x0',
    appId: '1:296629836637:web:57eb56e80daa37ec57e6b4',
    messagingSenderId: '296629836637',
    projectId: 'jins-ai-assistant',
    authDomain: 'jins-ai-assistant.firebaseapp.com',
    storageBucket: 'jins-ai-assistant.appspot.com',
    measurementId: 'G-0XKZL7XMR7',
  );
}
