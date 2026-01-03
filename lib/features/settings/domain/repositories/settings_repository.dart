// Interface repository cho cài đặt người dùng.
// Định nghĩa phương thức getSettings và saveSettings.

import '../entities/settings.dart';

abstract class SettingsRepository {
  SettingsEntity getSettings();
  Future<void> saveSettings(SettingsEntity settings);
}
