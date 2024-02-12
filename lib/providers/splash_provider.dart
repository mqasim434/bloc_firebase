import 'package:bloc_firebase/providers/registration_provider.dart';
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
}