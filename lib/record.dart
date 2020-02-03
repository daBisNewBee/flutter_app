import 'dart:async';
import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
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
*
* (原理类)Flutter之MethodChannel:
* https://blog.csdn.net/arinasiyyj/article/details/96873000
*
*
* 热更新的几点思考：
* 1. 可更新：根Widget树下的变更(刷新Widget树就可以生效了)
*           ex, 修改main()下入口不会生效，因为跟Widget改变了。
* 2. 不可更新：状态，及状态依赖相关
*           ex, 1. 全局变量和静态字段的修改不可变更，因为其被视为状态
*               (有个例外，被const修饰的字段可以，因为"const字段被视为别名而不是状态")
*               2. widget的属性变化，不可生效。stless与stful相互转变，因为这影响了当前状态的变化
*
*
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

  final array = [1,2,3,5]; // 注意：这里的成员修改后，热重载后不会生效
  static const foo = 4; // 热更新有效！对const字段值的更改始终会重新加载，
  final bar = foo; // 注意！热更新无效！需要支持热更新，要改成以下两种方式！
//  static const bar = foo;
//  get bar => foo;       // TODO:
  

  @override
  Widget build(BuildContext context) {
    methodChannel.setMethodCallHandler(platformCallHandler);
    eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError, onDone: _onDone);
    basicMessageChannel.setMessageHandler(_basicMessageChannelHandler);
//    debugPaintSizeEnabled = true; // 可以打印布局边界！！！
//    debugPaintBaselinesEnabled = true; // 文字基线
    // debug* 下的字段 仅在 调试模式下工作！
//    timeDilation = 50.0; // 调试动画最简单的方法是减慢它们的速度
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
    // 以下验证热更新
    print("array: $array");
    print('foo:$foo');
    print('bar:$bar');
  }

  Future<Map> sendMessage(Map params) async {
//    debugger(when: params.length > 0); // 代码断点：条件成立时中断！
    debugPrint("用这个方法打印可以防止日志被丢弃.");
    /*
    * 用于转储Widgets库的状态
    * TODO： 实际作用待验证
    * */
//    debugDumpApp();
    /*
    * 转储渲染树
    * "当调试布局问题时，关键要看的是size和constraints字段。
    *  约束沿着树向下传递，尺寸向上传递。"
    * */
//    debugDumpRenderTree();
//    debugDumpSemanticsTree(); // 打印语义树
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