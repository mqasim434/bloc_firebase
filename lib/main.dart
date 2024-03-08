import 'package:bloc_firebase/providers/chat_provider.dart';
import 'package:bloc_firebase/providers/inbox_provider.dart';
import 'package:bloc_firebase/providers/location_provider.dart';
import 'package:bloc_firebase/providers/otp_provider.dart';
import 'package:bloc_firebase/providers/profile_provider.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/providers/splash_provider.dart';
import 'package:bloc_firebase/services/awesome_notification_services.dart';
import 'package:bloc_firebase/screens/splash_screen.dart';
import 'package:bloc_firebase/services/play_audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  AwesomeNotificationServices.initializeNotification();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => OTPProvider()),
        ChangeNotifierProvider(create: (_) => SplashProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => InboxProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PlayAudioService()),
      ],
      child: MaterialApp(
          navigatorKey: MyApp.navigatorKey,
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          home: const SplashScreen()),
    );
  }
}
