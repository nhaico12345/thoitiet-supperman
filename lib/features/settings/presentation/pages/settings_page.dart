// Màn hình cài đặt ứng dụng.
// Cho phép thay đổi theme, đơn vị đo, bật/tắt thông báo và xem thông tin ứng dụng.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/settings.dart';
import '../bloc/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              _buildSectionHeader(context, 'Giao diện'),
              _buildThemeSelector(context, state),

              _buildSectionHeader(context, 'Đơn vị'),
              _buildUnitSelector(
                context,
                title: 'Nhiệt độ',
                value: state.settings.tempUnit == TempUnit.celsius
                    ? 'Độ C (°C)'
                    : 'Độ F (°F)',
                onTap: () {
                  final newUnit = state.settings.tempUnit == TempUnit.celsius
                      ? TempUnit.fahrenheit
                      : TempUnit.celsius;
                  context.read<SettingsBloc>().add(
                    UpdateSettings(state.settings.copyWith(tempUnit: newUnit)),
                  );
                },
              ),
              _buildUnitSelector(
                context,
                title: 'Tốc độ gió',
                value: state.settings.speedUnit == SpeedUnit.kmh
                    ? 'km/h'
                    : 'mph',
                onTap: () {
                  final newUnit = state.settings.speedUnit == SpeedUnit.kmh
                      ? SpeedUnit.mph
                      : SpeedUnit.kmh;
                  context.read<SettingsBloc>().add(
                    UpdateSettings(state.settings.copyWith(speedUnit: newUnit)),
                  );
                },
              ),
              _buildUnitSelector(
                context,
                title: 'Áp suất',
                value: state.settings.pressureUnit == PressureUnit.hpa
                    ? 'hPa'
                    : 'inHg',
                onTap: () {
                  final newUnit =
                      state.settings.pressureUnit == PressureUnit.hpa
                      ? PressureUnit.inhg
                      : PressureUnit.hpa;
                  context.read<SettingsBloc>().add(
                    UpdateSettings(
                      state.settings.copyWith(pressureUnit: newUnit),
                    ),
                  );
                },
              ),

              _buildSectionHeader(context, 'Thông báo & Cảnh báo'),
              SwitchListTile(
                title: const Text('Bật thông báo'),
                subtitle: const Text('Nhận thông báo thời tiết hàng ngày'),
                value: state.settings.enableNotifications,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(
                    UpdateSettings(
                      state.settings.copyWith(enableNotifications: value),
                    ),
                  );
                },
                secondary: const Icon(
                  Icons.notifications_active,
                  color: Colors.blue,
                ),
              ),
              if (state.settings.enableNotifications) ...[
                ListTile(
                  leading: const SizedBox(width: 24), // Indent
                  title: const Text('Chào buổi sáng'),
                  subtitle: Text(state.settings.morningTime),
                  trailing: Switch(
                    value: state.settings.enableMorningBrief,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(
                        UpdateSettings(
                          state.settings.copyWith(enableMorningBrief: value),
                        ),
                      );
                    },
                  ),
                  onTap: () => _showTimePicker(
                    context,
                    state.settings.morningTime,
                    (newTime) {
                      context.read<SettingsBloc>().add(
                        UpdateSettings(
                          state.settings.copyWith(morningTime: newTime),
                        ),
                      );
                    },
                  ),
                ),
                ListTile(
                  leading: const SizedBox(width: 24), // Indent
                  title: const Text('Dự báo tối'),
                  subtitle: Text(state.settings.eveningTime),
                  trailing: Switch(
                    value: state.settings.enableEveningForecast,
                    onChanged: (value) {
                      context.read<SettingsBloc>().add(
                        UpdateSettings(
                          state.settings.copyWith(enableEveningForecast: value),
                        ),
                      );
                    },
                  ),
                  onTap: () => _showTimePicker(
                    context,
                    state.settings.eveningTime,
                    (newTime) {
                      context.read<SettingsBloc>().add(
                        UpdateSettings(
                          state.settings.copyWith(eveningTime: newTime),
                        ),
                      );
                    },
                  ),
                ),
                SwitchListTile(
                  title: const Padding(
                    padding: EdgeInsets.only(left: 24.0),
                    child: Text('Cảnh báo nguy hiểm'),
                  ),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(left: 24.0),
                    child: Text('Mưa lớn, bão, UV cao...'),
                  ),
                  value: state.settings.enableAlerts,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(
                      UpdateSettings(
                        state.settings.copyWith(enableAlerts: value),
                      ),
                    );
                  },
                ),
              ],

              const Divider(height: 40),

              _buildSectionHeader(context, 'Thông tin'),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text('Về ứng dụng'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showAboutAppDialog(context),
              ),
              ListTile(
                leading: const Icon(
                  Icons.description_outlined,
                  color: Colors.blue,
                ),
                title: const Text('Điều khoản sử dụng'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showTermsDialog(context),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về ứng dụng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cloud, size: 50, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Siêu Thời Tiết',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text('Phiên bản 1.0.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            const Text(
              'Nhà phát triển:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'TRẦN ĐÌNH ĐĂNG',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue,
              ),
            ),
            const Text('SINH VIÊN ĐẠI HỌC HÀ TĨNH'),
            const Text('LỚP K16-CNTT'),
            const Text('Khoa Kỹ thuật - công nghệ'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Điều khoản sử dụng'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Chấp nhận điều khoản',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Bằng việc sử dụng ứng dụng này, bạn đồng ý tuân thủ các điều khoản và điều kiện được quy định dưới đây.',
              ),
              SizedBox(height: 10),
              Text(
                '2. Sử dụng dịch vụ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Ứng dụng cung cấp thông tin thời tiết dựa trên dữ liệu từ các nguồn uy tín. Tuy nhiên, chúng tôi không chịu trách nhiệm về tính chính xác tuyệt đối của dữ liệu.',
              ),
              SizedBox(height: 10),
              Text(
                '3. Quyền riêng tư',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Chúng tôi tôn trọng quyền riêng tư của bạn. Dữ liệu vị trí chỉ được sử dụng để cung cấp thông tin thời tiết tại khu vực của bạn và không được chia sẻ với bên thứ ba.',
              ),
              SizedBox(height: 10),
              Text(
                '4. Thay đổi điều khoản',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Chúng tôi có quyền thay đổi các điều khoản này bất cứ lúc nào mà không cần báo trước.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTimePicker(
    BuildContext context,
    String currentTime,
    Function(String) onTimeSelected,
  ) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (pickedTime != null) {
      final hour = pickedTime.hour.toString().padLeft(2, '0');
      final minute = pickedTime.minute.toString().padLeft(2, '0');
      onTimeSelected('$hour:$minute');
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(color: Colors.blue),
      ),
    );
  }

  Widget _buildThemeSelector(BuildContext context, SettingsState state) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: AppThemeMode.values.map((mode) {
          return RadioListTile<AppThemeMode>(
            title: Text(_getThemeName(mode)),
            value: mode,
            // ignore: deprecated_member_use
            groupValue: state.settings.themeMode,
            // ignore: deprecated_member_use
            onChanged: (value) {
              if (value != null) {
                context.read<SettingsBloc>().add(
                  UpdateSettings(state.settings.copyWith(themeMode: value)),
                );
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUnitSelector(
    BuildContext context, {
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Sáng';
      case AppThemeMode.dark:
        return 'Tối';
      case AppThemeMode.system:
        return 'Theo hệ thống';
    }
  }
}
