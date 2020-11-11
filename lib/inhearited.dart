
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/*
*
* 数据共享组件：InheritedWidget
*
* 1. 共享的什么？
*     比如，ShareDataWidget 中的 data
*
* 2. 如何共享？
*     一个使用共享数据的子widget，
*         比如 _TestWidget
*
*     一个变更共享数据的widget，
*         比如 InheritedWidgetRoute
*
* 3. 效果？
*     在一个Widget中对共享数据变更，会自动通知到相关子Widget
*         比如，在InheritedWidgetRoute中变更data，会通知到_TestWidget
*
* 4. 遗留问题？
*    TODO：效率不高！
*    setState时会重新构建整个页面，但实际只要重绘data相关widget
*
*    比如，setState时，_TestWidget、_TestWidget2都会回调build方法，
*    但实际只有_TestWidget依赖了data，对_TestWidget2的重绘是无意义的！！
*
* 参考：
* 7.2 数据共享（InheritedWidget）
* https://book.flutterchina.club/chapter7/inherited_widget.html
*
* */
class ShareDataWidget extends InheritedWidget {

  //需要在子树中共享的数据，保存点击次数
  final int data;

  ShareDataWidget({@required this.data, Widget child}):super(child:child);


  //定义一个便捷方法，方便子树中的widget获取共享数据
  static ShareDataWidget of(BuildContext context) {
    // TODO:没有找到getElementForInheritedWidgetOfExactType的替代方法！！
    //  据说可以避免子Widget回调"didChangeDependencies"
    return context.inheritFromWidgetOfExactType(ShareDataWidget); // 该方法会注册依赖关系
  }

  @override
  bool updateShouldNotify(ShareDataWidget oldWidget) {
    // TODO:covariant?
    // 该回调决定当data发生变化时，是否通知子树中依赖data的Widget,
    // 即是否回调子widget的didChangeDependencies
    return oldWidget.data != data ;
  }

}

class _TestWidget extends StatefulWidget {
  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<_TestWidget> {
  @override
  Widget build(BuildContext context) {
    print('重绘 1111 TestWidget');
    return Text(ShareDataWidget.of(context).data.toString());
//    return Text('Text',style: TextStyle(fontSize: 30),);
  }

  @override
  void didChangeDependencies() {
    //1. 父或祖先widget中的InheritedWidget改变(updateShouldNotify返回true)时会被调用。
    //2. 如果build中没有依赖InheritedWidget，则此回调不会被调用。
    print('didChangeDependencies ------->');
    // 可以在这里做些耗时操作，比如网络操作等.
  }
}

class _TestWidget2 extends StatefulWidget {
  @override
  __TestWidget2State createState() => __TestWidget2State();
}

class __TestWidget2State extends State<_TestWidget2> {
  @override
  Widget build(BuildContext context) {
    print('重绘 2222 TestWidget');
    return Text('普通Text');
  }
}

class InheritedWidgetRoute extends StatefulWidget {
  @override
  _InheritedWidgetRouteState createState() => _InheritedWidgetRouteState();
}

class _InheritedWidgetRouteState extends State<InheritedWidgetRoute> {
  int count = 0;

  @override
  void initState() {
    print('initState start.....');
    checkUpdate().then((value) => print('then.....')).catchError((onError) => print('onError'));
    print('initState end.....');
  }

  /*
  * I/flutter (22685): initState start.....
    I/flutter (22685): initState end.....
    I/flutter (22685): then.....
    2s后....
  * I/flutter (22685): 这里是延时任务执行完成！
  * */
  Future checkUpdate() async {
    Future.delayed(Duration(seconds: 2)).then((value){
      print('这里是延时任务执行完成');
      return Future.value(true);
    });
    return Future.value(false);
  }

  /*
  * I/flutter (22685): initState start.....
    I/flutter (22685): initState end.....
    2s后....
  * I/flutter (22685): 这里是延时任务执行完成！
  * I/flutter (22685): then.....
  * */
  Future checkUpdateByComplete() async {
    Completer complete = Completer();
    Future.delayed(Duration(seconds: 2)).then((value) {
      print('这里是延时任务执行完成！');
      complete.complete();// 用于控制外层的"then"什么时候执行！！
    });
    return complete.future;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ShareDataWidget(
        data: count,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 30),
              // 依赖ShareDataWidget的子Widget
              child: _TestWidget()),
            Padding(
              padding: EdgeInsets.only(bottom: 30),
              // 依赖ShareDataWidget的子Widget
              child: _TestWidget2()),
            RaisedButton(
              child: Text('增加'),
              //每点击一次，将count自增，然后重新build,ShareDataWidget的data将被更新
              onPressed: ()=> setState(()=> ++count),
            ),
          ],
      ),),
    );
  }
}


