import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import "dart:convert";
import 'package:sprintf/sprintf.dart';
import 'package:http/http.dart' as http;

class ForAndroidApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: new ThemeData(
        primaryColor: Colors.red,
      ),
      home:
//      AsyncUIPage(), // 异步UI
      new Center(
        child: LifecycleWatcher(),
      ),
    );
  }

}

class AsyncUIPage extends StatefulWidget {

  @override
  _AsyncUIPageState createState() {
    return _AsyncUIPageState();
  }

}

class _AsyncUIPageState extends State<AsyncUIPage> {
  List widgets = [];


  @override
  void initState() {
    super.initState();
    print('initState');
//    loadData();
    loadDataViaPort();
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    return Scaffold(
      appBar: AppBar(
        title: Text('AsyncUIPage'),
      ),
      body: ListView.builder(
          itemCount: widgets.length,
          itemBuilder: (BuildContext context, int position) {
            return getRow(position);
          }),
    );
  }

  Widget getRow(int i) {
    print('getRow i:' + i.toString());
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Text(
          sprintf("id:%d title:%s", [widgets[i]["id"], widgets[i]["title"]]),
    ));
  }

  // await延迟执行
  // 类似于"AsyncTask和IntentService"，要异步运行代码，可以将函数声明为异步函数，并在该函数中等待这个耗时任务
  loadData() async {
    String dataURL = "https://jsonplaceholder.typicode.com/posts";
    // Dart规定有async标记的函数，只能由await来调用
    http.Response response = await http.get(dataURL);
    setState(() {
      widgets = json.decode(response.body);
    });
  }

  // isolate 机制 。 TODO： 其实有点懵逼
  loadDataViaPort() async {
    // 1.
    // 通过spawn新建一个isolate，并绑定静态方法
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(dataLoader, receivePort.sendPort);

    // 获取新isolate的监听port
    SendPort sendPort = await receivePort.first;
    List dataList = await sendReceive(sendPort, 'https://jsonplaceholder.typicode.com/posts');
    print('dataList: $dataList');
    setState(() {
      widgets = dataList;
    });
  }

  // isolate的绑定方法
  // “dataLoader”是在它自己的独立执行线程中运行的隔离区，
  // 您可以在其中执行CPU密集型任务，例如解析大于1万的JSON或执行计算密集型数学计算。
  static dataLoader(SendPort sendPort) async {
    // 2.
    // 创建监听port，并将sendPort传给外界用来调用
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    // 监听外界调用
    await for (var msg in receivePort) {
      // 4.
      String requestUrl = msg[0];
      SendPort callbackPort = msg[1];

      Client client = http.Client();
      Response response = await client.get(requestUrl);
      List dataList = json.decode(response.body);
      // 回调返回值给调用者
      callbackPort.send(dataList);
    }
  }

  // 创建自己的监听port，并且向新isolate发送消息
  Future sendReceive(SendPort sendPort, String url) {
    // 3.
    ReceivePort receivePort = ReceivePort();
    sendPort.send([url, receivePort.sendPort]);
    // 接收到返回值，返回给调用者
    return receivePort.first;
  }
}

// "如何监听Android Activity生命周期事件"
class LifecycleWatcher extends StatefulWidget {

  @override
  _LifecycleWatcherState createState() {
    return _LifecycleWatcherState();
  }

}

class _LifecycleWatcherState extends State<LifecycleWatcher> with WidgetsBindingObserver {

  AppLifecycleState _lastAppLifecycleState;

  @override
  Widget build(BuildContext context) {
    if (_lastAppLifecycleState == null) {
      return Text('_lastAppLifecycleState == null', textDirection: TextDirection.ltr,);
    }
    return Text('_lastAppLifecycleState was :$_lastAppLifecycleState');
  }

  @override
  void initState() {
    print('initState');
    WidgetsBinding.instance.addObserver(this);
  }

  /*
  *
  * 推到后台：
  * inactive
  * paused
  *
  * 切到前台：
  * resumed
  * */
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('didChangeAppLifecycleState: $state');
    setState(() {
      _lastAppLifecycleState = state;
    });
  }

  @override
  void dispose() {
    print('dispose');
    WidgetsBinding.instance.removeObserver(this);
  }

}