import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:suraksha/Helpers/overlay.dart';
import 'package:suraksha/Pages/Dashboard/dashboard.dart';
import 'package:suraksha/Pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shake/shake.dart';
import 'package:suraksha/Services/GenerateAlert.dart';
import 'package:telephony/telephony.dart';
import 'package:workmanager/workmanager.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:showcaseview/showcaseview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeService();
  await Firebase.initializeApp();
  await setVariables();

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  runApp(MyApp());
}

Future<Position> getLocation() async {
  LocationPermission permission;
  bool _ = await Geolocator.isLocationServiceEnabled();
  permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  Position _locationData = await Geolocator.getCurrentPosition();
  return _locationData;
}

Future<void> setVariables() async {
  Position _locationData = await getLocation();

  String a = _locationData.latitude.toString();
  String b = _locationData.longitude.toString();

  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? email = prefs.getString('userEmail');
  if (email == null || email == '') {
    await prefs.setBool('isLoggedIn', false);
    await prefs.setString('userEmail', '');
    await prefs.setBool('alertFlag', true);
    await prefs.setBool("showManual", false);
    await prefs.setBool("locationMonitoring", false);
    await prefs.setBool("getHomeSafe", false);
  }
  await prefs.setStringList('location', [a, b]);
}

Future<void> callBack(String tag) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (tag == "cancel_alert") {
    print(tag);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('alertFlag', false);
    print(prefs.getBool('alertFlag'));
    SystemAlertWindow.closeSystemWindow(prefMode: SystemWindowPrefMode.OVERLAY);
  }
}

const simplePeriodicTask = "sendLocation";
const sendVideo = "sendVideo";
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simplePeriodicTask:
        await sendLocationMessage(inputData!['contacts']);
        return true;
      case sendVideo:
        List contacts = inputData!['contacts'];
        String link = inputData['link'];
        sendVideoMessage(contacts, link);
        return true;
    }
    return Future.value(true);
  });
}

Future<void> sendLocationMessage(contacts) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String>? _locationData = prefs.getStringList('location');
  String a = _locationData![0];
  String b = _locationData[1];

  String link = "http://maps.google.com/?q=$a,$b";
  for (String contact in contacts) {
    Telephony.backgroundInstance
        .sendSms(to: contact, message: "I am on my way! Track me here.\n$link");
  }
}

Future<void> sendVideoMessage(contacts, link) async {
  for (String contact in contacts) {
    Telephony.backgroundInstance.sendSms(
      to: contact,
      message: "Check Video Recording here.\n$link",
    );
    print("message sent");
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

void onIosBackground() {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');
}

Future<void> onStart() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = FlutterBackgroundService();

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

  String screenShake = "Be strong, We are with you!";

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
    _requestPermissions();
    SystemAlertWindow.registerOnClickListener(callBack);
    getEmail();
    ShakeDetector _ = ShakeDetector.autoStart(
        shakeSlopTimeMS: 500,
        shakeCountResetTime: 3000,
        shakeThresholdGravity: 6,
        onPhoneShake: () {
          print("SHAKE DETECTOR");
          _startTimer();
          _showOverlayWindow();
        });
    Future.delayed(Duration.zero, () async {
      currentvol = await PerfectVolumeControl.getVolume();
    });
    PerfectVolumeControl.stream.listen((volume) {
      if (volume != currentvol) {
        keyPressCount++;
        print(keyPressCount);
        if (keyPressCount == 3) {
          // print("alert generated");
          keyPressCount = 0;
          _startTimer();
          _showOverlayWindow();
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

  int _counter = 0;
  Timer? _timer;

  Future<void> _startTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _counter = 15;
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_counter > 0) {
        _counter--;
      } else {
        _timer!.cancel();
        SystemAlertWindow.closeSystemWindow(
            prefMode: SystemWindowPrefMode.OVERLAY);
        bool? alertFlag = prefs.getBool('alertFlag');
        if (alertFlag == true) {
          print("Generating Alert");
          generateAlert();
        } else {
          print("alert not Generated");
          await prefs.setBool('alertFlag', true);
        }
      }
    });
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
    await Permission.sms.request();
    await Permission.location.request();
    await Permission.microphone.request();
    await Permission.phone.request();
    await SystemAlertWindow.requestPermissions(
        prefMode: SystemWindowPrefMode.OVERLAY);
  }

  void _showOverlayWindow() {
    SystemAlertWindow.showSystemWindow(
        height: 230,
        header: overlayheader,
        body: overlaybody,
        footer: overlaayfooter,
        margin: SystemWindowMargin(left: 10, right: 10, top: 200, bottom: 0),
        gravity: SystemWindowGravity.TOP,
        prefMode: SystemWindowPrefMode.OVERLAY);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Suraksha - Women Safety App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: email != null && email != ''
            ? ShowCaseWidget(
                builder: Builder(builder: (context) => Dashboard()),
              )
            : Splash());
  }
}
