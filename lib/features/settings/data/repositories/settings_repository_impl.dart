// Lưu và đọc các tùy chọn: đơn vị đo, theme, thông báo.

import 'package:hive/hive.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final Box box;

  SettingsRepositoryImpl(this.box);

  @override
  SettingsEntity getSettings() {
    final model = box.get('settings');
    if (model != null && model is SettingsModel) {
      return model;
    }
    return const SettingsEntity(); // Default
  }

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    await box.put('settings', SettingsModel.fromEntity(settings));
  }
}
