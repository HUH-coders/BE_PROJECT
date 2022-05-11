import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:suraksha/Models/EmergencyContact.dart';

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
    result["message"] = "Added Successful!";
  } catch (e) {
    print(e);
    result["message"] = 'Please try again later!';
  }
  return result;
}

Future<Map> deleteContact(EmergencyContact? ec, String email) async {
  Map result = {'flag': false, 'message': ''};
  try {
    Map<dynamic, dynamic>? mp = ec!.toJson();
    final CollectionReference userRef =
        FirebaseFirestore.instance.collection('user');
    await userRef.doc(email).update({
      "contacts": FieldValue.arrayRemove([mp])
    });
    result["flag"] = true;
    result["message"] = "Deleted Successful!";
  } catch (e) {
    print(e);
    result["message"] = 'Please try again later!';
  }
  return result;
}

Future<Map> updateContact(
    EmergencyContact ecNew, EmergencyContact ecPrev, String email) async {
  print(ecNew);
  print(ecPrev);
  Map result = {'flag': false, 'message': ''};
  try {
    Map<dynamic, dynamic>? mpNew = ecNew.toJson();
    Map<dynamic, dynamic>? mpPrev = ecPrev.toJson();
    final CollectionReference userRef =
        FirebaseFirestore.instance.collection('user');
    await userRef.doc(email).update({
      "contacts": FieldValue.arrayRemove([mpPrev])
    });
    await userRef.doc(email).update({
      "contacts": FieldValue.arrayUnion([mpNew])
    });
    result["flag"] = true;
    result["message"] = "Updated Successful!";
  } catch (e) {
    print(e);
    result["message"] = 'Please try again later!';
  }
  return result;
}
