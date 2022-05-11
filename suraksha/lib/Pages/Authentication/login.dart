import 'package:flutter/material.dart';
import 'package:suraksha/Pages/Dashboard/dashboard.dart';
import 'package:suraksha/Services/auth.dart';
import 'signup.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController password = TextEditingController();
  TextEditingController email = TextEditingController();
  bool passflag = true;
  Widget _snackbar = Container();
  final snackBar = SnackBar(content: const Text('Yay! A SnackBar!'));
  AuthenticationController ac = new AuthenticationController();
  Map fieldKeys = {
    'email': GlobalKey<FormFieldState>(),
    'password': GlobalKey<FormFieldState>(),
  };

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
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
                              fit: BoxFit.fill))),
                  Padding(
                      padding: const EdgeInsets.all(25.0),
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
                            child: Column(children: <Widget>[
                              Container(child: _snackbar),
                              Container(
                                  height: 60,
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: const BoxDecoration(
                                      border: Border(
                                          bottom:
                                              BorderSide(color: Colors.grey))),
                                  child: TextFormField(
                                    key: fieldKeys["email"],
                                    controller: email,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Email",
                                        suffixIcon: const Icon(Icons.email),
                                        hintStyle:
                                            TextStyle(color: Colors.grey[400])),
                                    validator: (value) {
                                      return value == null || value.isEmpty
                                          ? 'Email cannot be empty!'
                                          : null;
                                    },
                                    onChanged: (value) {
                                      fieldKeys['email']
                                          .currentState!
                                          .validate();
                                    },
                                  )),
                              Container(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    key: fieldKeys["password"],
                                    controller: password,
                                    obscureText: passflag,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Password",
                                        suffixIcon: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                passflag = !passflag;
                                              });
                                            },
                                            child: passflag
                                                ? const Icon(
                                                    Icons.visibility_off)
                                                : const Icon(Icons.visibility)),
                                        hintStyle:
                                            TextStyle(color: Colors.grey[400])),
                                    validator: (value) {
                                      return value == null || value.isEmpty
                                          ? 'Password cannot be empty!'
                                          : null;
                                    },
                                    onChanged: (value) {
                                      fieldKeys["password"]
                                          .currentState!
                                          .validate();
                                    },
                                  ))
                            ])),
                        const SizedBox(height: 30),
                        GestureDetector(
                          onTap: () async {
                            if (_formKey.currentState!.validate()) {
                              Map result =
                                  await ac.login(email.text, password.text);
                              if (result["flag"]) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Dashboard()));
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const Dashboard()));
                              } else {
                                Fluttertoast.showToast(
                                  msg: result["message"],
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                );
                              }
                            }
                          },
                          child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: const LinearGradient(colors: [
                                    Color.fromRGBO(143, 148, 251, 1),
                                    Color.fromRGBO(143, 148, 251, .6)
                                  ])),
                              child: const Center(
                                  child: Text(
                                "LOGIN",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ))),
                        ),
                        const SizedBox(height: 30),
                        const Text("Forgot Password?",
                            style: TextStyle(
                                color: Color.fromRGBO(143, 148, 251, 1))),
                        const SizedBox(height: 20.0),
                        GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const SignUpPage()));
                            },
                            child: const Text('Don\'t have an account? SignUp',
                                style: TextStyle(
                                    color: Color.fromRGBO(143, 148, 251, 1)))),
                      ]))
                ]))));
  }
}
