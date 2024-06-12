import 'package:firebase_core/firebase_core.dart';

class FirebaseSetup {
  static Future<void> initialize() async {
    // Replace these values with your Firebase configuration
    var firebaseOptions = FirebaseOptions(
      apiKey: 'AIzaSyC3OEoy-nGyj5h8rZ5GT5tANQ3eMWpggOE',
      authDomain: 'your-auth-domain',
      projectId: 'your-project-id',
      storageBucket: 'your-storage-bucket',
      messagingSenderId: 'your-messaging-sender-id',
      appId: 'your-app-id',
    );

    await Firebase.initializeApp(options: firebaseOptions);
    print('Firebase initialized');
  }
}