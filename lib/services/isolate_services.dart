import 'dart:isolate';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class IsolateServices {
  void markUserOffline() async {
    ReceivePort receivePort = ReceivePort();

    try {
      await Isolate.spawn(updateOnlineStatus, [receivePort.sendPort, true]);
    } catch (e) {
      print(e);
    }
  }

  static void updateOnlineStatus(List<dynamic> args) async {
    SendPort sendPort = args[0];
    bool isOnline = args[1];

    try {
      await Firebase.initializeApp();

      String? signedInUserEmail = FirebaseAuth.instance.currentUser?.email;
      if (signedInUserEmail != null) {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: signedInUserEmail)
            .get();

        for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot
        in querySnapshot.docs) {
          await docSnapshot.reference.update({'isOnline': isOnline});
          print('User Online status updated for email: $signedInUserEmail');
        }
      } else {
        print('Current user email is null.');
      }
    } catch (error) {
      print('Error updating user online status: $error');
    }

    sendPort.send(null);
  }
}
