import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/screens/chat_screen.dart';
import 'package:bloc_firebase/screens/inbox_screen.dart';import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton(
      {super.key, required this.icon, required this.onPress});

  final String icon;
  final Future<UserModel?> Function() onPress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Future<UserModel?> Function() value = onPress;
        value.call().then((value) => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Inbox(),
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
