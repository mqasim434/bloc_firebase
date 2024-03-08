import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ChatProvider extends ChangeNotifier {
  TextEditingController messageController = TextEditingController();
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final signedInUser = FirebaseAuth.instance.currentUser?.email;

  String? lastMessage;
  Timestamp? lastMessageTime ;

  void clearController() {
    messageController.clear();
    notifyListeners();
  }

  void sendMessage({
    required String senderEmail,
    required String receiverEmail,
    String message = '',
    bool isImage = false,
    bool isLocation = false,
    bool isSent = true,
    bool isDelivered = false,
    bool isRead = false,
  }) async {
    String notificationMessage = messageController.text;
    Timestamp currentTime = Timestamp.now();
    DocumentReference messageRef = await firebaseFirestore.collection('messages').add({
      'text': message == '' ? messageController.text : message,
      'senderId': senderEmail,
      'receiverId': receiverEmail,
      'isSent': isSent,
      'isDelivered': isDelivered,
      'isRead': isRead,
      'isImage': isImage,
      'isLocation': isLocation,
      'timestamp': currentTime,
    });

    final tokenData = await FirebaseFirestore.instance
        .collection('deviceTokens')
        .where('email', isEqualTo: receiverEmail)
        .get();

    if (tokenData.docs.isNotEmpty) {
      String token = tokenData.docs.first.data()['token'];
      var data = {
        'to': token,
        'priority': 'high',
        'notification': {
          'title': senderEmail,
          'body': notificationMessage,
          'sound': 'assets/sounds/custom_sound.mp3',
        }
      };

      try {
        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          body: jsonEncode(data),
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization':
                'key=AAAAdXFIeUc:APA91bEtFbRX7OfO1J0FG6LD6STe3I21HXrXJUatzP_f520DWg2Z7CNzNAeXbbsRQRxCHhkyz5BTbitnAlLizw82ECOGlibYIPJzojSTcXPQ4Nk8NvksSlTMKiZB0JP-BYhrXpiX1hDR',
          },
        );
        await messageRef.update({'isDelivered': true});
        print('Message sent successfully');
      } catch (error) {
        print('Error sending message: $error');
      }
    } else {
      print('No token found for email: $receiverEmail');
    }
  }

  void deleteMessage(String id) {
    firebaseFirestore.collection('messages').doc(id).delete();
    notifyListeners();
  }

  void markAsRead(String messageId){
    FirebaseFirestore.instance.collection('messages').doc(messageId).update(
        {'isRead': true});
  }

  filterMessages(AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot,
      String senderEmail, String receiverEmail) {
    List<QueryDocumentSnapshot<Map<String, dynamic>>> messages = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> message
        in snapshot.data!.docs) {
      if (message.data()['email'] == senderEmail ||
          message.data()['email'] == receiverEmail) {
        messages.add(message);
        print('message: $message');
      }
    }
    notifyListeners();
    return messages;
  }


  void updateUserFields(Map<String,dynamic> args) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();
      args.forEach((field, value){
        for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot
        in querySnapshot.docs) {
          ()async{
            await docSnapshot.reference.update({field: value});
          }.call();
          print('User $field status updated successfully for email: $signedInUser');
        }
      });
    } catch (error) {
      print('Error updating status for email $signedInUser: $error');
    }
  }

  Stream<dynamic> getUserField(String email,String field) {
    return firebaseFirestore
        .collection('users')
        .where('email', isEqualTo: signedInUser)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data()['field'];
      } else {
        return null;
      }
    });
  }

  void updateLastMessage(String lastMsg) {
    lastMessage = lastMsg;
    notifyListeners();
  }
  void updateLastMessageTimestamp(Timestamp lastMsgTime) {
    lastMessageTime = lastMsgTime;
    notifyListeners();
  }

  void addLastMessage(
    String email,
  ) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot
          in querySnapshot.docs) {
        await docSnapshot.reference.update({'lastMessage': lastMessage});
        await docSnapshot.reference.update({'lastMessageTimestamp': lastMessageTime});
        print('User last seen updated successfully for email: $email');
      }
    } catch (error) {
      print('Error updating user last seen for email $email: $error');
    }
  }

  pickImage(String source, String senderEmail, String receiverEmail) async {
    ImagePicker imagePicker = ImagePicker();

    XFile? pickedImage;
    String? _imageUrl;

    if (source == 'camera') {
      pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
    } else {
      pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    }

    if (pickedImage != null) {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('chatImages')
          .child(senderEmail)
          .child('image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      try {
        await ref.putFile(File(pickedImage!.path.toString()));
        String imageUrl = await ref.getDownloadURL();
        _imageUrl = imageUrl;
        sendMessage(
            senderEmail: senderEmail,
            receiverEmail: receiverEmail,
            message: _imageUrl.toString(),
            isImage: true);
        print('Image uploaded successfully: $_imageUrl');
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  sendCurrentLocation(String senderEmail, String receiverEmail) async {
    Geolocator.getCurrentPosition().then((value) => {
          sendMessage(
              senderEmail: senderEmail,
              receiverEmail: receiverEmail,
              isLocation: true,
              message:
                  'https://www.google.com/maps/search/?api=1&query=${value.latitude},${value.longitude}')
        });

    notifyListeners();
  }
}
