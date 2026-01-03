import 'package:flutter_test/flutter_test.dart';
import 'package:sieuthoitiet/core/utils/unit_converter.dart';
import 'package:sieuthoitiet/features/settings/domain/entities/settings.dart';

void main() {
  group('UnitConverter Tests', () {
    test('Convert Celsius to Fahrenheit', () {
      expect(UnitConverter.convertTemp(0, TempUnit.fahrenheit), 32);
      expect(UnitConverter.convertTemp(100, TempUnit.fahrenheit), 212);
      // 25C -> 77F
      expect(UnitConverter.convertTemp(25, TempUnit.fahrenheit), 77);
    });

    test('Convert Fahrenheit to Celsius (Logic check)', () {
      // Our converter usually takes C as input and converts to target unit.
      // If input is C, and target is C, return C.
      expect(UnitConverter.convertTemp(25, TempUnit.celsius), 25);
    });

    test('Convert Speed km/h to mph', () {
      // 1 km/h = 0.621371 mph
      expect(UnitConverter.convertSpeed(10, SpeedUnit.mph), closeTo(6.21, 0.01));
    });

    test('Convert Pressure hPa to inHg', () {
      // 1 hPa = 0.02953 inHg
      expect(UnitConverter.convertPressure(1000, PressureUnit.inhg), closeTo(29.53, 0.01));
    });
  });
}
