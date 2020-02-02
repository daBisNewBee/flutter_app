import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/ios_quality.dart';

class RecordApp extends StatelessWidget {
  FlutterSound flutterSound = FlutterSound();
  StreamSubscription _streamSubscription;
  String _audioPath;

  // channel的名称要和Native端的一致
  // MethodChannel提供了方法调用的通道
  static const MethodChannel platform = const MethodChannel("samples.flutter.io/battery");
  static const EventChannel eventChannel = const EventChannel("samples.flutter.io/charging");

  @override
  Widget build(BuildContext context) {
    platform.setMethodCallHandler(platformCallHandler);
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError, onDone: _onDone);

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
              new RaisedButton(
                child: Text('Flutter调用Native方法'),
                onPressed: _getMsgFlutterFromNative),
              new RaisedButton(
                child: Text('Native调用Flutter方法'),
                  onPressed: _getMsgNativeFromFlutter),

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

  _getMsgFlutterFromNative() async {
    final int result = await platform.invokeMethod("getBatteryLevel");
    print('getBatteryLevel: $result');
  }

  Future<dynamic> platformCallHandler(MethodCall call) async {
    String retStr;
    switch(call.method) {
      case "getName":
        retStr = "This is String from Flutter World.";
        break;
      default:
        retStr = "This is default String from flutter.";
        break;
    }
    return retStr;
  }

   _getMsgNativeFromFlutter() async {
     await platform.invokeMethod('invokeFlutterMethod');
  }

  _onError(Object error) {
    print('_onError:' + error);
  }

  _onEvent(Object event) {
    print('_onEvent:' + event.toString());
  }

  _onDone() {
    print('_onDone.');
  }
}