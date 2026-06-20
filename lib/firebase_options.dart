import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

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
    // We are returning the same options across platforms for testing purposes.
    // In a production app, you would use flutterfire configure to generate
    // platform-specific options.
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBFVkJ1TIH3dB9kOctY8Y1fMdj_vOyVz-c',
    appId: '1:237591936635:web:e9de2c6c7c904843d72cde',
    messagingSenderId: '237591936635',
    projectId: 'trippies-1c3e8',
    authDomain: 'trippies-1c3e8.firebaseapp.com',
    storageBucket: 'trippies-1c3e8.firebasestorage.app',
    measurementId: 'G-8NGBBF6J8E',
  );
}
