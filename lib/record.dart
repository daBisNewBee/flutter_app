import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/ios_quality.dart';

/*
* Flutter如何和Native通信-Android视角:
* https://www.jianshu.com/p/d9eeb15b3fa0
*
* Flutter通过BasicMessageChannel实现Flutter 与Android iOS 的双向通信：
* https://blog.csdn.net/zl18603543572/article/details/96043692
* */
class RecordApp extends StatelessWidget {
  FlutterSound flutterSound = FlutterSound();
  StreamSubscription _streamSubscription;
  String _audioPath;

  // channel的名称要和Native端的一致
  // MethodChannel提供了方法调用的通道
  static const MethodChannel methodChannel = const MethodChannel("samples.flutter.io/battery");
  // 传递数据流，避免信息接收端主动轮训，比如电池变更信息等
  static const EventChannel eventChannel = const EventChannel("samples.flutter.io/charging");
  // 传递字符串和一些半结构体的数据，具体结构参考"MessageCodec"的几个子类
  static const BasicMessageChannel basicMessageChannel = const BasicMessageChannel("samples.flutter.io/basic", StandardMessageCodec());

  @override
  Widget build(BuildContext context) {
    methodChannel.setMethodCallHandler(platformCallHandler);
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError, onDone: _onDone);
    basicMessageChannel.setMessageHandler(_basicMessageChannelHandler);

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
              RaisedButton(
                child: Text('Flutter发送消息到Native'),
                onPressed: _sendMsgFlutter2Native),
              RaisedButton(
                child: Text('Native发送消息到Flutter'),
                onPressed: _sendMsgNaive2Flutter),
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
    final int result = await methodChannel.invokeMethod("getBatteryLevel");
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
     await methodChannel.invokeMethod('invokeFlutterMethod');
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

  _sendMsgFlutter2Native() {
    sendMessage({"method":"test", "ontent":"这是Flutter的数据", "code":100});
  }

  _sendMsgNaive2Flutter() {
    sendMessage({"method":"test2", "ontent":"这是Flutter的数据2", "code":300});
  }

  Future<Map> sendMessage(Map params) async {
    Map reply = await basicMessageChannel.send(params);
    int code = reply["code"];
    String message = reply["message"];
    print('code:$code message:$message');
    return reply;
  }

  Future<Map> _basicMessageChannelHandler(result) {
    int code = result["code"];
    String message = result["message"];
    print('_basicMessageChannelHandler: code:$code message:$message');
//    Map ret = {"a-key":"a-value","b-key":"b-value"};
    return null;
  }
}