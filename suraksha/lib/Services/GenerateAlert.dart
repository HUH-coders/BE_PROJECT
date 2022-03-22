import 'dart:io';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suraksha/Models/EmergencyContact.dart';
import 'package:suraksha/Services/UserService.dart';
import 'package:workmanager/workmanager.dart';
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';

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
  List<String> contacts = [];
  final prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('userEmail');
  List<EmergencyContact> ecs = await getUserContacts(email!);
  for (EmergencyContact i in ecs) {
    contacts.add(i.phoneno);
  }
  Workmanager().registerPeriodicTask("3", 'simplePeriodicTask',
      tag: "3",
      inputData: {"contacts": contacts},
      frequency: Duration(minutes: 15));
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

Future<void> backgroundVideoRecording() async {
  final cameras = await availableCameras();
  final front = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front);
  CameraController _cameraController =
      CameraController(front, ResolutionPreset.max);
  await _cameraController.initialize();
  await _cameraController.prepareForVideoRecording();
  await _cameraController.startVideoRecording();
  await Future.delayed(const Duration(seconds: 2), () {});
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
    sendVideo(urlDownload);
  }


Future<void> generateAlert() async {
  await sendLocationPeriodically();
  await backgroundVideoRecording();
}

