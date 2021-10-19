import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveSafe extends StatelessWidget {
  const LiveSafe({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: MediaQuery.of(context).size.width,
      child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: const [
            LiveSafeCard(
                imageName: "assets/police-badge.png",
                query: "Police Stations near me",
                title: "Police Stations"),
            LiveSafeCard(
                imageName: "assets/hospital.png",
                query: "Hospitals near me",
                title: "Hospitals"),
            LiveSafeCard(
                imageName: "assets/pharmacy.png",
                query: "Phramacies near me",
                title: "Phramacies"),
            LiveSafeCard(
                imageName: "assets/bus-stop.png",
                query: "Bus Stations near me",
                title: "Bus Stations"),
          ]),
    );
  }
}

class LiveSafeCard extends StatelessWidget {
  final String imageName;
  final String title;
  final String query;

  const LiveSafeCard(
      {Key? key,
      required this.imageName,
      required this.query,
      required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: [
          Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: InkWell(
              onTap: () {
                openMap(query);
              },
              child: SizedBox(
                  height: 50,
                  width: 50,
                  child: Center(
                      child: Image.asset(
                    imageName,
                    height: 32,
                  ))),
            ),
          ),
          Text(title)
        ],
      ),
    );
  }

  static Future<void> openMap(String location) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$location';
    try {
      await launch(googleUrl);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Something went wrong! Call emergency numbers.");
    }
  }
}
