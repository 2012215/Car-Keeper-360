import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'Login.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Signup> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  String errorText = '';
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Car Keeper 360 Signup"),
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
                controller: userNameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  hintText: 'User Name',
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
                controller: userEmailController,
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
                controller: userPasswordController,
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
                    )),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: () async {
                var userName = userNameController.text.trim();
                var userEmail = userEmailController.text.trim();
                var userPassword = userPasswordController.text.trim();
                if (userName.isEmpty || userEmail.isEmpty || userPassword.isEmpty) {
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

                setState(() {
                  errorText = '';
                });

                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: userEmail, password: userPassword);
                  log("User Created");
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                } catch (e) {
                  setState(() {
                    errorText = 'Email already in use. Please use a different email.';
                  });
                }
              },
              child: Text("Signup"),
            ),
            if (errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  errorText,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(
              height: 15,
            ),
            GestureDetector(
              onTap: () {
                Get.to(() => Login());
              },
              child: Container(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text("Already have an account. Log in"),
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
