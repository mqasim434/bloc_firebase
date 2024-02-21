import 'package:bloc_firebase/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageWidget extends StatelessWidget {
  final String message;
  final String senderId;
  final bool isSentByUser;
  final String messageId;

  const MessageWidget({
    Key? key,
    required this.message,
    required this.isSentByUser,
    required this.messageId,
    required this.senderId
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    return Align(
      alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: InkWell(
        onLongPress: (){
          chatProvider.deleteMessage(messageId);
        },
        child: Column(
          crossAxisAlignment: isSentByUser ?CrossAxisAlignment.end:CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSentByUser ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message,
                style: TextStyle(color: isSentByUser ? Colors.white : Colors.black),
              ),
            ),
            Padding(
              padding: isSentByUser?const EdgeInsets.only(right: 10.0):const EdgeInsets.only(left: 10.0),
              child: Text(senderId),
            ),
          ],
        ),
      ),
    );
  }
}
