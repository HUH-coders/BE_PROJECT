import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:suraksha/Pages/Dashboard/dashboard.dart';
import 'package:suraksha/Pages/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shake/shake.dart';
import 'package:suraksha/Services/GenerateAlert.dart';
import 'package:telephony/telephony.dart';
import 'package:tflite_audio/tflite_audio.dart';
import 'package:workmanager/workmanager.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:system_alert_window/system_alert_window.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';

// import 'package:mailer/mailer.dart';
// import 'package:mailer/smtp_server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeService();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail');
  if (email == null || email == '') {
    prefs.setBool('isLoggedIn', false);
    prefs.setString('userEmail', '');
    prefs.setBool('alertFlag', true);
    prefs.setBool("showManual", false);
  }

  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  await AndroidAlarmManager.initialize();

  runApp(MyApp());
  print("heyya");
  // if (email != null) {
  //   await AndroidAlarmManager.periodic(
  //       const Duration(seconds: 15), 0, fetchLocation);
  // }

  TfliteAudio.loadModel(
      model: 'assets/Rakshak_model.tflite',
      label: 'assets/Rakshak_model_labels.txt',
      inputType: 'decodedWav');
}

void fetchLocation() async {
  print("here");
  Position _locationData = await Geolocator.getCurrentPosition();

  String a = _locationData.latitude.toString();
  String b = _locationData.longitude.toString();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList('location', [a, b]);
  print(a + "\t" + b);
}

void callBack(String tag) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (tag == "cancel_alert") {
    print(tag);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('alertFlag', false);
    SystemAlertWindow.closeSystemWindow(prefMode: SystemWindowPrefMode.OVERLAY);
  }
}

// void sendLocation(email, location) async {
//   String username = 'autoemailtesting12@gmail.com';
//   String password = 'email@1234';
//   final smtpServer = gmail(username, password);
//   final equivalentMessage = Message()
//     ..from = Address(username, 'Suraksha')
//     ..recipients.add(Address(email))
//     // ..ccRecipients.addAll([Address('urvi.bheda@somaiya.edu'), 'himali.saini@somaiya.edu'])
//     // ..bccRecipients.add('bccAddress@example.com')
//     ..subject = 'Alert Generated ${DateTime.now()}'
//     ..text = 'This is the plain text.\nThis is line 2 of the text part.'
//     ..html = "<h1>Alert generated</h1>\n\n<p>See location Here: $location </p>";
// }

const simplePeriodicTask = "sendLocation";
const sendVideo = "sendVideo";
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simplePeriodicTask:
        await sendLocationMessage(inputData!['contacts']);
        return true;
      case sendVideo:
        await Telephony.instance.requestSmsPermissions;
        List contacts = inputData!['contacts'];
        String link = inputData['link'];
        sendVideoMessage(contacts, link);
        return true;
    }
    return Future.value(true);
  });
}

Future<void> sendLocationMessage(contacts) async {
  print("heyyyyayayyayyaayyay");
  Position _locationData = await Geolocator.getCurrentPosition();
  print("hshsh");
  print(_locationData);

  String a = _locationData.latitude.toString();
  String b = _locationData.longitude.toString();

  print(a + b);
  String link = "http://maps.google.com/?q=$a,$b";
  for (String contact in contacts) {
    print(contact);
    Telephony.backgroundInstance
        .sendSms(to: contact, message: "I am on my way! Track me here.\n$link");
  }
}

Future<void> sendVideoMessage(contacts, link) async {
  for (String contact in contacts) {
    print(contact);
    try {
      await Telephony.backgroundInstance.sendSms(
        to: contact,
        message: "Check Video Recording here.\n$link",
      );
      print("message sent");
    } catch (e) {
      print(e);
      print("message not sent");
    }
  }
}

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

  // SharedPreferences prefs = await SharedPreferences.getInstance();

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

  // await BackgroundLocation.setAndroidNotification(
  //   title: "Location tracking is running in the background!",
  //   message: "You can turn it off from settings menu inside the app",
  //   icon: '@mipmap/ic_logo',
  // );
  // BackgroundLocation.startLocationService(
  //   distanceFilter: 20,
  // );

  // BackgroundLocation.getLocationUpdates((location) {
  //   print(location);
  //   prefs.setStringList("location",
  //       [location.latitude.toString(), location.longitude.toString()]);
  // });
  String screenShake = "Be strong, We are with you!";
  ShakeDetector.autoStart(
      shakeThresholdGravity: 8,
      shakeSlopTimeMS: 500,
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
    _requestPermissions();
    SystemAlertWindow.registerOnClickListener(callBack);
    getEmail();
    ShakeDetector _ = ShakeDetector.autoStart(
        shakeThresholdGravity: 8,
        shakeSlopTimeMS: 500,
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
        print("\n\n Volume key pressed\n\n");
        keyPressCount++;
        print(keyPressCount);
        if (keyPressCount == 3) {
          print("alert generated");
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

    _counter = 10;
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        _counter--;
      } else {
        _timer!.cancel();
        SystemAlertWindow.closeSystemWindow(
            prefMode: SystemWindowPrefMode.OVERLAY);
        bool? alertFlag = prefs.getBool('alertFlag');
        print(alertFlag);
        if (alertFlag == true) {
          print("Generating Alert");
          generateAlert();
        } else {
          print("alert not Generated");
          prefs.setBool('alertFlag', true);
        }
      }
    });
  }

  Future<void> _requestPermissions() async {
    await SystemAlertWindow.requestPermissions(
        prefMode: SystemWindowPrefMode.OVERLAY);
    // LocationPermission permission = await Geolocator.checkPermission();
    // print(permission);
    // permission = await Geolocator.requestPermission();
    // final Telephony telephony = Telephony.instance;
    // bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
    // print(permissionsGranted);
  }

  void _showOverlayWindow() {
    SystemWindowHeader header = SystemWindowHeader(
        title: SystemWindowText(
            text: "Cancel Alert", fontSize: 15, textColor: Colors.black45),
        padding: SystemWindowPadding.setSymmetricPadding(12, 12),
        buttonPosition: ButtonPosition.TRAILING);
    SystemWindowBody body = SystemWindowBody(
      rows: [
        EachRow(
          columns: [
            EachColumn(
              text: SystemWindowText(
                  text: 'Tap \"Cancel\" immediately to cancel the alert ',
                  fontSize: 12,
                  textColor: Colors.black45),
            )
          ],
          gravity: ContentGravity.CENTER,
        ),
      ],
      padding: SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
    );
    SystemWindowFooter footer = SystemWindowFooter(
        buttons: [
          SystemWindowButton(
            text: SystemWindowText(
                text: "Cancel Alert", fontSize: 12, textColor: Colors.white),
            tag: "cancel_alert",
            width: 0,
            padding:
                SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
            height: SystemWindowButton.WRAP_CONTENT,
            decoration: SystemWindowDecoration(
                startColor: Color.fromRGBO(250, 139, 97, 1),
                endColor: Color.fromRGBO(247, 28, 88, 1),
                borderWidth: 0,
                borderRadius: 30.0),
          )
        ],
        padding: SystemWindowPadding(left: 16, right: 16, bottom: 12),
        decoration: SystemWindowDecoration(startColor: Colors.white),
        buttonsPosition: ButtonPosition.CENTER);
    SystemAlertWindow.showSystemWindow(
        height: 230,
        header: header,
        body: body,
        footer: footer,
        margin: SystemWindowMargin(left: 8, right: 8, top: 200, bottom: 0),
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
