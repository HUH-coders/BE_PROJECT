import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha/Pages/Authentication/login.dart';
import 'package:suraksha/Services/auth.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_share/flutter_share.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool switchValue = false;
  Future<int> checkPIN() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int pin = (prefs.getInt('pin') ?? -1111);
    print('User $pin .');
    return pin;
  }

  @override
  void initState() {
    super.initState();
    checkService();
  }

  Future<void> share() async {
    await FlutterShare.share(
        title: 'App share',
        text: 'Share our app',
        linkUrl: 'https://www.google.com/',
        chooserTitle: 'Example Chooser Title');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          "Settings",
          style: TextStyle(
              fontSize: 25, fontWeight: FontWeight.w500, color: Colors.black),
        ),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: ListView(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  "About Us",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Expanded(child: Divider())
            ],
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: Center(
                  child: Image.asset(
                "assets/suraksha-logo.png",
                height: 40,
              )),
            ),
            title: Text("Suraksha"),
            subtitle: Text("Your safety in your hands"),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              "Suraksha is developed to help women in times of distress though men can use it too. It assures safety with various trigger generation techniques like shake detection, lock key press and using audio monitoring to detect trigger words like ‘Help’ and ‘Bachao’. After alert generation, different actions like periodic location tracking, background video recording and sending it to all the emergency contacts is performed.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Application",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Expanded(child: Divider())
            ],
          ),
          GestureDetector(
            onTap: () {
              share();
            },
            child: ListTile(
              title: Text("Share"),
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Center(child: Icon(Icons.share)),
              ),
            ),
          ),
          GestureDetector(
              onTap: () {
                Workmanager().cancelByTag("3");
                Workmanager().cancelByTag("4");
                Fluttertoast.showToast(msg: "Alerts Canceled");
              },
              child: ListTile(
                  title: Text("Stop Alerts"),
                  leading: CircleAvatar(
                      backgroundColor: Colors.grey[200],
                      child: Center(
                          child: Icon(
                        Icons.do_not_disturb_off,
                        size: 24,
                      ))))),
          GestureDetector(
            onTap: () {
              AuthenticationController ac = new AuthenticationController();
              ac.logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const LoginPage()));
            },
            child: ListTile(
              title: Text("Logout"),
              leading: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: Center(
                    child: Icon(
                  Icons.logout,
                  size: 24,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> checkService() async {
    bool running = await FlutterBackgroundService().isServiceRunning();
    setState(() {
      switchValue = running;
    });

    return running;
  }
}
