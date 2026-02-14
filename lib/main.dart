import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'app.dart';
import 'screens/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterNaverMap().init(
    clientId: 'YOUR_CLIENT_ID', // TODO: 네이버 클라우드 플랫폼에서 발급받은 Client ID로 교체
    onAuthFailed: (ex) => debugPrint('네이버 지도 인증 실패: $ex'),
  );

  final onboardingDone = await isOnboardingComplete();

  runApp(
    ProviderScope(
      child: KindergartenApp(showOnboarding: !onboardingDone),
    ),
  );
}
