import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:trackflow/features/navegation/presentation/cubit/naviegation_cubit.dart';

import 'package:trackflow/core/router/app_routes.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentTab = context.select((NavigationCubit cubit) => cubit.state);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: AppTab.values.indexOf(currentTab),
        onTap: (index) {
          debugPrint('onTap: $index');
          final tab = AppTab.values[index];
          context.read<NavigationCubit>().setTab(tab);
          switch (tab) {
            case AppTab.dashboard:
              context.go(AppRoutes.dashboard);
              break;
            case AppTab.projects:
              context.go(AppRoutes.projects);
              break;
            case AppTab.notifications:
              context.go(AppRoutes.notifications);
              break;
            case AppTab.settings:
              context.go(AppRoutes.settingsAccount);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projects'),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Settings'),
        ],
      ),
    );
  }
}
