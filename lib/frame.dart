import 'package:flutter/material.dart';

// "基础 Widget"
class MyScaffold extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Material(
      child: new Column(
        children: <Widget>[
          new MyAppBar(
            title: new Text(
              'Example title',
              style: Theme.of(context).primaryTextTheme.title,
            ),
          ),
          new Expanded(
              child: new Center(
                child: new Text('Hello world.'),
              ))
        ],
      ),
    );
  }

}

class MyAppBar extends StatelessWidget {

  MyAppBar({this.title});

  final Widget title;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Container(
      // 单位是逻辑上的像素（并非真实的像素，类似于浏览器中的像素）
      height: 56.0,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: new BoxDecoration(color: Colors.blue[500]),
      // Row 是水平方向的线性布局（linear layout）. 其他：水平（Row）和垂直（Column）
      child: new Row(
        children: <Widget>[
          new IconButton(
              icon: new Icon(Icons.menu),
              tooltip:'Naviga Menu',
              onPressed: null),
          new Expanded(child: title), // 会填充尚未被其他子项占用的的剩余可用空间
          new IconButton(
              icon: new Icon(Icons.search),
              tooltip:'Search',
              onPressed: null)
        ],
      ),
    );
  }
}

// "使用 Material 组件"
class TutorialHome extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    //Scaffold是Material中主要的布局组件.
    return new Scaffold(
      appBar: new AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.menu),
            tooltip: 'Naviga Menu',
            onPressed: null),
        title: new Text('AppBar title'),
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.search),
              tooltip:'Search',
              onPressed: null),
          new MyButton()
        ],
      ),
      //body占屏幕的大部分
      body: new Center(
        child: new Text('hhhello world.'),
      ),
      floatingActionButton: new FloatingActionButton(
          tooltip:'Add',
          child: new Icon(Icons.add),
          onPressed: null),
    );
  }

}

// "处理手势"
class MyButton extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        print('MyButton was onTap!');
      },
      child: new Container(
        height: 36.0,
        padding:const EdgeInsets.all(8.0),
        margin:const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: new BoxDecoration(
          borderRadius: new BorderRadius.circular(5.0),
          color: Colors.lightGreen[500],
        ),
        child: new Center(
          child: new Text('Engage'),
        ),
      ),
    );
  }

}

// ================================================================================
// "整合所有"

class Product {
  const Product({this.name});
  final String name;
}

typedef void CartChangedCallback(Product product, bool inCart);

//  该widget是无状态的。
class ShoppingListItem extends StatelessWidget {

  final Product product;
  final bool inCart;
  final CartChangedCallback onCartChanged;

  ShoppingListItem({this.product, this.inCart, this.onCartChanged});
//  : product = product, super(key : new ObjectKey(product));

  Color _getColor(BuildContext context) {
    print('_getColor:' + inCart.toString());
    return inCart ? Colors.black54:Theme.of(context).primaryColor;
  }

  TextStyle _getTextStyle(BuildContext context) {
    if (!inCart) return null;
    return new TextStyle(
      color: Colors.black54,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new ListTile(
      onTap: (){
        // 回调父widget的函数："_handleCartChanged"
        onCartChanged(product, !inCart);
      },
      leading: new CircleAvatar(
        backgroundColor: _getColor(context),
        child: new Text(product.name[0]),
      ),
      title: new Text(product.name, style: _getTextStyle(context)),
    );
  }

}

class ShoppingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shopping'),),
      body: ShoppingList(
        products: <Product>[
          Product(name: 'Eggs'),
          Product(name: 'Flour'),
          Product(name: 'Chocolate'),
        ],),
    );
  }
}

class ShoppingList extends StatefulWidget {

//  ShoppingList({this.products});
  ShoppingList({Key key, this.products}) : super(key : key); // TODO: key的作用？

  final List<Product> products;

  @override
  _ShoppingListState createState() {
    return new _ShoppingListState();
  }
}

// 请注意，我们通常命名State子类时带一个下划线，这表示其是私有的
class _ShoppingListState extends State<ShoppingList> {

  Set<Product> _shoppingCart = new Set<Product>();

  void _handleCartChanged(Product product, bool inCart) {
    // 为了通知框架它改变了它的内部状态，需要调用setState
    setState(() {
      print('_handleCartChanged:' + inCart.toString() + " product:" + product.name + " size:" + _shoppingCart.length.toString());
      if (inCart) {
        _shoppingCart.add(product);
      } else {
        _shoppingCart.remove(product);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        // 通过"widget属性"可以访问"ShoppingList"中的属性
        children: widget.products.map((Product product) {
        return new ShoppingListItem(
          product: product,
          inCart: _shoppingCart.contains(product),
          onCartChanged: _handleCartChanged,
        );
      }).toList(),
      ),
    );
  }

}