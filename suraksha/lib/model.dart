// import 'package:suraksha/Services/GenerateAlert.dart';
import 'package:tflite_audio/tflite_audio.dart';

void getResult(String filepath) {
  print(filepath);
  Stream<Map<dynamic, dynamic>> recognitionStream;

  String result = '';
  int inferenceTime = 0;

  print("yaha aaya");
  recognitionStream = TfliteAudio.startFileRecognition(
    sampleRate: 16000,
    audioDirectory: filepath,
  );

  print(recognitionStream);

  print("yaha aaya 2");
  recognitionStream.listen((event) {
    result = event["inferenceTime"];
    inferenceTime = event["recognitionResult"];
    print("heyy");
    print(result);
    print(inferenceTime);
    print(event);
  }).onDone(() => print("Yaha aaya 4"));
  print("yaha aaya 3");
}
