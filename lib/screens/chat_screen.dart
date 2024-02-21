import 'package:bloc_firebase/components/message_widget.dart';
import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/providers/chat_provider.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/services/notification_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({required this.otherUser});

  final UserModel otherUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {


  NotificationServices notificationServices = NotificationServices();
  ChatProvider chatProvider = ChatProvider();
  RegistrationProvider registrationProvider = RegistrationProvider();

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
        chatProvider.changeOnlineStatus(registrationProvider.currentUser!.email.toString(), true);
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }


  @override
  Widget build(BuildContext context) {
    initializeProvider(context);
    // final chatProvider = Provider.of<ChatProvider>(context);
    // final registrationProvider = Provider.of<RegistrationProvider>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: BackButton(
            onPressed: () {
              chatProvider.updateTypingStatus(registrationProvider.currentUser!.email.toString(),false);
              Navigator.pop(context);
            },
          ),
          title: Row(
            children: [
              CircleAvatar(
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.otherUser.email.toString(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      StreamBuilder<String>(
                          stream: chatProvider.getTypingStatus(
                              widget.otherUser.email.toString()),
                          builder: (context, snapshot) {
                            return Align(
                              alignment: Alignment.topCenter,
                              child: snapshot.data.toString() == 'typing'
                                  ? Text(
                                      '${snapshot.data.toString()}...',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blueAccent,
                                      ),
                                    )
                                  : StreamBuilder(
                                      stream: chatProvider.getOnlineStatus(
                                          widget.otherUser.email.toString()),
                                      builder: (context, snapshot) {
                                        return snapshot.data.toString() ==
                                                'online'
                                            ? Text(
                                                snapshot.data.toString(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.blueAccent,
                                                ),
                                              )
                                            : StreamBuilder(
                                            stream: chatProvider.getLastSeen(
                                                widget.otherUser.email.toString()),
                                            builder: (context, snapshot) {
                                              return Text(
                                                snapshot.data.toString(),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.blueAccent,
                                                ),
                                              );
                                            });
                                      }),
                            );
                          }),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var messages = snapshot.data!.docs
                      .where(
                        (element) => ((element.data()['senderId'] ==
                                    registrationProvider.currentUser!.email &&
                                element.data()['receiverId'] ==
                                    widget.otherUser.email) ||
                            (element.data()['receiverId'] ==
                                    registrationProvider.currentUser!.email &&
                                element.data()['senderId'] ==
                                    widget.otherUser.email)),
                      )
                      .toList();
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
                            senderId: message['senderId'],
                            message: message['text'],
                            isSentByUser: message['senderId'] ==
                                registrationProvider.currentUser!.email
                                    .toString(),
                          ),
                        ],
                      );
                    },
                  );
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
                      onChanged: (text) {
                        if (text.isNotEmpty||text!='' && registrationProvider.currentUser!=null) {
                          chatProvider.updateTypingStatus(
                              registrationProvider.currentUser!.email.toString(),
                              true);
                        } else {
                          chatProvider.updateTypingStatus(
                              registrationProvider.currentUser!.email.toString(),
                              false);
                        }
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
                          if(chatProvider.messageController.text.isNotEmpty){
                            chatProvider.updateLastMessage(chatProvider.messageController.text);
                            if(registrationProvider.currentUser!=null){
                              chatProvider.sendMessage(
                                  registrationProvider.currentUser!.email
                                      .toString(),
                                  widget.otherUser.email.toString());
                            }
                            chatProvider.clearController();
                            chatProvider.updateTypingStatus(registrationProvider.currentUser!.email
                                .toString(), false);
                          }
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
