import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'app.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AuthRepository.initialize(
    appKey: const String.fromEnvironment(
      'KAKAO_MAP_KEY',
      defaultValue: '0a6efe42f1e9ada89baef04fe816a43a',
    ),
  );

  final onboardingDone = await isOnboardingComplete();

  runApp(
    ProviderScope(
      child: KindergartenApp(showOnboarding: !onboardingDone),
    ),
  );
}
