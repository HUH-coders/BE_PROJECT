import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:suraksha/Helpers/constants.dart';
import 'package:suraksha/Pages/Settings/SettingsScreen.dart';

class DashAppbar extends StatelessWidget {
  final Function getRandomInt;
  final int quoteIndex;
  final List<GlobalKey> keyList;
  const DashAppbar(
      {Key? key,
      required this.getRandomInt,
      required this.quoteIndex,
      required this.keyList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        isThreeLine: true,
        title: Text(sweetSayings[quoteIndex][0],
            style: TextStyle(color: Colors.grey[600])),
        subtitle: Showcase(
          key: keyList[0],
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
                    child: Icon(Icons.help)),
              )),
        ),
        trailing: Showcase(
          key: keyList[1],
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
                      child: Image.asset("assets/settings.png", height: 24)),
                )),
          ),
        ));
  }
}
