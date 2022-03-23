// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'dart:typed_data';
import 'package:background_location/background_location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha/Models/EmergencyContact.dart';
import 'package:suraksha/Services/UserService.dart';
import 'package:workmanager/workmanager.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class FirebaseApi {
  static UploadTask? uploadFile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putFile(file);
    } on FirebaseException catch (e) {
      return null;
    }
  }

  static UploadTask? uploadBytes(String destination, Uint8List data) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);

      return ref.putData(data);
    } on FirebaseException catch (e) {
      return null;
    }
  }
}


Future<void> sendLocationPeriodically() async {
  // String loc;
  // await BackgroundLocation.setAndroidNotification(
  //   title: "Location tracking is running in the background!",
  //   message: "You can turn it off from settings menu inside the app",
  //   icon: '@mipmap/ic_logo',
  // );
  BackgroundLocation.startLocationService(
    distanceFilter: 20,
  );

  BackgroundLocation.getLocationUpdates((location) {
    print(location);
    // loc = location;
    // prefs.setStringList("location",
    //     [location.latitude.toString(), location.longitude.toString()]);
  });



  List<String> emails = [];
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail');
  List<EmergencyContact> ecs = await getUserContacts(email!);
  for (EmergencyContact i in ecs) {
    emails.add(i.email);
  }
  // List<String>? location = prefs.getStringList("location");
  // print("location: $location");
  //       String a = location![0];
  //       String b = location[1];
  //       String link = "http://maps.google.com/?q=$a,$b";
  //       print(link);
  // for(email in emails){
  //   sendMail(email,link);
  // }
  // Workmanager().registerPeriodicTask("3", 'simplePeriodicTask',
  //     tag: "3",
  //     inputData: {"emails": emails},
  //     frequency: Duration(minutes: 15));
}

Future<void> sendVideo(link) async {
  List<String> contacts = [];
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail');
  List<EmergencyContact> ecs = await getUserContacts(email!);
  for (EmergencyContact i in ecs) {
    contacts.add(i.phoneno);
  }
  Workmanager().registerOneOffTask("4", 'sendVideo',
      tag: "4",
      inputData: {"contacts": contacts, "link":link},
  );
      // frequency: Duration(minutes: 15));
}

void sendMail(email,link) async {
print("inside send mail");
String username = 'autoemailtesting12@gmail.com';
String password = 'email@1234';
print(username);
print(password);
  final smtpServer = gmail(username, password);
  print(smtpServer);
  final equivalentMessage = Message()
  ..from = Address(username, 'Suraksha')
  ..recipients.add(Address(email))
  // ..ccRecipients.addAll([Address('urvi.bheda@somaiya.edu'), 'himali.saini@somaiya.edu'])
  // ..bccRecipients.add('bccAddress@example.com')
  ..subject = 'Alert Generated ${DateTime.now()}'
  ..text = 'This is the plain text.\nThis is line 2 of the text part.'
  ..html = "<h1>Alert generated</h1>\n\n<p>Track Here: ${link} </p>";

  await send(equivalentMessage, smtpServer);
  }

Future<void> backgroundVideoRecording() async {
  final cameras = await availableCameras();
  final front = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front);
  CameraController _cameraController =
      CameraController(front, ResolutionPreset.max);
  await _cameraController.initialize();
  await _cameraController.prepareForVideoRecording();
  await _cameraController.startVideoRecording();
  await Future.delayed(const Duration(seconds: 5), () {});
  print("120 secs Done");
  final file = await _cameraController.stopVideoRecording();
  print("\n\n\n");
  print(file.path);
  final File? video = File(file.path);
  uploadFile(video);
  await GallerySaver.saveVideo(file.path);
  // File(file.path).deleteSync();
  print("recording stopped");
}

  Future uploadFile(file) async {
    print("abcdddddddddddddddddddddddddd");
      UploadTask? task;
    if (file == null) return;

    final fileName = basename(file!.path);
    final destination = 'files/$fileName';

    task = FirebaseApi.uploadFile(destination, file!);
    // setState(() {});

    if (task == null) return;

    final snapshot = await task.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $urlDownload');
    // sendVideo(urlDownload);
    List<String> emails = [];
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail');
  List<EmergencyContact> ecs = await getUserContacts(email!);
  for (EmergencyContact i in ecs) {
    emails.add(i.email);
  }
  for(email in emails){
    sendMail(email,urlDownload);
  }
  }


Future<void> generateAlert() async {
  await sendLocationPeriodically();
  await backgroundVideoRecording();
}

