import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:showcaseview/showcaseview.dart';

class Emergency extends StatelessWidget {
  final List<GlobalKey> keyList;
  const Emergency({Key? key, required this.keyList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 180,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: [
          SizedBox(width: 10),
          Showcase(
            title: "Emergency Helpline Numbers",
            description: 'Tap to call immediately',
            key: keyList[0],
            child: EmergencyCard(
                imageName: "assets/icons/alert.png",
                title: "Women Helpline",
                description: "Call 1-0-9-1 for emergencies.",
                number: "1 -0 -9 -1",
                callNum: "1091"),
          ),
          SizedBox(width: 10),
          EmergencyCard(
              imageName: "assets/ambulance.png",
              title: "Ambulance",
              description: "Any medical emergency",
              number: "1 -0 -2",
              callNum: "102"),
          SizedBox(width: 10),
          EmergencyCard(
              imageName: "assets/icons/alert.png",
              title: "Police",
              description: "Any crime related emergency",
              number: "1 -0 -0",
              callNum: "100"),
          SizedBox(width: 10),
          EmergencyCard(
              imageName: "assets/army.png",
              title: "Active Emergency",
              description: "National Counter Terrorism Authority",
              number: "1 -1 -2",
              callNum: "112"),
          SizedBox(width: 10),
        ],
      ),
    );
  }
}

class EmergencyCard extends StatelessWidget {
  final String imageName;
  final String title;
  final String description;
  final String number;
  final String callNum;

  const EmergencyCard(
      {Key? key,
      required this.imageName,
      required this.description,
      required this.number,
      required this.title,
      required this.callNum})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
                onTap: () {
                  _callNumber(number);
                },
                child: Container(
                    height: 180,
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.fromRGBO(143, 148, 251, 1),
                          Color.fromRGBO(143, 148, 251, .6)
                        ],
                      ),
                    ),
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                  backgroundColor:
                                      Colors.white.withOpacity(0.5),
                                  radius: 25,
                                  child: Center(
                                      child:
                                          Image.asset(imageName, height: 35))),
                              Text(title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24)),
                              Text(
                                description,
                                style: const TextStyle(color: Colors.white),
                              ),
                              Expanded(
                                  child: Container(
                                      height: 30,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(300)),
                                      child: Center(
                                          child: Text(number,
                                              style: TextStyle(
                                                  color: Colors.red[300],
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18)))))
                            ]))))));
  }
}

_callNumber(number) async {
  await FlutterPhoneDirectCaller.callNumber(number);
}
