
class User {
  final String name;
  final String email;
  final int age;

  User(this.name, this.email, this.age);

  User.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        email = json['email'],
        age = int.parse(json['age']);

  Map<String, dynamic> toJson() =>
      {
        'name' : name,
        'email' : email,
        'age' : age,
      };


  @override
  String toString() {
    return 'User{name: $name, email: $email, age: $age}';
  }

}