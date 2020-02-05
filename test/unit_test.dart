
import 'dart:convert';
import 'dart:io';

import 'package:flutter_app/user.dart';
import 'package:flutter_test/flutter_test.dart';

// 单元测试
void main() {
  test("11111", (){
    print('start.....');
    var answer = 42;
    expect(answer, 42);
    print('end.....');
  });

  test('json_inner', (){
    String jsonStr = "{\"name\": \"John Smith\",\"email\": \"john@example.com\", \"age\":\"99\"}";
    // 1. "内连序列化JSON"，避免使用这种方式！ 缺点：运行时才知道值得类型，易错
    Map<String, dynamic> map = json.decode(jsonStr);
    print('result: $map');
    print('name: ${map['name']}'); // 这里输错就取不到实际值了！
    print('email: ${map['email']}');
    print('age: ${map['age']}');

    // 2. "在模型类中序列化JSON", 建议！
    // 优点：可以具有类型安全、自动补全字段（name和email）以及编译时异常
    var user = User.fromJson(map);
    print('user: $user');
    print('user: ${user.name}');
    print('user: ${user.email}');
    print('age: ${user.age}');

    String encode2JsonStr = json.encode(user); // map 也可以encode
    print('json.encode: $encode2JsonStr');

    @deprecated
    var encode2JsonMap = user.toJson();
    print('user.toJson: $encode2JsonMap');
  });

  test('httpclient', () async {
    var url = 'https://httpbin.org/ip';
    var httpClient = HttpClient();

    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();
    if (response.statusCode == HttpStatus.OK) {
      var jsonStr = await response.transform(utf8.decoder).join();
      var data = json.decode(jsonStr);
      print('result :' + data['origin']);
    } else {
      print('ERROR:' + response.statusCode.toString());
    }
  });
}