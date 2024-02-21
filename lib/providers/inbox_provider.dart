import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InboxProvider extends ChangeNotifier {
  Stream<List<Map<String, dynamic>>> getUsersFromFirestore() {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Return a stream of snapshots from the 'users' collection
      return firestore.collection('users').snapshots().map((querySnapshot) {
        // Convert each document snapshot to a Map
        return querySnapshot.docs.map((docSnapshot) {
          return docSnapshot.data();
        }).toList();
      });
    } catch (e) {
      print('Error retrieving users from Firestore: $e');
      // Return an empty stream in case of an error
      return Stream.empty();
    }
  }
}
