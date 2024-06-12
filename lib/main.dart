import 'package:firebase_core/firebase_core.dart';
import 'firebase_setup.dart'; // Import your Firebase setup file
import 'package:flutter/material.dart';
import 'package:fyp/home.dart';
import 'package:get/get.dart';
import 'Login.dart';



import 'Login.dart';

void main()async {

  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseSetup.initialize();

  runApp(const MainApp());
}

  class MainApp extends StatelessWidget {
    const MainApp({super.key});

    @override
    Widget build(BuildContext context) {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const Login(),
      );
    }
}
