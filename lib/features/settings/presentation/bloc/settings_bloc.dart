// File: settings_bloc.dart
// Mô tả: BLoC quản lý cài đặt người dùng.
// Xử lý FCM topic subscriptions cho thông báo sáng/tối và cảnh báo.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;
  final NotificationService _notificationService;

  SettingsBloc(this._settingsRepository, this._notificationService)
    : super(SettingsState(_settingsRepository.getSettings())) {
    on<UpdateSettings>(_onUpdateSettings);
  }

  Future<void> _onUpdateSettings(
    UpdateSettings event,
    Emitter<SettingsState> emit,
  ) async {
    await _settingsRepository.saveSettings(event.settings);
    emit(SettingsState(event.settings));

    // Run notification updates in background to avoid blocking UI
    _handleNotificationChanges(event.settings).ignore();
  }

  Future<void> _handleNotificationChanges(SettingsEntity settings) async {
    // If notifications are globally disabled
    if (!settings.enableNotifications) {
      await _notificationService.cancelAll();
      await _notificationService.unsubscribeFromAlerts();
      await _notificationService.unsubscribeFromMorningBrief();
      await _notificationService.unsubscribeFromEveningForecast();
      return;
    }

    // ===== FCM TOPIC SUBSCRIPTIONS =====

    // 1. Weather Alerts Topic
    if (settings.enableAlerts) {
      await _notificationService.subscribeToAlerts();
    } else {
      await _notificationService.unsubscribeFromAlerts();
    }

    // 2. Morning Brief Topic
    if (settings.enableMorningBrief) {
      await _notificationService.subscribeToMorningBrief();
    } else {
      await _notificationService.unsubscribeFromMorningBrief();
    }

    // 3. Evening Forecast Topic
    if (settings.enableEveningForecast) {
      await _notificationService.subscribeToEveningForecast();
    } else {
      await _notificationService.unsubscribeFromEveningForecast();
    }
  }
}
