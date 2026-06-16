import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web not configured yet');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS not configured');
      default:
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVMwpUx3rUqyJOVvgzff16tGO1t74TAuQ',
    appId: '1:1031478365934:android:9833b0571ee9f84f006dff',
    messagingSenderId: '1031478365934',
    projectId: 'primefleet-d789f',
    storageBucket: 'primefleet-d789f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAVMwpUx3rUqyJOVvgzff16tGO1t74TAuQ',
    appId: '1:1031478365934:ios:9e34e7e05611249a006dff',
    messagingSenderId: '1031478365934',
    projectId: 'primefleet-d789f',
    storageBucket: 'primefleet-d789f.firebasestorage.app',
    iosBundleId: 'com.primefleet.primefleet',
  );
}