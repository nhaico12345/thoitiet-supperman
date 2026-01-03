// Cấu hình điều hướng (routing) sử dụng GoRouter.
// Định nghĩa các route: home, settings, locations, chat, wardrobe.

import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/locations/presentation/pages/locations_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/wardrobe/presentation/pages/wardrobe_page.dart';
import '../../features/wardrobe/presentation/pages/add_clothing_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/locations',
      builder: (context, state) => const LocationsPage(),
    ),
    GoRoute(path: '/chat', builder: (context, state) => const ChatPage()),
    GoRoute(
      path: '/wardrobe',
      builder: (context, state) => const WardrobePage(),
    ),
    GoRoute(
      path: '/wardrobe/add',
      builder: (context, state) => const AddClothingPage(),
    ),
  ],
);
