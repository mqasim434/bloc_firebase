import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/screens/otp_screen.dart';
import 'package:bloc_firebase/services/notification_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter_login/entity/auth_result.dart';
import 'package:twitter_login/twitter_login.dart';

class RegistrationProvider extends ChangeNotifier {
  bool isLoading = false;
  UserModel? currentUser;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  NotificationServices notificationServices = NotificationServices();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void clearControllers() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    notifyListeners();
  }

  Future<UserCredential> signUpWithEmail() async {
    var credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
    UserModel userData = UserModel(
      email: emailController.text,
    );
    firebaseFirestore.collection('deviceTokens').add({
      'email': emailController.text,
      'token': await notificationServices.getDeviceToken()
    });
    firebaseFirestore.collection('users').add(userData.toJson());
    return credential;
  }

  Future<UserCredential> signInWithEmail() async {
    isLoading = true;
    notifyListeners();
    var credential = await firebaseAuth.signInWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );
    final querySnapshot = await FirebaseFirestore.instance
        .collection('deviceTokens')
        .where('email', isEqualTo: emailController.text)
        .get();
    for (final docSnapshot in querySnapshot.docs) {
      await docSnapshot.reference
          .update({'token': await notificationServices.getDeviceToken()});
    }
    isLoading = false;
    currentUser = UserModel(
      name: credential.user!.displayName,
      email: credential.user!.email,
      phone: credential.user!.phoneNumber,
      imageUrl: credential.user!.photoURL,
    );
    notifyListeners();
    return credential;
  }

  Future<UserModel?> signupWithGoogle() async {
    isLoading = true;
    notifyListeners();
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    final credentials = GoogleAuthProvider.credential(
      idToken: gAuth.idToken,
      accessToken: gAuth.accessToken,
    );
    isLoading = false;
    var userCredentials = await firebaseAuth.signInWithCredential(credentials);
    currentUser = UserModel(
      name: userCredentials.user!.displayName,
      email: userCredentials.user!.email,
      phone: userCredentials.user!.phoneNumber,
      imageUrl: userCredentials.user!.photoURL,
    );
    firebaseFirestore.collection('deviceTokens').add({
      'email': emailController.text,
      'token': await notificationServices.getDeviceToken()
    });
    firebaseFirestore.collection('users').add(currentUser!.toJson());
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

  Future<UserModel?> signinWithGithub() async {
    GithubAuthProvider githubAuthProvider = GithubAuthProvider();

    var userCredentials = firebaseAuth.signInWithProvider(githubAuthProvider);

    userCredentials.then((value) {
      currentUser = UserModel(
        name: value.user!.displayName,
        email: value.user!.email,
        phone: value.user!.phoneNumber,
        imageUrl: value.user!.photoURL,
      );
    });

    firebaseFirestore.collection('deviceTokens').add({
      'email': emailController.text,
      'token': await notificationServices.getDeviceToken()
    });
    firebaseFirestore.collection('users').add(currentUser!.toJson());

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
