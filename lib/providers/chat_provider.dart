import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatProvider extends ChangeNotifier {
  TextEditingController messageController = TextEditingController();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  String? lastMessage;

  void clearController() {
    messageController.clear();
    notifyListeners();
  }

  void sendMessage(String senderEmail,String receiverEmail) async {
    firebaseFirestore.collection('messages').add({
      'text': messageController.text,
      'senderId': senderEmail,
      'receiverId': receiverEmail,
      'timestamp': DateTime.now(),
    });

    final tokenData = await FirebaseFirestore.instance
        .collection('deviceTokens')
        .where('email', isEqualTo: receiverEmail)
        .get();

    String token = tokenData.docs.first.data()['token'];

    var data = {
      'to': token,
      'priority': 'high',
      'notification': {
        'title': senderEmail,
        'body': messageController.text,
        'sound': 'assets/sounds/custom_sound.mp3',
      }
    };
    http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAAdXFIeUc:APA91bEtFbRX7OfO1J0FG6LD6STe3I21HXrXJUatzP_f520DWg2Z7CNzNAeXbbsRQRxCHhkyz5BTbitnAlLizw82ECOGlibYIPJzojSTcXPQ4Nk8NvksSlTMKiZB0JP-BYhrXpiX1hDR'
        });
  }

  void deleteMessage(String id) {
    firebaseFirestore.collection('messages').doc(id).delete();
    notifyListeners();
  }


  filterMessages(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot, String senderEmail, String receiverEmail){
    List<QueryDocumentSnapshot<Map<String,dynamic>>> messages = [];
    for(QueryDocumentSnapshot<Map<String,dynamic>> message in snapshot.data!.docs){
      if(message.data()['email']==senderEmail||message.data()['email']==receiverEmail){
        messages.add(message);
        print('message: $message');
      }
    }
    notifyListeners();
    return messages;
  }

  void updateTypingStatus(String email,bool typingStatus)async{
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot in querySnapshot.docs) {
        await docSnapshot.reference.update({'isTyping': typingStatus});
        print('User typing status updated successfully for email: $email');
      }
    } catch (error) {
      print('Error updating user typing status for email $email: $error');
    }

  }

  Stream<String> getTypingStatus(String email) {
    return firebaseFirestore
        .collection('users')
        .where('email', isEqualTo: email)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data()['isTyping'] == true
            ? 'typing'
            : 'not typing';
      } else {
        return 'User not found';
      }
    });
  }

  void changeOnlineStatus(String email,bool onlineStatus)async{
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot in querySnapshot.docs) {
        await docSnapshot.reference.update({'isOnline': onlineStatus});
        print('User online status updated successfully for email: $email');
      }
    } catch (error) {
      print('Error updating user online status for email $email: $error');
    }
  }


  Stream<String> getOnlineStatus(String email) {
    return firebaseFirestore
        .collection('users')
        .where('email', isEqualTo: email)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data()['isOnline'] == true
            ? 'online'
            : 'offline';
      } else {
        return 'User not found';
      }
    });
  }

  void updateLastSeen(String email,String lastSeen)async{
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot in querySnapshot.docs) {
        await docSnapshot.reference.update({'lastSeen': lastSeen});
        print('User last seen updated successfully for email: $email');
      }
    } catch (error) {
      print('Error updating user last seen for email $email: $error');
    }
  }

  Stream<String> getLastSeen(String email) {
    return firebaseFirestore
        .collection('users')
        .where('email', isEqualTo: email)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data()['lastSeen'];
      } else {
        return 'User not found';
      }
    });
  }

  void updateLastMessage(String lastMsg){
    lastMessage = lastMsg;
    notifyListeners();
  }

  void addLastMessage(String email,)async{
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot in querySnapshot.docs) {
        await docSnapshot.reference.update({'lastMessage': lastMessage});
        print('User last seen updated successfully for email: $email');
      }
    } catch (error) {
      print('Error updating user last seen for email $email: $error');
    }
  }

  Stream<String> getLastMessage(String email) {
    return firebaseFirestore
        .collection('users')
        .where('email', isEqualTo: email)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data()['lastMessage'];
      } else {
        return 'User not found';
      }
    });
  }


}
