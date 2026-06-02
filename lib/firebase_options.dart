import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration for the Streaky app.
/// Generated manually from google-services.json values.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS - '
          'you can add them when you\'re ready to support iOS.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDij0oSk3TR0ewgcDc1nm_aKV8l-pHu-2I',
    appId: '1:180462655259:android:e93c6b91dffd8a4e0ce5be',
    messagingSenderId: '180462655259',
    projectId: 'streaky-9b1ae',
    storageBucket: 'streaky-9b1ae.firebasestorage.app',
  );

  /// Web Firebase options — uses the same project with a web app ID.
  /// The apiKey and projectId are the same across platforms.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDij0oSk3TR0ewgcDc1nm_aKV8l-pHu-2I',
    appId: '1:180462655259:web:streaky_web_app',
    messagingSenderId: '180462655259',
    projectId: 'streaky-9b1ae',
    storageBucket: 'streaky-9b1ae.firebasestorage.app',
    authDomain: 'streaky-9b1ae.firebaseapp.com',
  );
}
