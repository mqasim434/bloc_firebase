import 'package:bloc_firebase/providers/chat_provider.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/screens/inbox_screen.dart';
import 'package:bloc_firebase/screens/profile.dart';
import 'package:bloc_firebase/screens/signin_screen.dart';
import 'package:bloc_firebase/services/background_services.dart';
import 'package:bloc_firebase/services/play_audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'LocationScreen.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key});
  late ChatProvider chatProvider = ChatProvider();

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WidgetsBindingObserver {

  void initializeProvider(BuildContext context) {
    widget.chatProvider = Provider.of<ChatProvider>(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    BackgroundServices backgroundServices = BackgroundServices();
    switch (state) {
      case AppLifecycleState.paused:
        backgroundServices.initService();
        widget.chatProvider.updateUserFields({
          'isTyping': false,
          'lastSeen':
          '${(DateTime.now().hour) % 12}:${DateTime.now().minute} ${DateTime.now().hour > 12 ? 'PM' : 'AM'}'
        });
        break;

      case AppLifecycleState.resumed:
        backgroundServices.service.invoke('stopService');
        widget.chatProvider.updateUserFields({'isOnline': true});

      case AppLifecycleState.detached:
        backgroundServices.initService();
        widget.chatProvider.updateUserFields({
          'isTyping': false,
          'lastSeen':
          '${(DateTime.now().hour) % 12}:${DateTime.now().minute} ${DateTime.now().hour > 12 ? 'PM' : 'AM'}'
        });
        break;
      default:
        backgroundServices.service.invoke('stopService');
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    widget.chatProvider.updateUserFields({'isOnline':true});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screensList = [
      Inbox(),
      const LiveLocationScreen(),
      const ProfileScreen(),
    ];

    final registrationProvider = Provider.of<RegistrationProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat App'),
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                registrationProvider.signOutGoogleUser();
                chatProvider.updateUserFields({
                  'isOnline': false,
                });
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                    (route) => route.isFirst);
              },
              icon: const Icon(Icons.logout),
            )
          ],
          bottom: const TabBar(
            tabs: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text('Inbox'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text('Live Location'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text('Profile'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: screensList,
        ),
      ),
    );
  }
}
