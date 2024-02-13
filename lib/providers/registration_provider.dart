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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  Future<UserCredential> signUpWithEmail() async {
    var credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
    return credential;
  }

  Future<UserCredential> signInWithEmail() async {
    var credential = await firebaseAuth.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
    return credential;
  }

  Future<User?> signupWithGoogle() async {
    isLoading = true;
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credentials = GoogleAuthProvider.credential(
      idToken: gAuth.idToken,
      accessToken: gAuth.accessToken,
    );
    isLoading = false;
    var userCredentials = await firebaseAuth.signInWithCredential(credentials);
    currentUser = userCredentials.user;
    notifyListeners();
    return currentUser;
  }

  Future<UserCredential> signInWithTwitter() async {
    final twitterLogin = TwitterLogin(
        apiKey: 'rn2oUofv8lHvN4Ko2rGNDemzP',
        apiSecretKey: 'cL41W8daWPuFH17bYKjAu0lUn1TLdd1PrHGIYKDcATWYbBrQzm',
        redirectURI:
            'https://bloc-firebase-9c498.firebaseapp.com/__/auth/handler');

    final authResult = await twitterLogin.login();

    final twitterAuthCredential = TwitterAuthProvider.credential(
      accessToken: authResult.authToken!,
      secret: authResult.authTokenSecret!,
    );

    return await firebaseAuth.signInWithCredential(twitterAuthCredential);
  }

  Future<User?> signinWithGithub() async {
    GithubAuthProvider githubAuthProvider = GithubAuthProvider();

    var userCredentials = firebaseAuth.signInWithProvider(githubAuthProvider);

    userCredentials.then((value) {
      currentUser = value.user;
    });

    return currentUser;
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
