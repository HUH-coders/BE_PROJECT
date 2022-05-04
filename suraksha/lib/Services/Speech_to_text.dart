// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_recognition_result.dart';
// import 'package:speech_to_text/speech_to_text.dart';

// class SpeechRecognition extends StatefulWidget {
//   SpeechRecognition({Key? key}) : super(key: key);

//   @override
//   _SpeechRecognitionState createState() => _SpeechRecognitionState();
// }

// class _SpeechRecognitionState extends State<SpeechRecognition> {
//   SpeechToText _speechToText = SpeechToText();
//   bool _speechEnabled = false;
//   String _lastWords = '';
//   bool _isListening = false;

//   @override
//   void initState() {
//     super.initState();
//     _initSpeech();
//   }

//   void _initSpeech() async {
//     _speechEnabled = await _speechToText.initialize();
//     setState(() {});
//   }

//   void _startListening() async {
//     await _speechToText.listen(onResult: _onSpeechResult);
//     setState(() {
//       _isListening = true;
//     });
//   }

//   void _stopListening() async {
//     await _speechToText.stop();
//     setState(() {
//       _isListening = false;
//     });
//   }

//   /// This is the callback that the SpeechToText plugin calls when
//   /// the platform returns recognized words.
//   void _onSpeechResult(SpeechRecognitionResult result) {
//     setState(() {
//       _lastWords = result.recognizedWords;
//     });
//     List<String> ls = _lastWords.split(" ");
//     if (ls.contains("help")) {
//       print("Trigger word found!!");
//     }
//     if (_isListening) {
//       _startListening();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Speech Demo'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Container(
//               padding: EdgeInsets.all(16),
//               child: Text(
//                 'Recognized words:',
//                 style: TextStyle(fontSize: 20.0),
//               ),
//             ),
//             Expanded(
//               child: Container(
//                 padding: EdgeInsets.all(16),
//                 child: Text(
//                   _speechToText.isListening
//                       ? '$_lastWords'
//                       : _speechEnabled
//                           ? 'Tap the microphone to start listening...'
//                           : 'Speech not available',
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           setState(() {
//             _isListening = !_isListening;
//           });
//           _speechToText.isNotListening ? _startListening() : _stopListening();
//         },
//         tooltip: 'Listen',
//         child: Icon(_speechToText.isListening ? Icons.mic : Icons.mic_off),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:background_stt/background_stt.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SpeechRecognition extends StatefulWidget {
  @override
  _SpeechRecognitionState createState() => _SpeechRecognitionState();
}

class _SpeechRecognitionState extends State<SpeechRecognition> {
  var _service = BackgroundStt();
  String result = "Say something!";
  var isListening = false;

  @override
  void initState() {
    _service.startSpeechListenService;

    setState(() {
      if (mounted) isListening = true;
    });

    _service.getSpeechResults().onData((data) {
      print("getSpeechResults: ${data.result} , ${data.isPartial} [STT Mode]");

      _doOnSpeechCommandMatch(data.result);

      setState(() {
        result = data.result!;
      });
    });

    super.initState();
  }

  void _doOnSpeechCommandMatch(String? command) {
    if (command == "help") {
      Fluttertoast.showToast(msg: "Spoke help");
    }
  }

  @override
  void dispose() {
    super.dispose();
    _service.stopSpeechListenService;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Background Speech-to-Text'),
        ),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('$result\n\n'),
              Visibility(
                child: RaisedButton(
                  child: Text("Pause Listening"),
                  onPressed: () async {
                    await _service.pauseListening();

                    setState(() {
                      result = "Speech listener Paused!";
                      isListening = false;
                    });
                  },
                ),
                replacement: RaisedButton(
                  child: Text("Resume Listening"),
                  onPressed: () async {
                    await _service.resumeListening();

                    setState(() {
                      result = "Speech listener Resumed!";
                      isListening = true;
                    });
                  },
                ),
                visible: isListening,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
