
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AsyncUpdateApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '异步更新',
      home: Scaffold(
        appBar: AppBar(title: Text('异步更新')),
        body: FutureWidget(),
      ),
    );
  }

}

Future<String> mockNetworkData() async {
  return Future.delayed(Duration(seconds: 3), ()=>"我是从互联网获取的数据");
}

// 每隔1秒，计数加1
Stream<int> count() {
  return Stream.periodic(Duration(seconds: 1), (i) {
    return i;
  });
}

class FutureWidget extends StatefulWidget {
  @override
  _FutureWidgetState createState() => _FutureWidgetState();
}

class _FutureWidgetState extends State<FutureWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
      children: <Widget>[
        // FutureBuilder: 单次异步更新，关注结果更多！
        FutureBuilder(
        future: mockNetworkData(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          print('snapshot: ${snapshot.toString()}');
          // ConnectionState.waiting、ConnectionState.done
          if(snapshot.connectionState == ConnectionState.done){
            if(snapshot.hasError){
              return Text('返回错误：${snapshot.error}');
            } else{
              return Text('返回内容：${snapshot.data}');
            }
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
        // StreamBuilder: 进度更新,频繁多次异步更新
        // 常用于会多次读取数据的异步任务场景，如网络内容下载、文件读写等。
        // StreamBuilder正是用于配合Stream来展示流上事件（数据）变化的UI组件。
        StreamBuilder(
          stream: count(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.hasError) {
              return Text('发生了错误: ${snapshot.error}');
            }
            switch(snapshot.connectionState) {
              case ConnectionState.done:
                return Text('Stream已关闭');
              case ConnectionState.active:
                return Text('active: ${snapshot.data}');
              case ConnectionState.none:
                return Text('没有Stream');
              case ConnectionState.waiting:
                return Text('等待数据');
            }
            return null;
          },
        )
      ],

      ),
    );
  }
}
