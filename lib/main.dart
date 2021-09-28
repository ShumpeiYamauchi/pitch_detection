import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_piano_audio_detection/flutter_piano_audio_detection.dart';
import 'dart:async';
import 'dart:io';

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
  String? _mainNote;
  List<String>? _effectiveNotes;
  List<String>? _allNotes;
  List<String>? _continuousNotes;
  bool? isC = true;

  List<String> answer = ['C4', 'E4', 'G4'];

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
    result = fpad.startAudioRecognition();
    sleep(Duration(seconds: 1));
    Set<String> twoprev = {};
    Set<String> oneprev = {};
    Set<String> currentprev = {};
    result!.listen((event) {
      setState(() {
        _allNotes = fpad.getNotes(event);
        twoprev = oneprev;
        oneprev = currentprev;
        currentprev = _allNotes!.toSet();
        _continuousNotes =
            currentprev.intersection(oneprev.intersection(twoprev)).toList();
        isC = _continuousNotes == answer;
        print(isC);
        isC = answer.toSet().difference(_continuousNotes!.toSet()).isEmpty &&
            _continuousNotes!.toSet().difference(answer.toSet()).isEmpty;
        print(answer);
        print(_continuousNotes);
        print(isC);
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Text(
            //   'Main note:',
            // ),
            // Text(
            //   '$_mainNote',
            //   style: Theme.of(context).textTheme.headline4,
            // ),
            // Text(
            //   'Effective notes:',
            // ),
            // Text(
            //   '$_effectiveNotes',
            //   style: Theme.of(context).textTheme.headline4,
            // ),
            // Text(
            //   'All notes:',
            // ),
            // Text(
            //   '$_allNotes',
            //   style: Theme.of(context).textTheme.headline4,
            // ),
            Text(
              'Continuous notes:',
            ),
            Text(
              '$_continuousNotes',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              'Is C:',
            ),
            if (isC == true)
              Icon(Icons.mood, size: 50)
            else
              Icon(Icons.mood_bad)
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
