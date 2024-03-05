import 'package:bloc_firebase/screens/dashboard.dart';
import 'package:bloc_firebase/screens/signin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashProvider extends ChangeNotifier{
  bool _isLoggedIn = false;

  FirebaseAuth auth = FirebaseAuth.instance;

  SplashProvider(){
    if(auth.currentUser!=null){
      _isLoggedIn = true;
    }
    notifyListeners();
  }

  void checkSession(BuildContext context){
    if(_isLoggedIn){
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Dashboard()));
      });
    }else{Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignInScreen()));
    });
    }
  }
}