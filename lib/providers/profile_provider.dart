import 'dart:io';

import 'package:bloc_firebase/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfileProvider extends ChangeNotifier {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Stream<UserModel> getUserProfile(String email){
    return firebaseFirestore.collection('users').where('email',isEqualTo: email).snapshots().map((snapshot){
      if(snapshot.docs.isEmpty){
        return UserModel();
      }
      else{
        return UserModel.fromJson(snapshot.docs.first.data());
      }
    });
  }

  void pickImage(String source,String email)async{
    ImagePicker imagePicker = ImagePicker();

    XFile? pickedImage;
    String? _imageUrl;
    if(source=='camera'){
      pickedImage = await imagePicker.pickImage(source: ImageSource.camera);
    }
    else{
      pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    }

    firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('images')
        .child(email)
        .child('image_${DateTime.now().millisecondsSinceEpoch}.jpg');

    try {
      await ref.putFile(File(pickedImage!.path.toString()));
      String imageUrl = await ref.getDownloadURL();
      _imageUrl = imageUrl;
      notifyListeners();
      updateData('imageUrl',_imageUrl.toString() ,email);
      print('Image uploaded successfully: $_imageUrl');
    } catch (e) {
      print('Error uploading image: $e');
    }

  }

  void updateData(String field,String data ,String email) async {
    var querySnapshot = await firebaseFirestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    print(field);
    for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot
        in querySnapshot.docs) {
      // Update the specified field in each document
      await docSnapshot.reference.update({field: data});
      print('Field $field updated successfully for email: $email');
    }
  }
}
