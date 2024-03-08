import 'package:bloc_firebase/providers/chat_provider.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/providers/splash_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  ChatProvider chatProvider = ChatProvider();
  RegistrationProvider registrationProvider = RegistrationProvider();

  void initializeProvider(BuildContext context) {
    chatProvider = Provider.of<ChatProvider>(context);
    registrationProvider = Provider.of<RegistrationProvider>(context);
  }

  @override
  void initState() {
    SplashProvider().checkSession(context);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    initializeProvider(context);
    return const Scaffold(
      body: Center(
              child: Text(
                'Splash',
                style: TextStyle(fontSize: 24),
              ),
            ),
    );
  }
}
