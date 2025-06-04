import 'package:SmartSpend/Constants.dart';
import 'package:SmartSpend/screens/Dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  login() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return; // User cancelled

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Reference to Firestore
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Check if the email already exists
        QuerySnapshot existingUser = await firestore
            .collection('Users')
            .where('Email', isEqualTo: user.email)
            .get();

        if (existingUser.docs.isEmpty) {
          // If user doesn't exist, add them
          await firestore.collection('Users').doc(user.uid).set({
            'Name': user.displayName,
            'Email': user.email,
            'Gender': null,
            'Mobile': null,
            'Address': null,
            'Pincode': null,
          });
          print('New user added to Firestore');
        } else {
          print('User already exists in Firestore');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
          );
        }
      }
    } catch (e) {
      print('Login error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage('assets/images/logo.jpg'),
                backgroundColor: Colors.white,
                // backgroundColor: const Color(0xFFF5F6FA),
              ),
              const SizedBox(height: 10),
              // App Name
              const Text(
                'SmartSpend',
                style: TextStyle(
                  fontSize: 33,
                  fontWeight: FontWeight.bold,
                  color: primary_color,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 1),
              // Subtitle
              const Text(
                'Your Personal Finance Buddy',
                style: TextStyle(
                  fontSize: 16,
                  color: text_color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              // Card with Google Sign-In Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                child: Column(
                  children: [
                    // Custom Google Sign-In Button
                    GestureDetector(
                      onTap: login,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/google.png',
                              height: 24,
                              width: 24,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
