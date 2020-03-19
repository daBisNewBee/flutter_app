import 'package:flutter/material.dart';

/*
* 管理状态:
* 1. widget管理自己的state TapBpoxA
  2. 父widget管理 widget状态 TapBpoxB
  3. 混搭管理（父widget和widget自身都管理状态）） TapBoxC

  选择何种，两个原则：
  1. 如果状态是用户数据，如复选框的选中状态、滑块的位置，则该状态最好由父widget管理
  2. 如果所讨论的状态是有关界面外观效果的，例如动画，那么状态最好由widget本身来管理.
  *
  * 所谓的"管理"意思是：
  * 在哪里执行：
  * "
  * setState(() {
      _highlight = true;
    });
  * 在本控件内执行，就是本控件内自己管理；ex,TapBpoxA,
  * 在其他控件执行，就是其他控件来管理！ex,TapboxB由ParentWidget来管理，
  *                                 TapboxC的active由ParentWidget来管理，highlight由自己管理
  * "
* */

// TapboxA 管理自身状态.
class TapboxA extends StatefulWidget {

  @override
  _TapboxAState createState() {
    return new _TapboxAState();
  }
}

class _TapboxAState extends State<TapboxA> {
  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: _handleTap,
      child: new Container(
        child: new Center(
          child: new Text(
            _isActive ? 'Active':'InActive',
            style: new TextStyle(fontSize: 32.0, color: Colors.white),),
        ),
        width: 200.0,
        height: 200.0,
        decoration: new BoxDecoration(
          color: _isActive ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  void _handleTap() {
    setState(() {
      _isActive = !_isActive;
    });
  }

  @override
  void initState() {
    print('_TapboxAState initState.');
  }

}

class ManageStateApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '管理状态',
      home: new Scaffold(
        appBar: new AppBar(title: new Text('管理状态')),
        body: new Column(
          children: <Widget>[
            new Container(
              alignment: Alignment.topCenter,
              child: new TapboxA(),
            ),
            new Divider(),
            new Container (
              alignment: Alignment.center,
              child: new ParentWidget(),
            ),
          ],
        ),
      ),
    );
  }
}

class ParentWidget extends StatefulWidget {

  @override
  _ParentWidgetState createState() {
    return new _ParentWidgetState();
  }

}

// 对于父widget来说，管理状态并告诉其子widget何时更新通常是最有意义的。
class _ParentWidgetState extends State<ParentWidget> {

  bool _active = false;

  void _handleTapboxChanged(bool newValue) {
    setState(() {
      _active = newValue;
    });
  }

  @override
  void initState() {
    print('_ParentWidgetState initState');
  }

  @override
  Widget build(BuildContext context) {
     return new TapboxB (
//    return new TapboxC (
        onChanged: _handleTapboxChanged,
        active: _active,
    );
  }
}

// 父widget管理widget的state TODO: 还是不太明白这么做的意义？
class TapboxB extends StatelessWidget {

  TapboxB({Key key, this.active:false, @required this.onChanged})
      :super(key:key);

  final bool active;
  final ValueChanged<bool> onChanged;

  void _handleTap() {
    // 回调父Widget的"_handleTapboxChanged"，并由父Widget来决定是否更新、如何更新
    onChanged(!active);
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: _handleTap,
      child: new Container(
        child: new Center(
          child: new Text(
            active ? 'Active' : 'InActive',
            style: new TextStyle(fontSize: 32.0, color: Colors.white),
          ),
        ),
        width: 200.0,
        height: 200.0,
        decoration: new BoxDecoration(
          color: active ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}

// 混合管理：有状态widget管理一些状态，并且父widget管理其他状态。
// ex, TapboxC将其_active状态导出到其父widget中，但在内部管理其_highlight状态
class TapboxC extends StatefulWidget {

  // 如果父类不显示提供无名无参的构造函数，在子类中必须手动调用父类的一个构造函数。
  // 这种情况下，调用父类的构造函数的代码放在子类构造函数名后，子类构造函数体前，中间使用 : 分隔
  TapboxC({Key key, this.active : false, @required this.onChanged}) : super(key : key);
  // "super" 表示 在子类中手动调用父类的一个构造函数

  final bool active;
  final ValueChanged<bool> onChanged;

  @override
  State<StatefulWidget> createState() {
    return new _TapboxCState();
  }

}

class _TapboxCState extends State<TapboxC> {

  bool _highlight = false;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: _handleTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: new Container(
        child: new Center(
          child: new Text(
            widget.active ? 'Active' : 'InActive',
            style: new TextStyle(fontSize: 32.0, color: Colors.white)),
        ),
        width: 200.0,
        height: 200.0,
        decoration: new BoxDecoration(
          color: widget.active ? Colors.green : Colors.grey,
          border: _highlight ? new Border.all(
            color: Colors.teal,
            width: 10.0,
          ) : null,
        ),
      ),
    );
  }

  void _handleTap() {
    // TODO: 这里不需要setState，想想为什么？
//    setState(() {
      widget.onChanged(!widget.active);
//    });
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _highlight = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _highlight = false;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _highlight = false;
    });
  }
}