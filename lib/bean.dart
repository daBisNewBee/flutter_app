import 'package:json_annotation/json_annotation.dart';

// user.g.dart 将在我们运行生成命令后自动生成
part 'bean.g.dart'; // TODO: 无法生成

///这个标注是告诉生成器，这个类是需要生成Model类的
@JsonSerializable(nullable: false)
class Bean{
  Bean(this.name, this.email);

  String name;
  String email;
  //不同的类使用不同的mixin即可
  factory Bean.fromJson(Map<String, dynamic> json) => _$BeanFromJson(json);
  Map<String, dynamic> toJson() => _$BeanToJson(this);
}