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
        return android;
      case TargetPlatform.linux:
        return android;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBlQ7Xg4MZPFWKONrPJE_piXg2B6VHiWHk',
    appId: '1:325007849691:android:1e80296e19d308fc5234fe',
    messagingSenderId: '325007849691',
    projectId: 'dream11local',
    databaseURL: 'https://dream11local-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'dream11local.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBlQ7Xg4MZPFWKONrPJE_piXg2B6VHiWHk',
    appId: '1:325007849691:android:1e80296e19d308fc5234fe',
    messagingSenderId: '325007849691',
    projectId: 'dream11local',
    databaseURL: 'https://dream11local-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'dream11local.firebasestorage.app',
    iosBundleId: 'com.dream11.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBlQ7Xg4MZPFWKONrPJE_piXg2B6VHiWHk',
    appId: '1:325007849691:android:1e80296e19d308fc5234fe',
    messagingSenderId: '325007849691',
    projectId: 'dream11local',
    databaseURL: 'https://dream11local-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'dream11local.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBlQ7Xg4MZPFWKONrPJE_piXg2B6VHiWHk',
    appId: '1:325007849691:android:1e80296e19d308fc5234fe',
    messagingSenderId: '325007849691',
    projectId: 'dream11local',
    databaseURL: 'https://dream11local-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'dream11local.firebasestorage.app',
    iosBundleId: 'com.dream11.com',
  );
}
