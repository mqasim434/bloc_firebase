import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/providers/chat_provider.dart';
import 'package:bloc_firebase/providers/inbox_provider.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/screens/chat_screen.dart';
import 'package:bloc_firebase/services/play_audio_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Inbox extends StatelessWidget {
  Inbox({
    super.key,
  });

  ChatProvider chatProvider = ChatProvider();
  RegistrationProvider registrationProvider = RegistrationProvider();

  User? signedInUser = FirebaseAuth.instance.currentUser;

  void initializeProvider(BuildContext context) {
    chatProvider = Provider.of<ChatProvider>(context);
    registrationProvider = Provider.of<RegistrationProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    final inboxProvider = Provider.of<InboxProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: inboxProvider.getUsersFromFirestore(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.hasData) {
                List<Map<String, dynamic>> usersList = snapshot.data!
                    .where((map) => map['email'] != signedInUser!.email)
                    .toList();
                return ListView.builder(
                  itemCount: usersList.length,
                  itemBuilder: (context, index) {
                    var user = usersList[index];
                    if (user.isNotEmpty) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                otherUser: UserModel(
                                  email: user['email'].toString(),
                                ),
                              ),
                            ),
                          );
                        },
                        child: Card(
                          child: ListTile(
                            leading: user['imageUrl'] != null
                                ? CircleAvatar(
                                    radius: 25,
                                    backgroundImage:
                                        NetworkImage(user['imageUrl']))
                                : const CircleAvatar(
                                    radius: 25,
                                    child: Icon(Icons.person),
                                  ),
                            title: Text(user['email']),
                            subtitle: ((user['isTyping'] == true) && (true))
                                ? const Text('typing...')
                                : (user['lastMessage'] != null ||
                                        user['lastMessage'] != '')
                                    ? Text(user['lastMessage'] ?? '')
                                    : const Text(''),
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: Text('No User Yet'));
                    }
                  },
                );
              } else {
                return const Center(
                  child: Text(
                      'No data available'), // Placeholder text or handle differently
                );
              }
            }
          },
        ),
      ),
    );
  }
}
