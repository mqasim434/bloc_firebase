import 'package:bloc_firebase/components/message_widget.dart';
import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/providers/chat_provider.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/services/notification_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.userModel}) : super(key: key);

  final UserModel userModel;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
 NotificationServices notificationServices = NotificationServices();
  @override

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final registrationProvider = Provider.of<RegistrationProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            widget.userModel.name.toString(),
          ),
          centerTitle: true,
          actions: [
            IconButton(onPressed: (){
              registrationProvider.signOutGoogleUser();
              Navigator.pop(context);
            }, icon: const Icon(Icons.logout))
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var messages = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true, // Reverse the order of items
                    itemCount: messages!.length,
                    itemBuilder: (context, index) {
                      var message = messages[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          MessageWidget(
                            messageId: message.id,
                            email: message['senderId'],
                            message: message['text'],
                            isSentByUser: message['senderId'] == widget.userModel.email.toString(),
                          ),
                        ],
                      );
                    },
                  );
                  ;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: chatProvider.messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onChanged: (text){

                      },
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          chatProvider.sendMessage(widget.userModel.email.toString());
                          chatProvider.clearController();
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
