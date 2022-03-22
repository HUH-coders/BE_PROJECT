import 'dart:async';
import 'package:background_location/background_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:permission_handler/permission_handler.dart';
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
  }
  Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );
  runApp(MyApp());
}

// class AlertVariable {
//   static bool alertFlag = true;
// }

void callBack(String tag) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (tag == "cancel_alert") {
    print(tag);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('alertFlag', false);
    SystemAlertWindow.closeSystemWindow(prefMode: SystemWindowPrefMode.OVERLAY);
  }
}

const simplePeriodicTask = "simplePeriodicTask";
const sendVideo = "sendVideo";
void callbackDispatcher() {
      print("hello world");
  Workmanager().executeTask((task, inputData) async {
    print("\n\n\n $task \n\n\n");
    switch(task){
      case simplePeriodicTask:
        print("Inside 3..............\n\n\n\n");
        List contacts = inputData!['contacts'];
        final prefs = await SharedPreferences.getInstance();
        List<String>? location = prefs.getStringList("location");
        String a = location![0];
        String b = location[1];
        String link = "http://maps.google.com/?q=$a,$b";
        for (String contact in contacts) {
          Telephony.backgroundInstance.sendSms(
              to: contact, message: "I am on my way! Track me here.\n$link");
        }
        return true;
      case sendVideo:
      print("inside sendvideo\n\n");
      bool? permissionsGranted = await Telephony.instance.requestSmsPermissions;

        List contacts = inputData!['contacts'];
        String link = inputData['link'];
        final SmsSendStatusListener listener = (SendStatus status) {
    // Handle the status
                      print(status);
                      if(status=='SENT'){
                        print("yayya");
                      }
          };
        for (String contact in contacts) {
          print(contact);
          try{
            await Telephony.backgroundInstance.sendSms(
              to: contact, message: "Check Video Recording here.\n$link",
              statusListener: listener
);
              print("message sent");
          }catch(e){
            print(e);
            print("message not sent");
          }
        }
        return true;
    }
      return Future.value(true);
  });
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
    _requestPermissions();
    SystemAlertWindow.registerOnClickListener(callBack);
    getEmail();
    ShakeDetector _ = ShakeDetector.autoStart(onPhoneShake: () {
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
        home: email != null && email != '' ? Dashboard() : Splash());
  }
}
