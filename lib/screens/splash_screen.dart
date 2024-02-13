import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/providers/splash_provider.dart';
import 'package:bloc_firebase/screens/profile_screen.dart';
import 'package:bloc_firebase/screens/registration_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    SplashProvider().checkSession(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Splash',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
