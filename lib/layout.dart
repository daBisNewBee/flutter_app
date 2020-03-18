import 'package:flutter/material.dart';

/*
*
*  "创建布局"摘要：
*
*  1. 对齐 widgets
*     mainAxisAlignment和crossAxisAlignment
*
*  2. 调整 widgets
*     Expanded
*
*  3. 聚集 widgets
*     MainAxisSize.min
*
*  4. 嵌套行和列
*     Container
*
*  5. 常用布局widgets
*     a. 标准 widgets：
*         1. Container
*         2. GridView
*         3. ListView
*         4. Stack
*     b. Material Components：
*         1. Card
*         2. ListTile
* */
class MyLayoutApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    print('MyLayoutApp build:');
    Widget titleSection = new Container(
      padding: const EdgeInsets.all(32.0),// 上下左右各添加32像素补白
      child: new Row(
        children: <Widget>[
          new Expanded(
              flex:1, // 用于多个child时，当前child的大小占比，类似于"weight"，默认弹性系数是1
              child: new Column( // 可以去掉"Expanded"，但是右边的star会紧挨着标题
              // //显式指定对齐方式为左对齐，排除对齐干扰
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Container也是一个widget，允许您自定义其子widget。如果要添加填充，边距，边框或背景色，请使用Container来设置
                new Container(
                  // 上下各添加8像素补白
                  padding: const EdgeInsets.symmetric(vertical:8.0),
                  child: new Text(
                      'Oeschinen Lake Campground',
                    style: new TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                new Text(
                  'Kandersteg, Switzerland',
                  style: new TextStyle(
                    color: Colors.grey[500]
                  ),
                )
            ],
          )),
          new FavoriteWidget(),
        ],
      ),
    );

    Column buildButtonColumn(IconData icon, String label) {
      Color color = Theme.of(context).primaryColor;
      return new Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Icon(icon, color: color),
          new Container(
            margin: const EdgeInsets.only(top:8.0),
            child: new Text(
              label,
              style: new TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
                color: color,
              ),
            ),
          )
        ],
      );
    }

    Widget buttonSection = new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,// 平均的分配每个列占据的行空间，否则挤在一起了！
        children: <Widget>[
          buildButtonColumn(Icons.call, 'CALL'),
          buildButtonColumn(Icons.near_me, 'ROUTE'),
          buildButtonColumn(Icons.share, 'SHARE'),
        ],
      ),
    );

    Widget textSection = new Container(
      padding: const EdgeInsets.all(32.0),
      child: new Text('Lake Oeschinen lies at the foot of '
          'the Blüemlisalp in the Bernese Alps. Situated '
          '1,578 meters above sea level, it is one of the '
          'larger Alpine Lakes. A gondola ride from Kandersteg, '
          'followed by a half-hour walk through pastures and '
          'pine forest, leads you to the lake, which warms to '
          '20 degrees Celsius in the summer. Activities enjoyed '
          'here include rowing, and riding the summer toboggan '
          'run.',
          softWrap: true),
    );
    final title = '构建布局';

    /*
    //  一般来说, app没有使用Scaffold的话，会有一个黑色的背景和一个默认为黑色的文本颜色。
    return new Container(
      decoration: new BoxDecoration(color: Colors.white),
      child: new Center(
        child: new Text('Hello World',
            textDirection: TextDirection.ltr,
            style: new TextStyle(fontSize: 40.0, color: Colors.black87)),
      ),
    );
     */
    return new MaterialApp(
      title: title,
      theme: new ThemeData(
        primaryColor: Colors.blue,
      ),
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text(title),
        ),
        body: new ListView(
          children: <Widget>[
            new Stack( // 使用"Stack"来组织需要重叠的widget
              alignment: Alignment.center,
              children: <Widget>[
                new Image.asset(
                  'images/lake.jpg',
                  width: 600.0,
                  height: 240.0,
                  fit: BoxFit.cover,
                ),
                new Container(
                  decoration: new BoxDecoration(
                    color: Colors.black45,
                  ),
                  child: new Text(
                    'Fuck You Title.',
                    style: new TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            titleSection,
            buttonSection,
            textSection,
            new Row(
              mainAxisSize: MainAxisSize.min,// 将孩子紧密聚集在一起，否则会分散开. TODO:未验证？
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Icon(Icons.star, color: Colors.green[500]),
                new Icon(Icons.star, color: Colors.green[500]),
                new Icon(Icons.star, color: Colors.green[500]),
                new Icon(Icons.star, color: Colors.black),
                new Icon(Icons.star, color: Colors.black),
            ],),
            new ListTile(
              leading: new Icon(Icons.map),
              title: new Text('Map'),
            ),
            new ListTile(
              leading: new Icon(Icons.photo),
              title: new Text('Album'),
            ),
            new ListTile(
              leading: new Icon(Icons.phone),
              title: new Text('Phone'),
            ),
            new SizedBox( // 使用SizedBox来限制Card的大小
              height: 210.0,
              child: new Card( // Card具有圆角和阴影，这使它有一个3D效果;通常与ListTile一起使用
                elevation: 24.0, // 控制投影效果
                child: new Column(
                  children: <Widget>[
                    /*
                    * ListTile:
                    * 1. 是Material Components库中的一个专门的行级widget，
                    * 2. 用于创建包含最多3行文本和可选的行前和行尾图标的行。
                    * 3. ListTile在Card或ListView中最常用
                    * 4. 比起Row不易配置，但更易于使用
                    * */
                    new ListTile(
                      title: new Text('1625 Main Street',
                          style: new TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: new Text('My City, CA 99984'),
                      trailing: new Text('This is trailing.'),
                      leading: new Icon(
                        Icons.restaurant_menu,
                        color: Colors.blue[500],
                      ),
                    ),
                    new Divider(),
                    new ListTile(
                      title: new Text('(408) 555-1212',
                          style: new TextStyle(fontWeight: FontWeight.w500)),
                      leading: new Icon(
                        Icons.contact_phone,
                        color: Colors.blue[500],
                      ),
                    ),
                    new ListTile(
                      title: new Text('costa@example.com'),
                      leading: new Icon(
                        Icons.contact_mail,
                        color: Colors.blue[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class FavoriteWidget extends StatefulWidget {

  @override
  _FavoriteWidgetState createState() => new _FavoriteWidgetState();

}

class _FavoriteWidgetState extends State<FavoriteWidget> {
  bool _isFavorited = true;
  int _favoriteCount = 41;

  @override
  Widget build(BuildContext context) {
    print('_FavoriteWidgetState build:' + '$_favoriteCount');
    return new Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        new Container( // TODO: 这里为什么要加个Container？
          padding:EdgeInsets.all(0.0),
          child: new IconButton(
              icon: new Icon(_isFavorited ? Icons.star : Icons.star_border,
              color : Colors.red),
              onPressed: _toggleFavorite),
        ),

        // 当文本在40和41之间变化时，将文本放在SizedBox中并设置其宽度
        // 可防止出现明显的“跳跃” ，因为这些值具有不同的宽度。
//        Text('$_favoriteCount'),
        new SizedBox(
          width: 28.0,
          child: new Text('$_favoriteCount'), // _favoriteCount.toString()
        ),
      ],
    );
  }

  void _toggleFavorite() {

    /*
    * 关于"setState"的几个考虑：
    * 1. 为什么 放在逻辑之前、之后执行，ui都会更新？
    *    标记到脏链表，等待更新帧信号的来临从而刷新需要重构的界面
    * 2. 为什么 每次点击，都会执行到"_FavoriteWidgetState build" ？
    * */
    setState(() {
    });

    setState(() {
      if (_isFavorited) {
        _favoriteCount-=1;
      } else {
        _favoriteCount+=1;
      }
      _isFavorited = !_isFavorited;
    });

    setState(() {
    });

  }
}