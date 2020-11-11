import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';


/*
* State的生命周期:
*
* 几个重要状态：
*
* 1. 创建一个Widget：
* initState (初始化)
  didChangeDependencies
  build (构建Widget树)
*
* 2. 点击热重载：
* reassemble (调试专用)
  didUpdateWidget (树rebuid)
  build
*
* 3. App 由前台到后台：
* AppLifecycleState.inactive
  AppLifecycleState.paused
*
* 4. App 由后台到前台：
* AppLifecycleState.inactive
  AppLifecycleState.resumed
*
* 5. 退出页面：(TODO：如何触发？)
* deactivate ()
* dispose (更彻底！State对象从树中永久被移除，释放资源)
*
* */
class LifeStateApp extends StatelessWidget {

  // "StatelessWidget 的生命周期只有一个，就是 build"
  // 因为无状态，所以无法提供setState等方法修改组件状态！
  @override
  Widget build(BuildContext context) {
    print('LifeStateApp StatelessWidget build.');
    return MaterialApp(
      title: "State的生命周期",
      home: Scaffold(
        appBar: AppBar(title: Text('State的生命周期'),),
        body: MySFBean(),
      ),
    );
  }

}

class MySFBean extends StatefulWidget {
  @override
  _MySFBeanState createState() => _MySFBeanState();
}

class _MySFBeanState extends State<MySFBean> with WidgetsBindingObserver {

  int count = 0;

  // 构建Widget子树
  @override
  Widget build(BuildContext context) {
    print('build'); // 不要在这里写业务逻辑！每次刷新界面都会调用！业务可以写在StatelessWidget的构造函数里！
    return Container(
      child: Center(
        child:Column(
          children: <Widget>[
            GestureDetector(
            child: Text('操蛋的flutter', style: TextStyle(fontSize: 32, color: Colors.pink),),
            onTap: (){
              setState(() {
                count++;
              });
            }
            ),
            Text('$count', style: TextStyle(fontSize:50, color: Colors.green),),
          ],
        )
      ),
    );
  }

  // widget创建执行的第一个方法，可以再里面初始化一些数据，以及绑定控制器
  @override
  void initState() {
    super.initState();
    print('initState');
    WidgetsBinding.instance.addObserver(this);
  }

  // State对象的依赖发生变化时会被调用 TODO:需要时再推敲具体作用
  // "Called when a dependency of this [State] object changes.(会执行多次)"
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('didChangeDependencies');
  }

  // State对象从树中被移除:永久！！通常在此回调中释放资源。
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    print('dispose');
  }

  // State对象从树中被移除(用的少....可以忽略)
  @override
  void deactivate() {
    super.deactivate();
    print('deactivate');
  }

  // 专门为了开发调试而提供的!! 在热重载(hot reload)时会被调用，
  // 此回调在Release模式下永远不会被调用!!
  @override
  void reassemble() {
    super.reassemble();
    print('reassemble');
  }

  // 当树rebuid的时候
  @override
  void didUpdateWidget(MySFBean oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('didUpdateWidget');
  }

  // // 事件监听. 这是 "WidgetsBindingObserver"下的方法.可以计算曝光等
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('didChangeAppLifecycleState：' + state.toString());
    switch(state){
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.resumed:
        break;
//      case AppLifecycleState.suspending:
//        break;
    }
  }
}
