import 'package:bloc_firebase/components/message_widget.dart';
import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/providers/chat_provider.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/services/awesome_notification_services.dart';
import 'package:bloc_firebase/services/notification_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen(
      {super.key,
      required this.otherUser,
      this.message = '',
      this.isReplying = false});

  final UserModel otherUser;
  String? message;
  bool isReplying;
  NotificationServices notificationServices = NotificationServices();
  ChatProvider chatProvider = ChatProvider();
  RegistrationProvider registrationProvider = RegistrationProvider();
  User? signedInUser = FirebaseAuth.instance.currentUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  void initializeProvider(BuildContext context) {
    widget.chatProvider = Provider.of<ChatProvider>(context);
    widget.registrationProvider = Provider.of<RegistrationProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    initializeProvider(context);
    AwesomeNotificationServices()
        .initializeProvider(context, widget.otherUser.email.toString());
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          leading: BackButton(
            onPressed: () {
              widget.chatProvider.updateUserFields({
                'isTyping': false,
              });
              Navigator.pop(context);
            },
          ),
          title: Row(
            children: [
              InkWell(
                onTap: () async {},
                child: CircleAvatar(
                  child: widget.registrationProvider.currentUser?.imageUrl
                              ?.isEmpty ??
                          true
                      ? const Icon(Icons.person)
                      : Image.network(
                          widget.registrationProvider.currentUser!.imageUrl!),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.otherUser.email.toString()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      StreamBuilder<dynamic>(
                          stream: widget.chatProvider.getUserField(
                              widget.otherUser.email.toString(),
                              'typingStatus'),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data == true
                                  ? const Text(
                                      'typing...',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.blueAccent,
                                      ),
                                    )
                                  : StreamBuilder(
                                      stream: widget.chatProvider.getUserField(
                                          widget.otherUser.email.toString(),
                                          'isOnline'),
                                      builder: (context, snapshot) {
                                        return snapshot.data == true
                                            ? const Text(
                                                'online',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.blueAccent,
                                                ),
                                              )
                                            : StreamBuilder(
                                                stream: widget.chatProvider
                                                    .getUserField(
                                                        widget.otherUser.email
                                                            .toString(),
                                                        'lastSeen'),
                                                builder: (context, snapshot) {
                                                  return Text(
                                                    snapshot.data.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.blueAccent,
                                                    ),
                                                  );
                                                },
                                              );
                                      },
                                    );
                            } else {
                              return const Text('');
                            }
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData) {
                      return const Center(child: Text('No Messages Yet!'));
                    } else {
                      var messages = snapshot.data!.docs
                          .where(
                            (element) => ((element.data()['senderId'] ==
                                        FirebaseAuth
                                            .instance.currentUser!.email &&
                                    element.data()['receiverId'] ==
                                        widget.otherUser.email) ||
                                (element.data()['receiverId'] ==
                                        FirebaseAuth
                                            .instance.currentUser!.email &&
                                    element.data()['senderId'] ==
                                        widget.otherUser.email)),
                          )
                          .toList();
                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          var message = messages[index];
                          return MessageWidget(
                            messageId: message.id,
                            isImage: message['isImage'],
                            senderId: message['senderId'],
                            receiverId: message['receiverId'],
                            currentUser: widget.signedInUser!.email.toString(),
                            message: message['text'],
                            isSent: message['isSent'],
                            isDelivered: message['isDelivered'],
                            isRead: message['isRead'],
                            isLocation: message['isLocation'],
                            isSentByUser: message['senderId'] ==
                                widget.signedInUser!.email.toString(),
                          );
                        },
                      );
                    }
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: widget.chatProvider.messageController,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.only(bottom: 30, left: 20, top: 0),
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        suffixIcon: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    child: SizedBox(
                                      width: 200,
                                      height: 180,
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              widget.chatProvider.pickImage(
                                                  'camera',
                                                  widget.signedInUser!.email
                                                      .toString(),
                                                  widget.otherUser.toString());
                                              Navigator.pop(context);
                                            },
                                            child: const ListTile(
                                              title: Text('Camera'),
                                              trailing: Icon(Icons.camera),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              widget.chatProvider.pickImage(
                                                  'gallery',
                                                  widget.signedInUser!.email
                                                      .toString(),
                                                  widget.otherUser.email
                                                      .toString());
                                              Navigator.pop(context);
                                            },
                                            child: const ListTile(
                                              title: Text('Gallery'),
                                              trailing:
                                                  Icon(Icons.browse_gallery),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () async {
                                              widget.chatProvider
                                                  .sendCurrentLocation(
                                                      widget.signedInUser!.email
                                                          .toString(),
                                                      widget.otherUser.email
                                                          .toString());
                                              Navigator.pop(context);
                                            },
                                            child: const ListTile(
                                              title: Text('Location'),
                                              trailing: Icon(Icons.location_on),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          },
                          child: const Icon(
                            Icons.attach_file,
                            size: 30,
                          ),
                        ),
                      ),
                      onChanged: (text) {
                        if (text.isNotEmpty ||
                            text != '' &&
                                FirebaseAuth.instance.currentUser != null) {
                          widget.chatProvider
                              .updateUserFields({'isTyping': true});
                        } else {
                          widget.chatProvider
                              .updateUserFields({'isTyping': false});
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
                          if (widget
                              .chatProvider.messageController.text.isNotEmpty) {
                            widget.chatProvider.updateLastMessage(
                                widget.chatProvider.messageController.text);
                            if (widget.registrationProvider.currentUser !=
                                null) {
                              widget.chatProvider.sendMessage(
                                  senderEmail:
                                      widget.signedInUser!.email.toString(),
                                  receiverEmail:
                                      widget.otherUser.email.toString());
                            }
                            widget.chatProvider.clearController();
                            widget.chatProvider
                                .updateUserFields({'isTyping': false});
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
