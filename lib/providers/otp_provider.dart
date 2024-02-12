import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
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
}
