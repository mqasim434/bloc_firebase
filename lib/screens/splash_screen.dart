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

class _SplashScreenState extends State<SplashScreen> with WidgetsBindingObserver {

  ChatProvider chatProvider = ChatProvider();
  RegistrationProvider registrationProvider = RegistrationProvider();

  @override
  void initState() {
    super.initState();
    SplashProvider().checkSession(context);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state){
      case AppLifecycleState.paused:
        print('Paused');
        chatProvider.changeOnlineStatus(registrationProvider.currentUser!.email.toString(), false);
        chatProvider.updateTypingStatus(registrationProvider.currentUser!.email.toString(), false);
        break;
      case AppLifecycleState.detached:
        print('Killed');
        chatProvider.changeOnlineStatus(registrationProvider.currentUser!.email.toString(), false);
        chatProvider.updateTypingStatus(registrationProvider.currentUser!.email.toString(), false);
        chatProvider.updateLastSeen(registrationProvider.currentUser!.email.toString(), '${DateTime.now().hour}/${DateTime.now().minute}');
        break;
      case AppLifecycleState.resumed:
        print('resumed');
      default:
        print('HELLO');
    }
    super.didChangeAppLifecycleState(state);
  }

  void initializeProvider(BuildContext context){
    chatProvider = Provider.of<ChatProvider>(context);
    registrationProvider = Provider.of<RegistrationProvider>(context);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
