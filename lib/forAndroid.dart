import 'package:flutter/material.dart';
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
      home: AsyncUIPage(),
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
    loadData();
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

}