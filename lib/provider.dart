import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/*
* 1. StatefulWidget 封装的data组件，利用stful生命周期回调，自然注册data的变化监听
* 2. 在data变化时，notifyListener，回调注册时的setState函数
* 3. 重绘stateful的build，重新构建InheritedProvider
* 4. 依赖该InheritedWidget的子孙Widget就会更新
*
* */
class InheritedProvider<T> extends InheritedWidget {

  final T data;

  InheritedProvider({@required this.data, Widget child}):super(child:child);

  @override
  bool updateShouldNotify(InheritedProvider<T> oldWidget) {
    return true;
  }
}

// provider: 监听数据改变，无需再手动更新
class ChangeNotifierProvider<T extends ChangeNotifier> extends StatefulWidget {

  final Widget child;
  final T data;

  ChangeNotifierProvider({Key key, this.child, this.data});

  static T of<T>(BuildContext context, {bool listen = true}) {
    // final type = <InheritedProvider<T>>();
    final provider = listen ? context.dependOnInheritedWidgetOfExactType<InheritedProvider<T>>() :
      context.getElementForInheritedWidgetOfExactType<InheritedProvider<T>>()?.widget as InheritedProvider<T>;
    return provider.data;
  }

  @override
  _ChangeNotifierProviderState<T> createState() => _ChangeNotifierProviderState();
}

class _ChangeNotifierProviderState<T extends ChangeNotifier> extends State<ChangeNotifierProvider<T>> {

  void update() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    print('========> build =====> $widget');
    return InheritedProvider<T>(
      child: widget.child,
      data: widget.data,
    );
  }

  @override
  void initState() {
    widget.data.addListener(update);
    super.initState();
  }

  @override
  void dispose() {
    widget.data.removeListener(update);
    super.dispose();
  }

  @override
  void didUpdateWidget(ChangeNotifierProvider<T> oldWidget) {
    print('========> didUpdateWidget =====> $widget');
    if(widget.data != oldWidget.data) {
      oldWidget.data.removeListener(update);
      widget.data.addListener(update);
    }
    super.didUpdateWidget(oldWidget);
  }
}

class Item {
  double price;
  int count;

  Item(this.price, this.count);
}

class CartModel extends ChangeNotifier {
  final List<Item> _items = [];

  UnmodifiableListView<Item> get item => UnmodifiableListView(_items);

  double get totalPrice => _items.fold(0, (previousValue, element) => previousValue + element.count * element.price);

  void add(Item item) {
    _items.add(item);
    notifyListeners();
  }
}

class Consumer<T> extends StatelessWidget {

  final Widget child;
  final Widget Function(BuildContext context, T value) builder;

  Consumer({Key key ,@required this.builder, this.child }):assert(builder != null),super(key:key);

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      ChangeNotifierProvider.of<T>(context),
    );
  }
}

class ProviderRoute extends StatefulWidget {
  @override
  _ProviderRouteState createState() => _ProviderRouteState();
}

class _ProviderRouteState extends State<ProviderRoute> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: ChangeNotifierProvider(
          data: CartModel(),
          child: Builder(
            builder: (context) {
              return Column(
                children: <Widget>[
                  Builder(builder: (context) {
                    print('普通text build');
                    return Text('演示');
                  }),
                  Consumer<CartModel>(
                    builder: (context, cart) => Text("总价: ${cart.totalPrice}"),// Consumer 是对下面Builder的优化写法
                  ),
                  Builder(builder: (context) {
                    print('总价text build');
                    var cart = ChangeNotifierProvider.of<CartModel>(context, listen: true);
                    return Text('总价: ${cart.totalPrice}');
                  }),
                  Builder(builder: (context) {
                    print('按钮 build');
                    return RaisedButton(
                      child: Text('添加商品'),
                      onPressed: () {
                        // 性能问题优化。 "listen: false"：解除Button对InheritedWidget的注册关系，使得InheritedWidget更新时，button不会执行build
                        ChangeNotifierProvider.of<CartModel>(context, listen: false).add(Item(20.0, 1));
                  },
                );
              }),
            ],
          );
        },
      ),
    ));
  }
}
