import 'package:bloc_firebase/providers/chat_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageWidget extends StatefulWidget {
  final String message;
  final String senderId;
  final String receiverId;
  final String currentUser;
  final bool isSentByUser;
  final String messageId;
  final bool isImage;
  final bool isSent;
  final bool isDelivered;
  final bool isRead;
  final bool isLocation;

  const MessageWidget({
    Key? key,
    required this.message,
    required this.isSentByUser,
    required this.messageId,
    required this.receiverId,
    required this.currentUser,
    required this.senderId,
    required this.isImage,
    required this.isSent,
    required this.isDelivered,
    required this.isRead,
    required this.isLocation,
  }) : super(key: key);

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {

  @override
  void initState() {
    if(widget.currentUser==widget.receiverId){
      FirebaseFirestore.instance.collection('messages').doc(widget.messageId).update(
          {'isRead': true});
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    return Align(
      alignment: widget.isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: InkWell(
        onLongPress: () {
          chatProvider.deleteMessage(widget.messageId);
        },
        child: Column(
          crossAxisAlignment:
              widget.isSentByUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            widget.isImage
                ? InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: Image.network(
                                widget.message,
                                fit: BoxFit.cover,
                              ),
                            );
                          });
                    },
                    child: Container(
                      width: 200,
                      height: 200,
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.isSentByUser ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(12),
                          topRight: const Radius.circular(12),
                          bottomLeft: widget.isSentByUser? const Radius.circular(0):const Radius.circular(12),
                          bottomRight: widget.isSentByUser? const Radius.circular(0):const Radius.circular(12),
                        ),
                      ),
                      child: Image.network(
                        widget.message,
                        fit: BoxFit.cover,
                        width: 180,
                        height: 180,
                      ),
                    ),
                  )
                : widget.isLocation
                    ? InkWell(
                        onTap: () async {
                          if (!await launchUrl(Uri.parse(widget.message))) {
                            throw Exception('Could not launch ${widget.message}');
                          }
                        },
                        child: Container(
                          width: 200,
                          height: 250,
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                widget.isSentByUser ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                'assets/icons/map.png',
                                fit: BoxFit.cover,
                                width: 180,
                                height: 180,
                              ),
                              const Text(
                                'Tap to Open',
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: widget.isSentByUser ? Colors.blue : Colors.grey[300],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft: widget.isSentByUser? const Radius.circular(12):const Radius.circular(0),
                            bottomRight: widget.isSentByUser? const Radius.circular(0):const Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          widget.message,
                          style: TextStyle(
                              color:
                                  widget.isSentByUser ? Colors.white : Colors.black),
                        ),
                      ),
            Padding(
              padding: widget.isSentByUser
                  ? const EdgeInsets.only(right: 10.0)
                  : const EdgeInsets.only(left: 10.0),
              child: Row(
                mainAxisAlignment: widget.isSentByUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Text(widget.senderId),
                  widget.isSentByUser
                      ? Icon(
                          widget.isDelivered
                              ? Icons.done_all
                              : widget.isSent
                                  ? Icons.done
                                  : null,
                          color: widget.isRead ? Colors.blueAccent : Colors.white,
                        )
                      : const SizedBox()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
