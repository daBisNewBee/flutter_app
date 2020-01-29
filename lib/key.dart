import 'dart:math' as math;
import 'package:flutter/material.dart';

/*
*
* 何时需要使用到key？
*
* 【Flutter学习】之深入浅出 Key:
* https://www.cnblogs.com/lxlx1798/p/11171636.html
*
* 使用场合：
*  1. 有状态Widget
*  2. 同类型Widget进行操作时
*  3. 不需要使用：无状态Widget
*
* TODO:
*  1. 元素树、Widget树 原理
*  2. Widget 的 diff 更新机制
*  3. Key的几个衍生Localkey、GlobalKey 及其使用场合
* */
class StatelessColorTile extends StatelessWidget {
  final Color color = randomColor();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      width: 100.0,
      height: 100.0,
    );
  }
}

class StatefulColorTile extends StatefulWidget {

  StatefulColorTile({Key key}) : super(key:key);

  @override
  _StatefulColorTileState createState() {
    return _StatefulColorTileState();
  }
}

class _StatefulColorTileState extends State<StatefulColorTile> {
  final Color color = randomColor();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      width: 100.0,
      height: 100.0,
    );;
  }
}

class Screen extends StatefulWidget {

  @override
  _ScreenState createState() {
    return _ScreenState();
  }
}

class _ScreenState extends State<Screen> {
  List<Widget> widgets = [
    StatefulColorTile(key:UniqueKey()), // key重要！想想为什么！
    StatefulColorTile(key:UniqueKey()),
//    StatelessColorTile(),
//    StatelessColorTile(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('KeyFAQ'),),
        body: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: widgets,
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: _handleOnPressed,
            // new 可要可不要!!Dart的第一个版本实例化对象需要new关键字，dart2里new是可选(包含const)
            child: Icon(Icons.undo)),
    );
  }


  void _handleOnPressed() {
    setState(() {
      widgets.insert(0, widgets.removeAt(1));
    });
  }
}

class ScreenApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Key FAQ App',
      theme: ThemeData(
        primaryColor: Colors.green,
      ),
      home: Screen(),
    );
  }

}

Color randomColor(){
  return Color.fromARGB(
      math.Random().nextInt(255)
      ,math.Random().nextInt(255)
      ,math.Random().nextInt(255)
      ,math.Random().nextInt(255));
}
