import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:suraksha/Services/UserService.dart';

class AuthenticationController {
  String hashPassword(String pass) {
    var bytes = utf8.encode(pass); // data being hashed
    var encryptedS = sha256.convert(bytes);
    return encryptedS.toString();
  }

  Future<bool> checkIfUserExists(String email) async {
    User? user = await getUserData(email);
    return user == null ? false : true;
  }

  Future<Map> signup(User user) async {
    Map result = {'flag': false, 'message': ''};
    // check if the user exists
    if (await checkIfUserExists(user.email)) {
      result["message"] = "Email Already Exists!";
    } else {
      // hash the password
      user.password = hashPassword(user.password);

      // add user to database
      try {
        final CollectionReference userRef =
            FirebaseFirestore.instance.collection('user');
        await userRef.doc(user.email).set(user.toJson());
        result["flag"] = true;
        result["message"] = "Signup Successful!";
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setBool("showManual", false);
      } catch (e) {
        print(e);
        result["message"] = 'Please try again later!';
      }
    }

    return result;
  }

  Future<Map> login(String email, String password) async {
    Map result = {'flag': false, 'message': ''};
    try {
      User? user = await getUserData(email);
      if (user != null) {
        if (user.password == hashPassword(password)) {
          result["flag"] = true;
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setBool('isLoggedIn', true);
          prefs.setString('userEmail', user.email);
        } else {
          result["message"] = 'Please enter correct password.';
        }
      } else {
        result["message"] = 'You don\'t have an account. Please Sign Up!';
      }
    } catch (e) {
      print(e);
      result["message"] = 'Please try again later!';
    }
    return result;
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    prefs.setString('userEmail', '');
  }
}
