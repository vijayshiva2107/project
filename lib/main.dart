import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/freelancer_provider.dart';
import 'screens/home_screen.dart';
import 'screens/browse_screen.dart';
import 'screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init failed (expected if missing google-services.json): $e');
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => FreelancerProvider(),
      child: const LocalHireApp(),
    ),
  );
}

class LocalHireApp extends StatelessWidget {
  const LocalHireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LocalHire v2',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _idx = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    BrowseScreen(),
    RegisterScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) {
          if (i == 1) context.read<FreelancerProvider>().resetFilters();
          setState(() => _idx = i);
        },
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.accent.withOpacity(0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppTheme.accent),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded, color: AppTheme.accent),
            label: 'Browse',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle_rounded, color: AppTheme.accent),
            label: 'List Services',
          ),
        ],
      ),
    );
  }
}
