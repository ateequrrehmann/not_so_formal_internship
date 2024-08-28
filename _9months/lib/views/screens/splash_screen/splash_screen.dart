import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import '../main_screens/bottom_navigation_bar/bottom_nav_bar.dart';
import '../registration_login/register_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var isLogin = false;
  var auth = FirebaseAuth.instance;
  String? phone;


  Future<void> checkIfLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    phone = prefs.getString('user_phone');
    print('splash screen $phone');

    auth.authStateChanges().listen((User? user) {
      print(user);
      if (user != null && mounted) {
        setState(() {
          isLogin = true;
        });
        print(isLogin);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkIfLogin().then((_) {
      Timer(Duration(seconds: 3), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => isLogin && phone != null
                ? CustomBottomNavigationBar()
                : RegisterScreen(),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFCDD2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              child: Image.asset('lib/assets/splashscreen.png'),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '9months',
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.w400),
                ),
                // Text(
                //   'Connect',
                //   style: TextStyle(
                //       fontSize: 30,
                //       color: Color(0xFFEC407A),
                //       fontWeight: FontWeight.w400),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
