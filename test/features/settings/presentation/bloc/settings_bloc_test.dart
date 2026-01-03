import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sieuthoitiet/core/services/notification_service.dart';
import 'package:sieuthoitiet/features/settings/domain/entities/settings.dart';
import 'package:sieuthoitiet/features/settings/domain/repositories/settings_repository.dart';
import 'package:sieuthoitiet/features/settings/presentation/bloc/settings_bloc.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockNotificationService extends Mock implements NotificationService {}

class FakeSettingsEntity extends Fake implements SettingsEntity {}

void main() {
  late SettingsBloc settingsBloc;
  late MockSettingsRepository mockSettingsRepository;
  late MockNotificationService mockNotificationService;

  setUpAll(() {
    registerFallbackValue(FakeSettingsEntity());
  });

  setUp(() {
    mockSettingsRepository = MockSettingsRepository();
    mockNotificationService = MockNotificationService();

    // Default stub
    when(
      () => mockSettingsRepository.getSettings(),
    ).thenReturn(const SettingsEntity());
    when(
      () => mockSettingsRepository.saveSettings(any()),
    ).thenAnswer((_) async {});
    when(() => mockNotificationService.cancelAll()).thenAnswer((_) async {});
    when(
      () => mockNotificationService.unsubscribeFromAlerts(),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationService.unsubscribeFromMorningBrief(),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationService.unsubscribeFromEveningForecast(),
    ).thenAnswer((_) async {});

    settingsBloc = SettingsBloc(
      mockSettingsRepository,
      mockNotificationService,
    );
  });

  const initialSettings = SettingsEntity();
  const updatedSettings = SettingsEntity(
    tempUnit: TempUnit.fahrenheit,
  ); // Change unit

  group('SettingsBloc Tests', () {
    test('Initial state should contain default settings', () {
      expect(settingsBloc.state.settings, initialSettings);
    });

    blocTest<SettingsBloc, SettingsState>(
      'emits new state when UpdateSettings is added',
      build: () => settingsBloc,
      act: (bloc) => bloc.add(const UpdateSettings(updatedSettings)),
      expect: () => [const SettingsState(updatedSettings)],
      verify: (_) {
        verify(
          () => mockSettingsRepository.saveSettings(updatedSettings),
        ).called(1);
      },
    );
  });
}
