import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/screens/chat_screen.dart';
import 'package:bloc_firebase/screens/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton(
      {super.key, required this.icon, required this.onPress});

  final String icon;
  final Future<User?> Function() onPress;

  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    return InkWell(
      onTap: () {
        Future<User?> Function() value = onPress;
        value.call().then((value) => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    userModel: UserModel(
                      name: value!.displayName,
                      email: value!.email,
                      imageUrl: value.photoURL,
                    ),
                  ),
                ),
              ),
            });
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Image.asset(icon, width: 25),
        ),
      ),
    );
  }
}
