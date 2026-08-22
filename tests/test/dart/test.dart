#!/usr/bin/env dart
// Dart syntax highlighting test file
// Covers: keywords, types, strings, numbers, comments, annotations

library sample.highlight;

import 'dart:async' deferred as asyncLib show Future hide Stream;
import 'package:meta/meta.dart';
export 'src/shape.dart';
part 'extra.dart';

/// A documentation comment for the sealed hierarchy
@immutable
sealed class Shape {
  const Shape();
  String draw();
}

/**
 * Multi-line documentation comment
 * for the Circle class
 */
final class Circle extends Shape with Drawable {
  final double radius;
  const Circle(this.radius);

  @override
  String draw() => 'circle r=$radius';
}

mixin Drawable {
  void render() {}
}

enum Status { pending, done }

extension type Id(int value) {
  bool get isValid => value > 0;
}

extension StringX on String {
  String get shout => toUpperCase();
}

typedef Json = Map<String, Object?>;

Future<void> main() async {
  const answer = 42;
  const hex = 0xDEAD_BEEF;
  const big = 1_000_000;
  const pi = 3.1415;
  const sci = 1.42e5;
  const hex2 = 0x2A;

  var name = 'Dart';
  var msg = "Hello $name!";
  var expr = "2+2=${1 + 1}";
  var raw = r'This is $not interpolation\n';
  var raw2 = r"also raw $name";
  var multi = '''
    line 1
    line 2 $name
  ''';
  var multi2 = """
    double triple $answer
  """;
  var escapes = 'tab\t quote\' hex\x41 unicode\u0041 emoji\u{1F600} dollar\$';

  /* nested /* comment */ still comment */

  String? nullable;
  var value = nullable ?? 'default';
  var len = nullable?.length;
  var forced = nullable!.length;

  var list = <int>[1, 2, 3];
  var map = {'a': 1, 'b': 2};
  var record = (1, name: 'x');
  List<int>? extra;
  var spread = [...list, ...?extra];

  switch (Status.done) {
    case Status.done when true:
      break;
    default:
      throw StateError('nope');
  }

  try {
    assert(answer == 42);
  } on FormatException catch (e, st) {
    rethrow;
  } finally {
    print(e);
  }

  var symbol = #status;
  var cascade = list
    ..add(4)
    ..sort();

  late final int delayed;
  requiredNamed(value: 1);
  yield* const Stream.empty();
}

void requiredNamed({required int value}) {}

int operator [](int index) => index;

abstract interface class Box {
  factory Box() = _Box;
}

base class _Box implements Box {
  static const empty = 0;
  external void native();
}

int divide(int a, int b) => a ~/ b;
