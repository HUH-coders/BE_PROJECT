import 'package:flutter/material.dart';
import 'login.dart';
import 'package:suraksha/Helpers/validation.dart';
import 'package:suraksha/Services/auth.dart';
import 'package:suraksha/Models/EmergencyContact.dart';
import 'package:suraksha/Models/User.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late String name, email, phone, emergencyName, emergencyEmail, emergencyPhone;
  AuthenticationController ac = new AuthenticationController();
  //TextController to read text entered in text field
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  Container(
                    height: 400,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/signup.png'),
                            fit: BoxFit.fill)),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color.fromRGBO(143, 148, 251, .2),
                                    blurRadius: 20.0,
                                    offset: Offset(0, 10))
                              ]),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey))),
                                child: TextFormField(
                                  controller: password,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Name",
                                      suffixIcon:
                                          const Icon(Icons.visibility_off),
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    if (value != null) name = value;
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey))),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Email",
                                      suffixIcon: const Icon(Icons.email),
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter email';
                                    }
                                    if (!isEmail(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    if (value != null) email = value;
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey))),
                                child: TextFormField(
                                  controller: password,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Password",
                                      suffixIcon:
                                          const Icon(Icons.visibility_off),
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter password';
                                    }
                                    if (!checkLength(value)) {
                                      return 'Password length should be atleast 8 characters!';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey))),
                                child: TextFormField(
                                  controller: confirmpassword,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Confirm Password",
                                      suffixIcon:
                                          const Icon(Icons.visibility_off),
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter password again';
                                    }
                                    if (!checkLength(value)) {
                                      return 'Password length should be atleast 8 characters!';
                                    }
                                    if (!passwordsMatch(password.text, value)) {
                                      return 'Password does not match';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        bottom:
                                            BorderSide(color: Colors.grey))),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Phone number",
                                      suffixIcon:
                                          const Icon(Icons.phone_android),
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter phone number';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    if (value != null) phone = value;
                                  },
                                ),
                              ),
                              Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom:
                                              BorderSide(color: Colors.grey))),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText:
                                            "Emergency Contact Person Name",
                                        suffixIcon: const Icon(Icons.person),
                                        hintStyle:
                                            TextStyle(color: Colors.grey[400])),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter name';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      if (value != null) emergencyName = value;
                                    },
                                  )),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText:
                                          "Emergency Contact Phone number",
                                      suffixIcon:
                                          const Icon(Icons.phone_android),
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter phone number';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    if (value != null) emergencyPhone = value;
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Emergency Contact Email",
                                      suffixIcon:
                                          const Icon(Icons.phone_android),
                                      hintStyle:
                                          TextStyle(color: Colors.grey[400])),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter email';
                                    }
                                    if (!isEmail(value)) {
                                      return 'Enter valid email';
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    if (value != null) emergencyEmail = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () async {
                            if (await ac.signup(User(
                                name: name,
                                email: email,
                                password: password.text,
                                phone: phone,
                                contacts: [
                                  EmergencyContact(
                                      email: emergencyEmail,
                                      name: emergencyName,
                                      phoneno: emergencyPhone)
                                ]))) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()));
                            }
                          },
                          child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(colors: [
                                    Color.fromRGBO(143, 148, 251, 1),
                                    Color.fromRGBO(143, 148, 251, .6),
                                  ])),
                              child: const Center(
                                  child: Text("SIGNUP",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)))),
                        ),
                        const SizedBox(height: 20.0),
                        GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()));
                            },
                            child: const Text('Already have an account? Login',
                                style: TextStyle(
                                    color: Color.fromRGBO(143, 148, 251, 1))))
                      ]))
                ]))));
  }
}