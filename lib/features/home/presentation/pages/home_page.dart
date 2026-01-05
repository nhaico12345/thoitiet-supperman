// Màn hình chính hiển thị thông tin thời tiết.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/weather_skeleton_widget.dart';
import '../../../../shared/widgets/weather_refresh_indicator.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/services/device_service.dart';
import '../../../settings/domain/entities/settings.dart';
import '../../../settings/presentation/bloc/settings_bloc.dart';
import '../bloc/weather_bloc.dart';
import '../widgets/weather_background_widget.dart';
import '../../../../core/services/share_service.dart';
import 'layouts/home_mobile_layout.dart';
import 'layouts/home_tablet_layout.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final WeatherBloc _weatherBloc;

  @override
  void initState() {
    super.initState();
    _weatherBloc = getIt<WeatherBloc>();
    _initApp();
  }

  Future<void> _initApp() async {
    final deviceService = getIt<DeviceService>();
    // Xin quyền vị trí và thông báo ngay khi mở app
    await deviceService.requestInitialPermissions();

    if (!mounted) return;

    // Lấy trạng thái quyền vị trí ngay sau khi xin quyền
    final locationPermission = await Permission.location.status;

    if (!mounted) return;

    // Force refresh lấy dữ liệu thời tiết
    _weatherBloc.add(const GetWeather(forceRefresh: true));

    // Hiển thị thông báo nếu quyền vị trí bị từ chối
    if (locationPermission.isDenied || locationPermission.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Đang sử dụng vị trí mặc định. Hãy cấp quyền vị trí để có trải nghiệm tốt hơn.',
          ),
          action: SnackBarAction(
            label: 'Cài đặt',
            onPressed: () => openAppSettings(),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }

    await deviceService.checkAndShowAutoStartDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: _weatherBloc, child: const HomeView());
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WeatherBloc, WeatherState>(
      listener: (context, state) {
        if (state is WeatherError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error.toString())));
        }
        if (state is WeatherLoaded && state.aiErrorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.aiErrorMessage!),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == WeatherStatus.loading) {
          return const Scaffold(body: WeatherSkeletonWidget());
        }

        int? weatherCode;
        String title = 'Thời tiết ProMax';
        if (state.weather != null) {
          weatherCode = state.weather!.weatherCode;
          if (state.weather!.locationName != null) {
            title = state.weather!.locationName!;
          }
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(title, style: const TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // Share button
              if (state.weather != null)
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Chia sẻ',
                  onPressed: () {
                    ShareWeatherDialog.show(
                      context,
                      state.weather!,
                      ootdAdvice: state.ootdAdvice,
                    );
                  },
                ),
              IconButton(
                icon: const Icon(Icons.checkroom),
                tooltip: 'Tủ đồ cộng đồng',
                onPressed: () {
                  context.push('/wardrobe');
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () async {
                  await context.push('/settings');
                  if (context.mounted) {
                    context.read<WeatherBloc>().add(const GetWeather());
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () async {
                  await context.push('/locations');
                  if (context.mounted) {
                    context.read<WeatherBloc>().add(const GetWeather());
                  }
                },
              ),
            ],
          ),
          body: WeatherBackgroundWidget(
            weatherCode: weatherCode,
            isDay: DateTime.now().hour > 6 && DateTime.now().hour < 18,
            child: EnhancedRefreshIndicator(
              onRefresh: () async {
                context.read<WeatherBloc>().add(const GetWeather());
              },
              onRefreshComplete: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white),
                        SizedBox(width: 8),
                        Text('Đã cập nhật!'),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, settingsState) {
                  return _buildBody(context, state, settingsState.settings);
                },
              ),
            ),
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              context.push('/chat');
            },
            backgroundColor: Colors.white.withValues(alpha: 0.9),
            child: const Icon(Icons.smart_toy_outlined, color: Colors.blue),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeatherState state,
    SettingsEntity settings,
  ) {
    if (state is WeatherLoading) {
      return const WeatherSkeletonWidget();
    }
    if (state is WeatherLoaded) {
      final weather = state.weather;
      if (weather == null) return const SizedBox();

      return ResponsiveBuilder(
        mobileBuilder: (context) => HomeMobileLayout(
          weather: weather,
          settings: settings,
          recommendations: state.recommendations,
          isAILoading: state.isAILoading,
          weatherSummary: state.weatherSummary,
          ootdAdvice: state.ootdAdvice,
          smartWarnings: state.smartWarnings,
        ),
        tabletBuilder: (context) => HomeTabletLayout(
          weather: weather,
          settings: settings,
          recommendations: state.recommendations,
          isAILoading: state.isAILoading,
          weatherSummary: state.weatherSummary,
        ),
      );
    }
    if (state is WeatherError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Lỗi: ${state.error}',
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  context.read<WeatherBloc>().add(const GetWeather()),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }
    return const SizedBox();
  }
}
