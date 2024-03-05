import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:otp_text_field/otp_text_field.dart';

class OTPProvider extends ChangeNotifier {
  OtpFieldController otpController = OtpFieldController();
  int count = 15;

  OTPProvider() {
    Timer.periodic(Duration(seconds: 15), (timer) {
      count -= timer.tick;
      print(count);
    });
  }

  Future<UserCredential> verifyOtp(String verificationId) async {
    PhoneAuthCredential credential = await PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpController.toString(),
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }


  Future<bool> validateEmail(String email)async{

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

    var querySnapshot = await firebaseFirestore.collection('users').get();

    bool emailFound = false;

    for(QueryDocumentSnapshot<Map<String,dynamic>> document in querySnapshot.docs){
      if(document.data()['email']==email){
        emailFound = true;
      }
    }
    return emailFound;
  }


  Future<void> resetPasswordByEmail(String userEmail,BuildContext context) async {
    Random random = Random();
    final otpCode = random.nextInt(1000);

    FirebaseAuth firebaseAuth = FirebaseAuth.instance;

    firebaseAuth.sendPasswordResetEmail(email: userEmail);

  }

  bool isPhoneChecked = false;
  bool isEmailChecked = true;

  switchEmailPhone() {
    if (isPhoneChecked) {
      isPhoneChecked = false;
      isEmailChecked = true;
    } else {
      isPhoneChecked = true;
      isEmailChecked = false;
    }
    notifyListeners();
  }


}
