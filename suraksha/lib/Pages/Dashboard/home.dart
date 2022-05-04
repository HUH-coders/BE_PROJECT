import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:suraksha/Helpers/constants.dart';
import 'package:suraksha/Pages/Dashboard/widgets/carousel.dart';
import 'package:suraksha/Pages/Dashboard/widgets/emergency.dart';
import 'package:suraksha/Pages/Dashboard/widgets/livesafe.dart';
import 'package:suraksha/Pages/Dashboard/widgets/locationmonitoring.dart';
import 'package:suraksha/Pages/Dashboard/widgets/safehome.dart';
import 'package:suraksha/Pages/Settings/SettingsScreen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  GlobalKey _setting = GlobalKey();
  GlobalKey _quotes = GlobalKey();
  GlobalKey _emergency = GlobalKey();
  GlobalKey _livesafe = GlobalKey();
  GlobalKey _carousel = GlobalKey();
  bool manualFlag = false;

  showManual() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? val = prefs.getBool("showManual");
    if (val == null) {
      val = false;
    }
    setState(() {
      manualFlag = val!;
    });
    if (!manualFlag) {
      prefs.setBool("showManual", true);
    }
  }

  int quoteIndex = 0;
  @override
  void initState() {
    super.initState();
    showManual();
    // if (!manualFlag) {
    //   WidgetsBinding.instance!.addPostFrameCallback((_) =>
    //       ShowCaseWidget.of(context)?.startShowCase(
    //           [_emergency, _livesafe, _setting, _quotes, _carousel]));
    // }
    getRandomInt(false);
  }

  getRandomInt(fromClick) {
    Random rnd = Random();

    quoteIndex = rnd.nextInt(4);
    if (mounted && fromClick) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
            isThreeLine: true,
            title: Text(sweetSayings[quoteIndex][0],
                style: TextStyle(color: Colors.grey[600])),
            subtitle: Showcase(
              key: _quotes,
              title: 'Quotes',
              description: 'Click here to see new Quotes',
              child: GestureDetector(
                onTap: () {
                  getRandomInt(true);
                },
                child: Text(sweetSayings[quoteIndex][1],
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)),
              ),
            ),
            leading: GestureDetector(
              onTap: () {
                ShowCaseWidget.of(context)?.startShowCase(
                    [_emergency, _livesafe, _setting, _quotes, _carousel]);
              },
              child: Card(
                  elevation: 4,
                  shape: const CircleBorder(),
                  child: InkWell(
                    child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(Icons.help)),
                  )),
            ),
            trailing: Showcase(
              key: _setting,
              title: 'Settings',
              description: 'Click here to change App settings',
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SettingsScreen()));
                },
                child: Card(
                    elevation: 4,
                    shape: const CircleBorder(),
                    child: InkWell(
                      child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child:
                              Image.asset("assets/settings.png", height: 24)),
                    )),
              ),
            )),
        Expanded(
          child: SizedBox(
            height: 100,
            child: ListView(
              shrinkWrap: true,
              children: [
                SafeCarousel(keyList: [_carousel]),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                              padding: EdgeInsets.only(
                                  left: 8.0, right: 8.0, bottom: 8.0),
                              child: Text("Emergency",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20))),
                          TextButton(
                              onPressed: () {}, child: const Text("See More"))
                        ])),
                Emergency(keyList: [_emergency]),
                const Padding(
                    padding: EdgeInsets.only(left: 16.0, bottom: 10, top: 10),
                    child: Text("Explore LiveSafe",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20))),
                LiveSafe(keyList: [_livesafe]),
                LocationMonitoring(),
                SafeHome(),
                const SizedBox(height: 50)
              ],
            ),
          ),
        ),
      ],
    );
  }
}
