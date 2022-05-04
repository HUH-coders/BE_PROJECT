import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha/Services/GenerateAlert.dart';
import 'package:workmanager/workmanager.dart';

class LocationMonitoring extends StatefulWidget {
  const LocationMonitoring({Key? key}) : super(key: key);

  @override
  _LocationMonitoringState createState() => _LocationMonitoringState();
}

class _LocationMonitoringState extends State<LocationMonitoring> {
  bool locationMonitoringActivated = false;
  List<String> numbers = [];

  checkGetHomeActivated() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      locationMonitoringActivated =
          prefs.getBool("locationMonitoring") ?? false;
    });
  }

  changeStateOfHomeSafe(value) async {
    if (value) {
      Fluttertoast.showToast(msg: "Service Activated in Background!");
    } else {
      Fluttertoast.showToast(msg: "Service Disabled!");
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      locationMonitoringActivated = value;
      prefs.setBool("locationMonitoring", value);
    });
  }

  @override
  void initState() {
    super.initState();
    checkGetHomeActivated();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
        child: InkWell(
            onTap: () {
              showModelSafeHome(locationMonitoringActivated);
            },
            child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                    height: 180,
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                            ListTile(
                                title: Text("Location Monitoring"),
                                subtitle: Text("Share Location Periodically")),
                            Visibility(
                                visible: locationMonitoringActivated,
                                child: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: Row(children: [
                                      SpinKitDoubleBounce(
                                          color: Colors.red, size: 15),
                                      SizedBox(width: 15),
                                      Text("Currently Running...",
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 10))
                                    ])))
                          ])),
                      ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child:
                              Image.asset("assets/Location.png", height: 140))
                    ])))));
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
                        topRight: Radius.circular(30))),
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Row(children: [
                        Expanded(child: Divider(indent: 20, endIndent: 20)),
                        Text("Location Monitoring"),
                        Expanded(child: Divider(indent: 20, endIndent: 20))
                      ])),
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
                            if (getHomeActivated) {
                              changeStateOfHomeSafe(true);
                              sendLocationPeriodically();
                              // generateAlert();
                            } else {
                              changeStateOfHomeSafe(false);
                              await Workmanager().cancelByTag("3");
                            }
                          },
                          subtitle: Text(
                              "Your location will be shared with all of your contacts every 15 minutes")))
                ]));
          });
        });
  }
}
