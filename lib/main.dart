import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_piano_audio_detection/flutter_piano_audio_detection.dart';
import 'dart:async';
import 'answerList.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final isRecording = ValueNotifier<bool>(false);
  FlutterPianoAudioDetection fpad = new FlutterPianoAudioDetection();

  Stream<List<dynamic>>? result;
  List<String>? _allNotes;
  List<String>? _continuousNotes;

  static int _qNumber = 0;
  int _totalQuestoins = answerList.length;
  List<String> _answer = answerList[_qNumber];
  bool? isCorrect = false;

  @override
  void initState() {
    super.initState();
    fpad.prepare();
  }

  void start() async {
    fpad.start();
    getResult();
  }

  void stop() {
    fpad.stop();
  }

  void getResult() {
    Set<String> twoprev = {};
    Set<String> oneprev = {};
    Set<String> currentprev = {};

    result = fpad.startAudioRecognition();
    result!.listen((event) {
      setState(() {
        // get current notes
        _allNotes = fpad.getNotes(event);

        // pass notes to one previous set
        twoprev = oneprev;
        oneprev = currentprev;
        currentprev = _allNotes!.toSet();

        // continuousNotes are intersection of the three sets currentprev, oneprev and twoprev
        _continuousNotes =
            currentprev.intersection(oneprev.intersection(twoprev)).toList();

        // judge whether _continuousNotes is equal to the correct answer
        isCorrect =
            _answer.toSet().difference(_continuousNotes!.toSet()).isEmpty &&
                _continuousNotes!.toSet().difference(_answer.toSet()).isEmpty;

        // check playing correct notes
        if (isCorrect!) {
          if (_qNumber != _totalQuestoins - 1) {
            _qNumber++;
          } else {
            _qNumber = 0;
          }
          _answer = answerList[_qNumber];
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Piano Audio Detection'),
        ),
        body: Center(
            child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 200,
              height: 300,
            ),
            Text(
              'Next chord:',
            ),
            Text(
              '$_answer',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              'Playing notes:',
            ),
            Text(
              '$_continuousNotes',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              'Is Correct?:',
            ),
            if (isCorrect == true) Icon(Icons.mood, size: 50)
            // else
            //  Icon(Icons.mood_bad)
          ],
        )),
        floatingActionButton: Container(
          child: ValueListenableBuilder(
            valueListenable: isRecording,
            builder: (context, value, widget) {
              if (value == false) {
                return FloatingActionButton(
                  onPressed: () {
                    isRecording.value = true;
                    start();
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.mic),
                );
              } else {
                return FloatingActionButton(
                  onPressed: () {
                    isRecording.value = false;
                    stop();
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.adjust),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
