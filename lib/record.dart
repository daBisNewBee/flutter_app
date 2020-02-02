import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/ios_quality.dart';

class RecordApp extends StatelessWidget {
  FlutterSound flutterSound = FlutterSound();
  StreamSubscription _streamSubscription;
  String _audioPath;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '录音',
      home: Scaffold(
        appBar: AppBar(
          title: Text('录音APP'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              new RaisedButton(
                  child: Text('录制'),
                  onPressed: _startRecord),
              new RaisedButton(
                  child: Text('停止录制'),
                  onPressed: _stopRecord),
              new RaisedButton(
                  child: Text('播放'),
                  onPressed: _startPlay),
              new RaisedButton(
                  child: Text('停止播放'),
                  onPressed: _stopPlay),
            ],
          ),
        ),
      ),
    );
  }
    _startRecord() async {
    print('_startRecord');
    String result = await flutterSound.startRecorder(
//        uri: _audioPath,
        sampleRate: 44100,
        numChannels: 2,
        codec: t_CODEC.CODEC_AAC, // CODEC_PCM 不支持
        iosQuality: IosQuality.HIGH,
    );
    print('result:' + result);
    _audioPath = result;

    _streamSubscription = flutterSound.onRecorderStateChanged.listen((statue) {
      DateTime dateTime = DateTime.fromMicrosecondsSinceEpoch(
        statue.currentPosition.toInt(),
        isUtc: true,
      );
      print('dateTime:' + dateTime.toString());
      print('pos:' + statue.toString());
    });
  }

   _stopRecord() async {
    if (_streamSubscription != null) {
      _streamSubscription.pause();
    }

    print('_stopRecord');
    String result = await flutterSound.stopRecorder();
    print('result:' + result);
  }

   _startPlay() async {
    String result = await flutterSound.startPlayer(_audioPath);
    print('_startPlay:' + result);
  }

   _stopPlay() async{
    String result = await flutterSound.stopPlayer();
    print('_stopPlay:' + result);
  }
}