import 'package:flutter_test/flutter_test.dart';


/*
* mixin机制的几点考虑：(为了方便子类共享能力！)
*
* 1. 是因为dart不支持implement吗？不！支持的。
*
* 2. 为了更好的使得能力在不同子类中共享
*    ex. CanFixComputer 在 SoftwareEngineer 和 ITTeacher 共享
*    官方说法："当我们的继承父类不是同一个的，同时子类里面需要实现同样的功能时，Mixin显得尤为重要。"
*
* 3. 如何共享？子类不需要重复实现能力
*    ex. CanFixComputer 不需要在 SoftwareEngineer、ITTeacher 中重复实现
*
* 4. mixin 关键字？mixin AAA on Farther{}
*    作用：限制这种类的类型，只能被用来共享，因为不能被单独实例化！专用！
*    即：AAA 只会出现在with后面，xxxx with AAA
*
* 参考：
* 1. Flutter基础：理解Dart的Mixin继承机制：
* https://kevinwu.cn/p/ae2ce64/#场景
* 2. Flutter - Dart语法基础及mixin：
* https://www.jianshu.com/p/e359598b63ef
*
* */
abstract class Worker {
  void doWork();
}

class Engineer extends Worker {
  @override
  void doWork() {
    print('Engineer doWork');
  }
}

class Teacher extends Worker {
  @override
  void doWork() {
    print('Teacher doWork');
  }
}

class BuildingEngineer extends Engineer {

}

class ArtTeacher extends Teacher {

}



abstract class CanFixComputer {
  factory CanFixComputer._() {
    return null;
  }

  void fixComputer(){
    print('修电脑');
  }
}

abstract class CanDesignSoftware {
  // factory关键字结合_权限符避免外部实例化和扩展：
  factory CanDesignSoftware._() {
    return null;
  }

  void designSoftware(){
    print('设计软件');
  }
}

// 注意！ 这里是 with！不是 implements！
// 想一想好处是什么？
// 好处：SoftwareEngineer、ITTeacher 不再需要去实现同样的功能(CanFixComputer、CanDesignSoftware)
class SoftwareEngineer extends Engineer with CanFixComputer, CanDesignSoftware {

}

class ITTeacher extends Teacher with CanFixComputer {

}

/*
缺点：各个子类中需要重复实现接口！
class SoftwareEngineer extends Engineer implements CanFixComputer, CanDesignSoftware {
  @override
  void designSoftware() {
    print('设计软件');
  }

  @override
  void fixComputer() {
    print('SoftwareEngineer 修电脑');
  }
}

class ITTeacher extends Teacher implements CanFixComputer {
  @override
  void fixComputer() {
    print('ITTeacher 修电脑');
  }
}
 */

class First {
  void doPrint() {
    print('First');
  }
}

class Second {
  void doPrint() {
    print('Second');
  }
}

class Farther {

  Father() {
    init();
  }

  void init() {
    print('Farther init');
  }

  void doPrint() {
    print('Farther');
  }
}

class Son1 extends Farther with First, Second { // 这里如果，First、Second换下顺序会怎样？
}

class Son2 extends Farther with First implements Second {
}

class Son3 extends Farther with First implements Second {
  void doPrint() {
    print('Son3');
  }
}

// 当使用on关键字，自身不能作为父接口，表示该mixin只能在它的子类使用
mixin Third on Farther {
  void doPrint() {
    print('Third');
  }
}

class Son4 extends Farther with Third {

}

mixin AAA on Farther {
  void init() {
    print('AAA init');
    super.init();
    print('AAA end');
  }
}

mixin BBB on Farther {
  void init() {
    print('BBB init');
    super.init();
    print('BBB end');
  }
}

class Son5 extends Farther with AAA, BBB {
  void init() {
    print('Son5 init');
    super.init();
    print('Son5 end');
  }
}

void main() {

  // 多重继承场景
  test('multi_extends', (){
    Son5 son5 = Son5();
    son5.init();
    /*
    * Son5 init
      BBB init
      AAA init
      Farther init
      AAA end
      BBB end
      Son5 end
    * */
  });

  // mix机制的优先级、mixin关键字用法
  test('priority',() {
    Son1 son1 = Son1();
    son1.doPrint(); // Second : 最后mixin的优先级是最高,从低到高：Farther、Son1、First、Second

    Son2 son2 = Son2();
    son2.doPrint(); // First : "First中Mixin了Second的具体实现"

    Son3 son3 = Son3(); // Son3: 优先级最高的是在具体类中的方法
    son3.doPrint();

//    Third tsa = Third(); // 错误！mixin不能单独使用！
    Son4 son4 = Son4(); //
    son4.doPrint(); // Third
  });

  test('mixin', (){
    ITTeacher itTeacher = ITTeacher();
    itTeacher.doWork();
    itTeacher.fixComputer();

    SoftwareEngineer softwareEngineer = SoftwareEngineer();
    softwareEngineer.doWork();
    softwareEngineer.fixComputer();
    softwareEngineer.designSoftware();
  });
}