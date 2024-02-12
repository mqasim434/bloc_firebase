import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/providers/otp_provider.dart';
import 'package:bloc_firebase/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';

class OTPScreen extends StatelessWidget {
  const OTPScreen({super.key,required this.verificationId});

  final String verificationId;

  @override
  Widget build(BuildContext context) {

    final otpProvider = Provider.of<OTPProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('OTP Screen'),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Enter OTP Code',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: OTPTextField(
                controller: otpProvider.otpController,
                fieldWidth: 45,
                spaceBetween: 5,
                fieldStyle: FieldStyle.box,
                width: MediaQuery.of(context).size.width,
                length: 6,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {

                    },
                    child: const Text(
                      'Resend OTP',
                    ),
                  ),
                  const Text(
                    ' (15)',
                  ),
                ],
              ),
            ),
            ElevatedButton(onPressed: () {
              otpProvider.verifyOtp(verificationId).then((value){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return ProfileScreen(userModel: UserModel(
                  name: value!.user!.displayName,
                    email: value!.user!.email,
                    phone: value!.user!.phoneNumber,
                    imageUrl: value!.user!.photoURL,
                  ),);
                }));
              });
            }, child: const Text('Verify')),
          ],
        ),
      ),
    );
  }
}
