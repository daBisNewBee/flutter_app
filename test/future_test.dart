import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/*
*
* Dart单线程模型的几个关键字：
*  1. 单线程
*  为什么单线程也能异步？通过事件循环
*
*  2. Future
*  到底是什么？异步任务的封装
*  Event Queue 的任务建立提供了一层封装，
*
*  3. await 与 async
*  到底有什么用？实现协程，异步等待
*  如何实现异步？将等待语句扔到Event Loop，
* 一旦有了结果，Event Loop 就会把它从 Event Queue 中取出，等待代码继续执行。
*
*  4. Isolate
*  有什么用？
*  Dart 中的多线程，可以实现并发
*  有自己的事件循环与 Queue，独占资源
*  Isolate 之间可以通过消息机制进行单向通信，这些传递的消息通过对方的事件循环驱动对方进行异步处理
*
*
* "then 会在 Future 函数体执行完毕后立刻执行，无论是共用同一个事件循环还是进入下一个微任务。"
*
* */
void main() async {

  //then 4 会加入微任务队列，尽快执行
//  Future(() => null).then((_) => print('then 4'));
  // Future 函数体是 null，这意味着它不需要也没有事件循环，因此后续的 then 也无法与它共享。
  // 在这种场景下，Dart 会把后续的 then 放入微任务队列，在下一次事件循环中执行

//  asyncDemo();
//  testAll();
//  testAll2();
//  asyncTest();
  asyncTest2();

  test('future', (){
  });
}

Future<String> fetchContent() =>
    Future<String>
        .delayed(Duration(seconds: 0), ()=>'hello') // TODO: 这里改成2，调用会异常
        .then((x) =>'$x fuck you!');

// 这是异步等待，区别与阻塞等待！
func() async => print(await fetchContent());

void asyncTest() {
  print('before func');
  func();
  print('after func');
//  sleep(Duration(seconds: 5));
  /*
  * before func
    after func
    hello fuck you!
    *
    * 考虑：为什么hello 在后面？
    *  await 与 async 只对调用上下文的函数有效，并不向上传递。
    * 因此对于这个案例而言，func 是在异步等待。
    *
  * */
}

void asyncTest2() async {
  print('before func');
  await func();
  print('after func');
//  sleep(Duration(seconds: 5));
  /*
  * before func
    hello fuck you!
    after func
  *
  * 这样写，会在主函数里等待！
  * */
}


Future asyncDemo() async {
  Future<Null> future = new Future(() => null);
  await future.then((_){
    // 异步操作逻辑
    print('then');
  }).then((_){
    // 异步完成时的回调
    print("when Complete");
  }).catchError((_){
    // 捕获异常或者异步出错时的回调
    print('catchError');
  });
}

void testAll() {
  Future f3 = Future(() => null);
  Future f1 = Future(() => null);
  Future f2 = Future(() => null);
  Future f4 = Future(() => null);
  Future f5 = Future(() => null);

  f2.then((_) => print('f2. then -> f2'));
  f4.then((_) => print('f4. then -> f4'));
  f3.then((_) => print('f3. then -> f3'));

  f5.then((_){
    print('f5. then -> f5');
    Future(() => print("f5.then -> new Future"));
    f1.then((_) => print('f1. then -> f1'));
  });

  /*
  * f3. then -> f3
    f2. then -> f2
    f4. then -> f4  // 执行顺序只与Future的创建顺序有关

    f5. then -> f5
    f1. then -> f1  // 多个then嵌套时，先执行外面的，再执行里面的
    f5.then -> new Future // 等嵌套then结束后，再执行
  *
  * */

}

void testAll2() {
  Future(() => print('f1'));// 声明一个匿名 Future
  Future fx = Future(() =>  null);// 声明 Future fx，其执行体为 null

// 声明一个匿名 Future，并注册了两个 then。在第一个 then 回调里启动了一个微任务
  Future(() => print('f2')).then((_) {
    print('f3');
    scheduleMicrotask(() => print('f4'));
  }).then((_) => print('f5'));

// 声明了一个匿名 Future，并注册了两个 then。第一个 then 是一个 Future
  Future(() => print('f6'))
      .then((_) => Future(() => print('f7')))
      .then((_) => print('f8'));

// 声明了一个匿名 Future
  Future(() => print('f9'));

// 往执行体为 null 的 fx 注册了了一个 then
  fx.then((_) => print('f10'));

// 启动一个微任务
  scheduleMicrotask(() => print('f11'));
  print('f12');

  /*
  * f12  其他语句都是异步任务，所以先打印 f12
    f11  剩下的异步任务中，微任务队列优先级最高
    f1
    f10  执行体是 null，相当于执行完毕,微任务队列优先级最高
    f2
    f3
    f5
    f4
    f6
    f9
    f7
    f8
  *
  * */
}



