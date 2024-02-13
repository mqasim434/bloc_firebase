import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/screens/profile_screen.dart';
import 'package:bloc_firebase/screens/registration_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashProvider extends ChangeNotifier{
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  SplashProvider(){
    if(RegistrationProvider().currentUser!=null){
      _isLoggedIn = true;
    }
    notifyListeners();
  }

  void checkSession(BuildContext context){
    if(_isLoggedIn){
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ProfileScreen(userModel: UserModel(name: 'Qasim',email: 'mq30003'),)));
      });
    }else{
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const RegistrationScreen()));
      });
    }
  }
}