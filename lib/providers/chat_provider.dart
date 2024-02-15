import 'dart:convert';

import 'package:bloc_firebase/services/notification_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatProvider extends ChangeNotifier {
  TextEditingController messageController = TextEditingController();

  void clearController() {
    messageController.clear();
    notifyListeners();
  }

  void sendMessage(String email) async{
    FirebaseFirestore.instance.collection('messages').add({
      'text': messageController.text,
      'senderId': email, // Assuming you have the current user's ID
      'timestamp': DateTime.now(),
    });
    NotificationServices notificationServices = NotificationServices();
    
    final tokenData = await FirebaseFirestore.instance.collection('deviceTokens').where('email',isNotEqualTo: email).get();

    String token = tokenData.docs.first.data()['token'];

      var data = {
        'to':token,
        'priority': 'high',
        'notification':{
          'title':email,
          'body':messageController.text,
        }
      };
      http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          body: jsonEncode(data),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'key=AAAAdXFIeUc:APA91bEtFbRX7OfO1J0FG6LD6STe3I21HXrXJUatzP_f520DWg2Z7CNzNAeXbbsRQRxCHhkyz5BTbitnAlLizw82ECOGlibYIPJzojSTcXPQ4Nk8NvksSlTMKiZB0JP-BYhrXpiX1hDR'
          }
      );

  }

  void deleteMessage(String id) {
    FirebaseFirestore.instance.collection('messages').doc(id).delete();
    notifyListeners();
  }
}
