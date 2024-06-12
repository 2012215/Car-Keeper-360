import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fyp/signup.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'forgotpassword.dart';
import 'home.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String errorText = '';
  bool obscureText = true;
  bool isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Car Keeper 360"),
        toolbarHeight: 40,
      ),*/
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
                controller: emailController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  hintText: 'Email',
                  enabledBorder: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30.0),
              child: TextFormField(
                controller: passwordController,
                obscureText: obscureText,
                decoration: InputDecoration(
                  hintText: 'Password',
                  enabledBorder: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.password),
                  suffixIcon: GestureDetector(
                    onTap: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                    child: Icon(
                      obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () async {
                var userEmail = emailController.text.trim();
                var userPassword = passwordController.text.trim();

                if (userEmail.isEmpty || userPassword.isEmpty) {
                  setState(() {
                    errorText = 'Please fill all the fields.';
                  });
                  return;
                }
                if (!userEmail.contains('@')) {
                  setState(() {
                    errorText = 'Invalid email format.';
                  });
                  return;
                }

                RegExp passwordRegExp =
                RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9!@#\$&*~]).{8,}$');
                if (!passwordRegExp.hasMatch(userPassword)) {
                  setState(() {
                    errorText =
                    'Password must be 8 characters long and include uppercase, lowercase, and at least one digit or special character.';
                  });
                  return;
                }

                try {
                  // Sign in with Firebase
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: userEmail,
                    password: userPassword,
                  );

                  // Successfully signed in
                  setState(() {
                    isLoggedIn = true;
                    errorText = ''; // Clear any previous error
                  });

                  // Navigate to home screen
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                  );

                  // Display success message
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Success"),
                        content: Text("Account logged in successfully"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                } catch (e) {
                  // Handle sign-in errors
                  print('Error: $e');
                  setState(() {
                    isLoggedIn = true;
                    errorText = 'Invalid email or password.';
                  });

                  // Display failure message
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Error"),
                        content: Text("Login failed"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text("Login"),
            ),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => Forgot());
              },
              child: Container(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text("Forgot Password"),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => Signup());
              },
              child: Container(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text("Don't Have an Account. Signup"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
