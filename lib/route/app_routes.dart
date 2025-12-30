import 'package:go_router/go_router.dart';

import '../pages/home_page.dart';
import 'app_pages.dart';

class AppRoutes {
  static final routes = GoRouter(
    initialLocation: AppPages.home,
    routes: [
      GoRoute(
        path: AppPages.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
