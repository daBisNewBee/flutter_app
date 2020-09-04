import 'dart:async';
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
      AsyncUIPage(), // 异步UI
//      new Center(
//        child: LifecycleWatcher(),
//      ),
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
//    print('getRow i:' + i.toString());
    return Padding(
      padding: EdgeInsets.all(10.0),
      child:GestureDetector(
        onTap: () {
          print("------------ click: $i");
          loadIsolateSimple();
//          if(i % 2 == 0) {
//            loadDataViaPort();
//          } else{
//            loadData();
//          }
        },
        child:Text(
          sprintf("id:%d title:%s", [widgets[i]["id"], widgets[i]["title"]]),
        )
      ),
      );
  }

  // 1. await延迟执行
  // 类似于"AsyncTask和IntentService"，要异步运行代码，可以将函数声明为异步函数，并在该函数中等待这个耗时任务
  // async、await表示进入"协程"代码段，属于无线协程，这些变量保存在堆中，return后不会被销毁
  // (区别于有线协程，变量保存在栈中，return即销毁)。
  loadData() async {
    String dataURL = "https://jsonplaceholder.typicode.com/posts";
    // Dart规定有async标记的函数，只能由await来调用
    DateTime now = DateTime.now();
    print('11111 开始时间 begin $now');
    http.Response response = await http.get(dataURL);
    now = DateTime.now();
    print('11111 结束时间 begin $now');
    setState(() {
      widgets = json.decode(response.body);
    });
  }

  // 2. 这个例子的结论：在新建的Isolate中修改i和intObject变量的值后，
  // 在main()函数所在Isolate中不能获取到，所以Isolate在内存上是隔离的。
  loadIsolateSimple() async {
    final receive = ReceivePort();
    receive.listen((data)
    {
      print("Main 收到 data: $data, i = $i, intObject = ${intObject.get()}");
    });
    await Isolate.spawn(isolateEntryFunction, receive.sendPort);
    print(DateTime.now().toString() + " 开始了......");
  }

  static int i = 0;
  static IntObject intObject = IntObject();

  static isolateEntryFunction(SendPort sendPort){
    int counter = 0;
    Timer.periodic(const Duration(seconds: 3), (_){

      counter++;
      i++;
      intObject.increase();

      print("Isolate 打印 counter: $counter, i = $i, intObject = ${intObject.get()}");
      String msg = "来自Iso的消息: counter: $counter";
      sendPort.send(msg);
    });
  }

  /*
  * 由于并没有开启新的线程，只是进行IO中断改变CPU调度，
  * 所以网络请求这样的异步操作可以使用async、await，
  * 但如果是执行大量耗时同步操作的话，
  * 应该使用Isolate开辟新的线程去执行。
  *
  * 为什么要isolate？
  * 多线程模型下，工作线程、UI线程占用同一块内存，工作线程频繁对内存申请、回收，容易触发gc，引起ui卡顿。
  * isolate的出现，线程之间内存"隔离"，可以相互不影响
  *
  * */
  // 3. isolate 机制 。 TODO： 其实有点懵逼
  loadDataViaPort() async {
    // 1.
    // 通过spawn新建一个isolate，并绑定静态方法
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(dataLoader, receivePort.sendPort);

    // 获取新isolate的监听port
    SendPort sendPort = await receivePort.first;
    DateTime now = DateTime.now();
    print('22222 开始时间 begin $now');
    List dataList = await sendReceive(sendPort, 'https://jsonplaceholder.typicode.com/posts');
    now = DateTime.now();
    print('22222 结束时间 begin $now');
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


class IntObject {
  int i = 0;
  void increase() {
    i++;
  }
  int get() {
    return i;
  }
}