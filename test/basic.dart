void main() {
//  print('11111');

  // 括号的用法
  // 大括号。具体传递某一个参数，比较明确
  print('大括号用法:');
  funcBigKuoHao(name:'liu', age:'28', address:'shanghai');
  funcBigKuoHao(name:'liu', address:'shanghai');
  // 中括号。多个可选参数时，默认按顺序传值
  print('\n中括号用法:');
  funcMiddleKuoHao('liu', '28', 'shanghai');
  funcMiddleKuoHao('liu', 'shanghai');


  // Dart语法篇之函数的使用:
  // https://blog.csdn.net/u013064109/article/details/102965479
  
  // 位置参数、命名参数
  print('\n函数参数:');
  String ret = getDefaultErrorMsg();
  print('无参数 表达方式一 ret:$ret');
  ret = getDefaultErrorMsgEx;
  print('无参数 表达方式二 ret:$ret');
  ret = getDefaultErrorMsgOptionParam();
  print('可选参数 表达方式一 ret:$ret');
  ret = getDefaultErrorMsgOptionParam("not found!!");
  print('可选参数 表达方式二 ret:$ret');

  // 匿名函数、箭头函数
  /*
  * (num x) => x;//没有函数名，有必需的位置参数x
    (num x) {return x;}//等价于上面形式
    (int x, [int step]) => x + step;//没有函数名，有可选的位置参数step
    (int x, {int step1, int step2}) => x + step1 + step2;没有函数名，有可选的命名参
  *
  * */
}

funcBigKuoHao({String name, String age = '18', String address}) {
  print('name:$name age:$age address:$address');
}

funcMiddleKuoHao([String name, String age, String address]) {
  print('name:$name age:$age address:$address');
}

String getDefaultErrorMsg() => 'Unknown Error!';

get getDefaultErrorMsgEx => 'Unknown Error Ex!'; // 等价上面

// ?? 左边如果为空返回右边的值，否则不处理
String getDefaultErrorMsgOptionParam([String error]) => error ?? 'error为空时返回 可选位置参数返回值';
