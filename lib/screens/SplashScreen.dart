import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  bool isLogin = false;

  @override
  void initState() {
    super.initState();

    // setupDeviceData();

    // Timer for navigation after 3 seconds
    Timer(Duration(seconds: 3), () {
      // openPage();
    });
  }

  // void openPage(){
  //   if(isLogin) {
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => Dashboard()),
  //             (route) => false
  //     );
  //   }
  //   else {
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => Login()),
  //             (route) => false
  //     );
  //   }
  // }

  // Future<void> setupDeviceData() async {
  //   await LocalData.getUserData().then((value) {
  //     if (LocalData.userId == "") {
  //       isLogin = false;
  //     } else {
  //       isLogin = true;
  //     }
  //
  //   });
  //   await LocalData.setDeviceData();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // You can change it
      body: Center(
          child:
          Positioned.fill(
              child: Image.asset(
                'assets/images/logo.jpg',
                fit: BoxFit.cover,
              ))
      ),
    );
  }
}
