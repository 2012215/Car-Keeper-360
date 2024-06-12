import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Login.dart';

class Forgot extends StatefulWidget {
  const Forgot({super.key});

  @override
  State<Forgot> createState() => _ForgotState();
}

class _ForgotState extends State<Forgot> {
  TextEditingController forgetPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Forgot Password"),
        toolbarHeight: 40,
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage('OIG4.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 30.0),
              child: TextFormField(
                controller: forgetPasswordController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  //suffixIcon: Icon(Icons.email),
                  hintText: 'Email',
                  enabledBorder: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () async {
                var forgotEmail = forgetPasswordController.text.trim();
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: forgotEmail);
                  print("Email Sent");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                } on FirebaseAuthException catch (e) {
                  print("Error $e");
                }
              },
              child: Text("Forgot Password"),
            ),
            SizedBox(
              height: 15,
            ),
          ],
        ),
      ),
    );
  }
}