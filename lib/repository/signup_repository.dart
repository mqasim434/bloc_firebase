import 'package:bloc_firebase/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupRepository{
  static Future<void> signupUser(UserModel user)async {
    print("Function Called");
    final _db = FirebaseFirestore.instance;
    await _db.collection("Users").add(user.toJson());
  }
}