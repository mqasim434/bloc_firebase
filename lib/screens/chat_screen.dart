import 'package:bloc_firebase/components/message_widget.dart';
import 'package:bloc_firebase/models/user_model.dart';
import 'package:bloc_firebase/providers/chat_provider.dart';
import 'package:bloc_firebase/providers/registration_provider.dart';
import 'package:bloc_firebase/screens/profile.dart';
import 'package:bloc_firebase/services/awesome_notification_services.dart';
import 'package:bloc_firebase/services/notification_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        print('Paused');
        widget.chatProvider.changeOnlineStatus(
            widget.registrationProvider.currentUser!.email.toString(), false);
        widget.chatProvider.updateLastSeen(
            widget.registrationProvider.currentUser!.email.toString(),
            '${(DateTime.now().hour) % 12}:${DateTime.now().minute} ${DateTime.now().hour > 12 ? 'PM' : 'AM'}');
        widget.chatProvider.updateTypingStatus(
            widget.registrationProvider.currentUser!.email.toString(), false);
        break;
      case AppLifecycleState.detached:
        widget.chatProvider.changeOnlineStatus(
            widget.registrationProvider.currentUser!.email.toString(), false);
        widget.chatProvider.updateTypingStatus(
            widget.registrationProvider.currentUser!.email.toString(), false);
        widget.chatProvider.updateLastSeen(
            widget.registrationProvider.currentUser!.email.toString(),
            '${(DateTime.now().hour) % 12}:${DateTime.now().minute} ${DateTime.now().hour > 12 ? 'PM' : 'AM'}');
        break;
      case AppLifecycleState.resumed:
        widget.chatProvider.changeOnlineStatus(
            widget.registrationProvider.currentUser!.email.toString(), true);
      default:
        print('HELLO');
    }
    super.didChangeAppLifecycleState(state);
  }

  void initializeProvider(BuildContext context) {
    widget.chatProvider = Provider.of<ChatProvider>(context);
    widget.registrationProvider = Provider.of<RegistrationProvider>(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
              widget.chatProvider.updateTypingStatus(
                  widget.registrationProvider.currentUser!.email.toString(),
                  false);
              Navigator.pop(context);
            },
          ),
          title: Row(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ProfileScreen()));
                },
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
                      StreamBuilder<String>(
                          stream: widget.chatProvider.getTypingStatus(
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
                                      stream: widget.chatProvider
                                          .getOnlineStatus(widget
                                              .otherUser.email
                                              .toString()),
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
                                                stream: widget.chatProvider
                                                    .getLastSeen(widget
                                                        .otherUser.email
                                                        .toString()),
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
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var messages = snapshot.data!.docs
                      .where(
                        (element) => ((element.data()['senderId'] ==
                                    widget.registrationProvider.currentUser!
                                        .email &&
                                element.data()['receiverId'] ==
                                    widget.otherUser.email) ||
                            (element.data()['receiverId'] ==
                                    widget.registrationProvider.currentUser!
                                        .email &&
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
                          currentUser: widget
                              .registrationProvider.currentUser!.email
                              .toString(),
                          message: message['text'],
                          isSent: message['isSent'],
                          isDelivered: message['isDelivered'],
                          isRead: message['isRead'],
                          isLocation: message['isLocation'],
                          isSentByUser: message['senderId'] ==
                              widget.registrationProvider.currentUser!.email
                                  .toString(),
                        );
                      });
                },
              ),
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
                                                  widget.registrationProvider
                                                      .currentUser!.email
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
                                                  widget.registrationProvider
                                                      .currentUser!.email
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
                                                      widget
                                                          .registrationProvider
                                                          .currentUser!
                                                          .email
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
                                widget.registrationProvider.currentUser !=
                                    null) {
                          widget.chatProvider.updateTypingStatus(
                              widget.registrationProvider.currentUser!.email
                                  .toString(),
                              true);
                        } else {
                          widget.chatProvider.updateTypingStatus(
                              widget.registrationProvider.currentUser!.email
                                  .toString(),
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
                          if (widget
                              .chatProvider.messageController.text.isNotEmpty) {
                            widget.chatProvider.updateLastMessage(
                                widget.chatProvider.messageController.text);
                            if (widget.registrationProvider.currentUser !=
                                null) {
                              widget.chatProvider.sendMessage(
                                  senderEmail: widget
                                      .registrationProvider.currentUser!.email
                                      .toString(),
                                  receiverEmail:
                                      widget.otherUser.email.toString());
                            }
                            widget.chatProvider.clearController();
                            widget.chatProvider.updateTypingStatus(
                                widget.registrationProvider.currentUser!.email
                                    .toString(),
                                false);
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
