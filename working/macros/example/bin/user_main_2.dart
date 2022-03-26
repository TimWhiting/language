import 'package:macro_proposal/hello.dart';

void main(List<String> arguments) {
  final c = MyClass.named('foo', 1);
  print(c.val);
  print(c.val2);
}

class Class2 {}

abstract class MyClass extends Class2 {
  MyClass();
  @Hello()
  external factory MyClass.named(String val, int val2);
}
