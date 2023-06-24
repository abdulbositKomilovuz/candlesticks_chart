import 'package:candlesticks/src/models/zones.dart';

enum FibonacciLevels { f0, f236, f382, f5, f618, f786, f1 }

class Fibonacci extends Zones {
  final double f0;
  final double? f236;
  final double? f382;
  final double? f5;
  final double? f618;
  final double? f786;
  final double f1;

  Fibonacci({
    required this.f0,
    required this.f236,
    required this.f382,
    required this.f5,
    required this.f618,
    required this.f786,
    required this.f1,
  });

  double get min => f1;
  double get max => f0;
}
