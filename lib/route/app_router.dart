import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../pages/home_page.dart';
import 'app_pages.dart';

class AppRouter {
  late final GoRouter router;

  void initRouter() {
    router = GoRouter(
      initialLocation: AppPages.home,
      routes: [
        GoRoute(
          path: AppPages.home,
          builder: (context, state) => const HomePage(),
        ),
      ],
      errorBuilder: (context, state) =>
          const Scaffold(body: Center(child: Text('404'))),
    );
  }
}
