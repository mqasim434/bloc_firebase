import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/providers/chat_provider.dart';
import 'package:bloc_firebase/providers/inbox_provider.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Inbox extends StatelessWidget {
  const Inbox({Key? key});

  @override
  Widget build(BuildContext context) {
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final inboxProvider = Provider.of<InboxProvider>(context);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Inbox'),
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                registrationProvider.signOutGoogleUser();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.logout),
            )
          ],
        ),
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
                    .where((map) =>
                        map['email'] != registrationProvider.currentUser?.email)
                    .toList();
                return ListView.builder(
                  itemCount: usersList.length,
                  itemBuilder: (context, index) {
                    var user = usersList[index];
                    if (user != null) {
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
                            subtitle: user['isTyping'] == true
                                ? const Text('typing...')
                                : (user['lastMessage'] != null ||
                                        user['lastMessage'] != '')
                                    ? Text(user['lastMessage'])
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
