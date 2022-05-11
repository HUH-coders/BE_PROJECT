import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha/Models/EmergencyContact.dart';
import 'package:suraksha/Services/GenerateAlert.dart';
import 'package:suraksha/Services/UserService.dart';
import 'package:background_stt/background_stt.dart';

class SafeHome extends StatefulWidget {
  const SafeHome({Key? key}) : super(key: key);

  @override
  _SafeHomeState createState() => _SafeHomeState();
}

class _SafeHomeState extends State<SafeHome> {
  late String filePath;
  bool getHomeSafeActivated = false;
  List<String> numbers = [];
  bool _first = false;
  BackgroundStt? _service;
  String result = "Say something!";

  checkGetHomeActivated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      getHomeSafeActivated = prefs.getBool("getHomeSafe") ?? false;
    });
  }

  changeStateOfHomeSafe(value) async {
    if (value) {
      Fluttertoast.showToast(msg: "Safe Home Service Activated in Background!");
    } else {
      Fluttertoast.showToast(msg: "Safe Home Service Disabled!");
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      getHomeSafeActivated = value;
      prefs.setBool("getHomeSafe", value);
    });
  }

  @override
  void initState() {
    super.initState();
    checkGetHomeActivated();
  }

  void _doOnSpeechCommandMatch(String? command) async {
    if (command == "help" ||
        command == "bachao" ||
        command == "Help" ||
        command == "Bachao") {
      generateAlert();
      print("Alertt generated...");
      Fluttertoast.showToast(msg: "Spoke help");
      changeStateOfHomeSafe(false);
      await _service?.pauseListening();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _service?.stopSpeechListenService;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: InkWell(
        onTap: () {
          showModelSafeHome(getHomeSafeActivated);
        },
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            height: 180,
            width: MediaQuery.of(context).size.width * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ListTile(
                        title: Text("Get Home Safe"),
                        subtitle: Text(
                            "Monitor Audio Continuously \n\nRecommended in Highly Dangerous Area"),
                      ),
                      Visibility(
                        visible: getHomeSafeActivated,
                        child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Row(
                              children: [
                                SpinKitDoubleBounce(
                                  color: Colors.red,
                                  size: 15,
                                ),
                                SizedBox(width: 15),
                                Text("Currently Running...",
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 10)),
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/route.jpg",
                      height: 140,
                    ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  showModelSafeHome(bool processRunning) async {
    bool getHomeActivated = processRunning;
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        enableDrag: true,
        isScrollControlled: true,
        isDismissible: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height / 1.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Divider(
                          indent: 20,
                          endIndent: 20,
                        )),
                        Text("Get Home Safe"),
                        Expanded(
                            child: Divider(
                          indent: 20,
                          endIndent: 20,
                        )),
                      ],
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0xFFF5F4F6)),
                      child: SwitchListTile(
                        secondary: Lottie.asset("assets/routes.json"),
                        value: getHomeActivated,
                        onChanged: (val) async {
                          setModalState(() {
                            getHomeActivated = val;
                          });
                          if (!_first) {
                            setState(() {
                              _first = true;
                              _service = BackgroundStt();
                              _service?.startSpeechListenService;
                              _service?.getSpeechResults().onData((data) {
                                print(
                                    "getSpeechResults: ${data.result} , ${data.isPartial} [STT Mode]");

                                _doOnSpeechCommandMatch(data.result);

                                setState(() {
                                  result = data.result!;
                                });
                              });
                            });
                          } else {
                            if (getHomeActivated) {
                              changeStateOfHomeSafe(true);
                              print("Activated.........");
                              await _service?.resumeListening();
                            } else {
                              changeStateOfHomeSafe(false);
                              print("DEActivated.........");
                              await _service?.pauseListening();
                            }
                          }
                        },
                        subtitle: Text(
                            "Your location will be shared with all of your contacts every 15 minutes & your audio will be monitored"),
                      )),
                ],
              ),
            );
          });
        });
  }

  Future<List<String>> getSOSNumbers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('userEmail');
    List<EmergencyContact> contacts = await getUserContacts(email!);
    numbers = [];
    for (EmergencyContact i in contacts) {
      numbers.add(i.name + "***" + i.phoneno);
    }
    return numbers;
  }
}
