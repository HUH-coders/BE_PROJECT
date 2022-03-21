import 'dart:async';
import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:suraksha/Pages/Contacts/mycontacts.dart';
import 'package:suraksha/Pages/Dashboard/dashboard.dart';
import 'package:suraksha/Pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shake/shake.dart';
import 'package:telephony/telephony.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'Services/GenerateAlert.dart';
// import 'package:volume_watcher/volume_watcher.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeService();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail');
  if (email == null || email == '') {
    prefs.setBool('isLoggedIn', false);
    prefs.setString('userEmail', '');
  }
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  runApp(MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    List contacts = inputData!['contacts'];
    final prefs = await SharedPreferences.getInstance();
    List<String>? location = prefs.getStringList("location");
    String a = location![0];
    String b = location[1];
    String link = "http://maps.google.com/?q=${a},${b}";
    for (String contact in contacts) {
      Telephony.backgroundInstance.sendSms(
          to: contact, message: "I am on my way! Track me here.\n$link");
    }
    return true;
  });
}

const simplePeriodicTask = "simplePeriodicTask";

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
void onIosBackground() {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');
}

Future<void> onStart() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  service.onDataReceived.listen((event) async {
    if (event!["action"] == "setAsForeground") {
      service.setForegroundMode(true);
      return;
    }
    if (event["action"] == "setAsBackground") {
      service.setForegroundMode(false);
    }
    if (event["action"] == "stopService") {
      service.stopBackgroundService();
    }
  });
  Location _location;

  await BackgroundLocation.setAndroidNotification(
    title: "Location tracking is running in the background!",
    message: "You can turn it off from settings menu inside the app",
    icon: '@mipmap/ic_logo',
  );
  BackgroundLocation.startLocationService(
    distanceFilter: 20,
  );

  BackgroundLocation.getLocationUpdates((location) {
    print(location);
    _location = location;
    prefs.setStringList("location",
        [location.latitude.toString(), location.longitude.toString()]);
  });
  String screenShake = "Be strong, We are with you!";
  ShakeDetector.autoStart(
      shakeThresholdGravity: 7,
      onPhoneShake: () async {
        print("Test");
      });
  print("Nothing");
  // bring to foreground
  service.setForegroundMode(true);
  Timer.periodic(Duration(seconds: 1), (timer) async {
    if (!(await service.isServiceRunning())) timer.cancel();

    service.setNotificationInfo(
      title: "Safe Shake activated!",
      content: screenShake,
    );

    service.sendData(
      {"current_date": DateTime.now().toIso8601String()},
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? email;
  double currentvol = 0.5;
  int keyPressCount = 0;
  getEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('userEmail');
    });
  }

  @override
  void initState() {
    super.initState();
    getEmail();
    ShakeDetector _ = ShakeDetector.autoStart(onPhoneShake: () {
      print("SHAKE DETECTOR");
    });
    Future.delayed(Duration.zero, () async {
      currentvol = await PerfectVolumeControl.getVolume();
    });
    PerfectVolumeControl.stream.listen((volume) {
      //volume button is pressed,
      // this listener will be triggeret 3 times at one button press

      if (volume != currentvol) {
        //only execute button type check once time
        //  if(volume > currentvol){ //if new volume is greater, then it up button
        //     buttontype = "up";
        //  }else{ //else it is down button
        //     buttontype = "down";
        //  }
        print("\n\n Volume key pressed\n\n");
        // print("volume:");
        // print(volume);
        keyPressCount++;
        print(keyPressCount);
        if (keyPressCount == 3) {
          print("alert generated");
          keyPressCount = 0;
          generateAlert();
        }
      }

      setState(() {
        if (volume == 0.0 || volume == 1.0) {
          PerfectVolumeControl.setVolume(0.5);
          currentvol = 0.5;
        } else {
          currentvol = volume;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Suraksha - Women Safety App',
        theme: ThemeData(
          // fontFamily: GoogleFonts.poppins().fontFamily,
          primarySwatch: Colors.blue,
        ),
        home: email != null && email != '' ? Dashboard() : Splash());
  }
}
