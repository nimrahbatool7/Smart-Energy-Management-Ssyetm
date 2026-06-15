// File: lib/firebase_options.dart
// Generated placeholder to allow compilation. Run 'flutterfire configure' to overwrite with real project credentials.
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'dummy-web-api-key',
    appId: 'dummy-web-app-id',
    messagingSenderId: 'dummy-web-sender-id',
    projectId: 'dummy-project-id',
    authDomain: 'dummy-project.firebaseapp.com',
    storageBucket: 'dummy-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'dummy-android-api-key',
    appId: 'dummy-android-app-id',
    messagingSenderId: 'dummy-android-sender-id',
    projectId: 'dummy-project-id',
    storageBucket: 'dummy-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'dummy-ios-api-key',
    appId: 'dummy-ios-app-id',
    messagingSenderId: 'dummy-ios-sender-id',
    projectId: 'dummy-project-id',
    storageBucket: 'dummy-project.appspot.com',
    iosClientId: 'dummy-ios-client-id',
    iosBundleId: 'dummy-ios-bundle-id',
  );
}
