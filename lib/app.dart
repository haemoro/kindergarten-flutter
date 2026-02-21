import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'screens/home/home_screen.dart';
import 'screens/search/search_screen.dart';
import 'screens/detail/detail_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/compare/compare_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'providers/theme_provider.dart';

class KindergartenApp extends ConsumerWidget {
  final bool showOnboarding;

  const KindergartenApp({super.key, this.showOnboarding = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: '유치원 찾기',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: _createRouter(showOnboarding),
      debugShowCheckedModeBanner: false,
    );
  }
}

// 라우터 설정
GoRouter _createRouter(bool showOnboarding) => GoRouter(
  initialLocation: showOnboarding ? '/onboarding' : '/home',
  routes: [
    // 온보딩
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    // 메인 네비게이션 (하단 탭)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return _MainNavigationScreen(navigationShell: navigationShell);
      },
      branches: [
        // 탭 1: 홈
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        // 탭 2: 검색
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        // 탭 3: 지도
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const MapScreen(),
            ),
          ],
        ),
        // 탭 4: 즐겨찾기
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
        // 탭 5: 설정
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    // Push 화면 (전체 화면, 탭 바 없음)
    GoRoute(
      path: '/detail/:id',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: DetailScreen(id: state.pathParameters['id']!),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    ),
    GoRoute(
      path: '/compare',
      builder: (context, state) => const CompareScreen(),
    ),
  ],
);

// 메인 네비게이션 화면 (하단 탭)
class _MainNavigationScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _MainNavigationScreen({
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(height: 0.5, thickness: 0.5),
          NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: navigationShell.goBranch,
            elevation: 0,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, semanticLabel: '홈'),
                selectedIcon: Icon(Icons.home, semanticLabel: '홈'),
                label: '홈',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined, semanticLabel: '검색'),
                selectedIcon: Icon(Icons.search, semanticLabel: '검색'),
                label: '검색',
              ),
              NavigationDestination(
                icon: Icon(Icons.map_outlined, semanticLabel: '지도'),
                selectedIcon: Icon(Icons.map, semanticLabel: '지도'),
                label: '지도',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_outline, semanticLabel: '즐겨찾기'),
                selectedIcon: Icon(Icons.favorite, semanticLabel: '즐겨찾기'),
                label: '즐겨찾기',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, semanticLabel: '설정'),
                selectedIcon: Icon(Icons.settings, semanticLabel: '설정'),
                label: '설정',
              ),
            ],
          ),
        ],
      ),
    );
  }
}