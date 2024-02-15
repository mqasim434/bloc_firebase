import 'package:bloc_firebase/blocs/location_bloc/location_bloc.dart';
import 'package:bloc_firebase/providers/chat_provider.dart';
import 'package:bloc_firebase/providers/location_provider.dart';
import 'package:bloc_firebase/providers/otp_provider.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/providers/splash_provider.dart';
import 'package:bloc_firebase/repository/signup_repository.dart';
import 'package:bloc_firebase/screens/chat_screen.dart';
import 'package:bloc_firebase/screens/live_location.dart';
import 'package:bloc_firebase/screens/live_location_screen.dart';
import 'package:bloc_firebase/screens/registration_screen.dart';
import 'package:bloc_firebase/screens/signin_screen.dart';
import 'package:bloc_firebase/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RegistrationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OTPProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SplashProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const SplashScreen(),
      ),
    );
  }
}
