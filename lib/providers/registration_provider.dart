import 'dart:io';
import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_login/entity/auth_result.dart';
import 'package:twitter_login/twitter_login.dart';

class RegistrationProvider extends ChangeNotifier {
  bool isLoading = false;
  User? currentUser;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  Future<User?> signupWithGoogle() async {
    isLoading = true;
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credentials = GoogleAuthProvider.credential(
      idToken: gAuth.idToken,
      accessToken: gAuth.accessToken,
    );

    isLoading = false;
    notifyListeners();

    var userCredentials = await firebaseAuth.signInWithCredential(credentials);
    currentUser = userCredentials.user;
    return currentUser;
  }

  Future<UserCredential> signInWithTwitter() async {
    // Create a TwitterLogin instance
    final twitterLogin = TwitterLogin(
        apiKey: '9F3Ud0ltt234149H7NhK11lqJ',
        apiSecretKey: ' yiazlhZrzxbsmNTAVclFAruX9HntKjjwbegQTNHzasoo581KVN',
        redirectURI:
            'https://bloc-firebase-9c498.firebaseapp.com/__/auth/handler');

    // Trigger the sign-in flow
    final authResult = await twitterLogin.login();

    // Create a credential from the access token
    final twitterAuthCredential = TwitterAuthProvider.credential(
      accessToken: authResult.authToken!,
      secret: authResult.authTokenSecret!,
    );

    // Once signed in, return the UserCredential
    return await firebaseAuth.signInWithCredential(twitterAuthCredential);
  }

  Future<UserCredential> signinWithGithub() async {
    GithubAuthProvider githubAuthProvider = GithubAuthProvider();

    return firebaseAuth.signInWithProvider(githubAuthProvider);
  }

  signinWithPhone(BuildContext context) async {
    firebaseAuth.verifyPhoneNumber(
      phoneNumber: '+923046268933',
      verificationCompleted: (credentials) {},
      verificationFailed: (ex) {},
      codeSent: (verificationId, resendToken) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              verificationId: verificationId,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (verificationId) {},
    );
  }

  void signOutGoogleUser() async {
    try {
      await firebaseAuth.signOut();
      print("User signed out successfully");
    } catch (e) {
      print("Error signing out: $e");
    }
  }
}
