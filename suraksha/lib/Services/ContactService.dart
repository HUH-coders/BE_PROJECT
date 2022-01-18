import 'dart:async';
// import 'package:suraksha/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suraksha/Models/EmergencyContact.dart';
// import 'package:suraksha/Models/User.dart';
// import 'dart:convert';

Future<Map> addContact(EmergencyContact ec, String email) async {
  Map result = {'flag': false, 'message': ''};
  try {
    Map<dynamic, dynamic>? mp = ec.toJson();
    final CollectionReference userRef =
        FirebaseFirestore.instance.collection('user');
    await userRef.doc(email).update({
      "contacts": FieldValue.arrayUnion([mp])
    });
    result["flag"] = true;
    result["message"] = "Signup Successful!";
  } catch (e) {
    print(e);
    result["message"] = 'Please try again later!';
  }
  return result;
}

Future<Map> deleteContact(EmergencyContact ec, String email) async {
  Map result = {'flag': false, 'message': ''};

  return result;
}
