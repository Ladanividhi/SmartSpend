import 'package:SmartSpend/screens/RecordPage.dart';
import 'package:SmartSpend/screens/Login.dart';
import 'package:SmartSpend/screens/Dashboard.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // return Homepage();
            return Dashboard();
          } else {
            return Login();
          }
        },
      ),
    );
  }
}
