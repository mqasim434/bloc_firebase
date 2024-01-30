import 'package:bloc_firebase/blocs/signup_bloc.dart';
import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/repository/signup_repository.dart';
import 'package:bloc_firebase/screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: BlocProvider<SignupBloc>(
        create: (_) => SignupBloc(),
        child: const SignupScreen(),
      ),
    );
  }
}