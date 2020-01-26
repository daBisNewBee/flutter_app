import 'package:flutter/material.dart';


// 使用主题共享颜色和字体样式
class MyThemeApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final appName = 'Custom Themes';
    return new MaterialApp(
      title: appName,
      // 创建应用主题:全局主题
      theme: new ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.lightBlue[800],
        accentColor: Colors.cyan[600],// TODO：这个属性若注释，以下几种方式获取到的主题颜色会不确定！
      ),
      home: new MyHomePage(
        title: appName,
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {

  final String title;

  MyHomePage({Key key, @required this.title}):super(key:key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: new Center(
        child: new Container(
          // 复用一个已有主题："Theme.of(context)将查找Widget树并返回树中最近的Theme"
          color: Theme.of(context).accentColor,
          child:  new Text(
            'Text with a background color',
            style: Theme.of(context).textTheme.title,
          ),
        ),
      ),
      floatingActionButton: new Theme(
          // 1. 局部主题:之"创建特有的 ThemeData"。 可以区别于父主题颜色
          data: new ThemeData(accentColor: Colors.yellow),
          // 2. 局部主题:之"扩展父主题"。 可以复用父主题颜色
//        data: Theme.of(context).copyWith(accentColor: Colors.yellow),
          // 注意判断一下以上两者区别？
          child: new FloatingActionButton(
              onPressed: null,
              child: new Icon(Icons.add),
          )),
    );
  }

}


/*
* 导航到新页面并返回
* */
class FirstScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('First Screen'),
      ),
      body: new Center(
        child: new RaisedButton(
            child: new Text('Launch new screen.'),
            onPressed: () {
              Navigator.push(context, new MaterialPageRoute(
                  builder:(context){
                    return new SecondScreen();
              }));
            }
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Second Screen'),
      ),
      body: new Center(
        child: new RaisedButton(
            child: new Text('Go Back!'),
            onPressed: () {
              Navigator.pop(context);
            }
        ),
      ),
    );
  }

}