// Dùng để hiển thị theo đơn vị người dùng chọn trong cài đặt.

import '../../features/settings/domain/entities/settings.dart';

class UnitConverter {
  static double convertTemp(double tempC, TempUnit unit) {
    if (unit == TempUnit.celsius) return tempC;
    return (tempC * 9 / 5) + 32;
  }

  static double convertSpeed(double speedKmh, SpeedUnit unit) {
    if (unit == SpeedUnit.kmh) return speedKmh;
    return speedKmh * 0.621371;
  }

  static double convertPressure(double pressureHpa, PressureUnit unit) {
    if (unit == PressureUnit.hpa) return pressureHpa;
    return pressureHpa * 0.02953;
  }
}
