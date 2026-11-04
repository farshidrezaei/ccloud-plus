import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_top_bar.dart';
import 'floating_mini_player.dart';
import 'sidebar_navigation.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: Row(
            children: [
              SidebarNavigation(router: GoRouter.of(context)),
              Expanded(
                child: Column(
                  children: [
                    const AppTopBar(),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        ),
        const FloatingMiniPlayer(),
      ],
    );
  }
}
