# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**유치원 찾기 앱** - 부모/보호자가 주변 유치원을 검색, 상세 확인, 비교, 즐겨찾기할 수 있는 Flutter 앱
- Flutter 3.32.8 / Dart 3.8.1 / Stable channel
- 지원 플랫폼: Android, iOS, Web, macOS, Linux, Windows
- Package namespace: `com.kindergarten.kindergarten_flutter`
- MVP 기능 전체 구현 완료 (설계 문서: `FLUTTER_MVP_SPEC.md`)
  - 무한스크롤은 `infinite_scroll_pagination` 패키지 대신 커스텀 `PaginatedSearchNotifier`로 구현

## Common Commands

```bash
# Run
flutter run -d chrome              # 웹 브라우저
flutter run -d macos               # macOS 데스크톱

# Build
flutter build web                  # 웹 빌드
flutter build apk                  # Android APK

# Test
flutter test                       # 전체 테스트
flutter test test/widget_test.dart # 단일 테스트 파일
flutter test --name "test name"    # 이름으로 특정 테스트

# Code Quality
flutter analyze                    # Dart 정적 분석
dart format lib/                   # 코드 포맷팅
dart fix --apply                   # 자동 수정 가능한 lint 이슈

# Dependencies
flutter pub get                    # 의존성 설치
flutter pub add <package>          # 패키지 추가
```

## Architecture

Riverpod 기반 Provider 패턴. 단방향 데이터 흐름: Repository → Provider → Screen(Widget).

```
lib/
├── main.dart                  # ProviderScope 루트
├── app.dart                   # MaterialApp.router + GoRouter + BottomNavigationBar
├── core/
│   ├── constants/             # API 엔드포인트, 앱 상수 (반경, 페이지 크기 등)
│   ├── network/               # Dio 클라이언트, API 예외 모델
│   ├── theme/                 # AppColors, AppTextStyles, AppTheme, AppDecorations
│   └── utils/                 # DeviceIdManager, LocationService
├── models/                    # 불변 데이터 모델 (fromJson 팩토리)
├── providers/                 # Riverpod Providers (상태 관리 + 캐싱)
├── repositories/              # API 호출 래퍼 (Dio 사용)
├── screens/                   # 화면별 디렉토리 (screen.dart + widgets/)
│   ├── home/                  # 홈 (주변 유치원, 즐겨찾기)
│   ├── search/                # 검색/목록 (필터, 무한스크롤)
│   ├── map/                   # 지도 (Google Maps 마커)
│   ├── detail/                # 상세 (6개 탭: 교육/급식/안전/시설/교사/방과후)
│   ├── favorites/             # 즐겨찾기 (비교 선택)
│   ├── compare/               # 비교 (가로 스크롤 테이블)
│   └── settings/              # 설정
└── widgets/                   # 공용 위젯 (BadgeChip, EmptyState, ErrorState 등)
```

### 핵심 규칙
- **Widget에 비즈니스 로직 금지**: Screen은 표시만, Provider가 로직 담당
- **Immutable Data Models**: 모델은 불변, `fromJson` 팩토리로 생성
- **Repository 패턴**: 데이터 접근은 반드시 Repository를 통해

### 네이밍 컨벤션
- Screen: `HomeScreen`, `DetailScreen`
- Provider: `kindergartenSearchProvider`, `nearbyKindergartensProvider`
- Repository: `KindergartenRepository`, `FavoriteRepository`

## Routing

GoRouter + `StatefulShellRoute.indexedStack`로 하단 탭 네비게이션 구성 (`app.dart`).

| 경로 | 화면 | 비고 |
|------|------|------|
| `/home` | HomeScreen | 탭 1 (initialLocation) |
| `/search` | SearchScreen | 탭 2 |
| `/map` | MapScreen | 탭 3 |
| `/favorites` | FavoritesScreen | 탭 4 |
| `/settings` | SettingsScreen | 탭 5 |
| `/detail/:id` | DetailScreen | Push (슬라이드 트랜지션) |
| `/compare` | CompareScreen | Push |

## State Management (Riverpod)

주요 Provider 구성 (`providers/`):
- `kindergartenSearchProvider` - 검색 결과 (searchFilter 변경 시 자동 재조회)
- `kindergartenDetailProvider(id)` - 유치원 상세 (Family)
- `mapMarkersProvider({lat, lng, radiusKm, type})` - 지도 마커 (Family, Record 타입 파라미터)
- `nearbyKindergartensProvider` - 홈 화면 주변 유치원 (현위치 기반)
- `compareResultProvider({ids, lat, lng})` - 비교 결과 (Family)
- `currentPositionProvider` / `locationPermissionProvider` - 위치/권한
- `deviceIdProvider` - 기기 식별 UUID
- `favoritesProvider` - 즐겨찾기 목록

## Server / API

- 백엔드: **kindergarten** 프로젝트 (`~/kids/kindergarten`, 별도 리포지토리)
- Base URL: `http://localhost:1025` (개발), Android 에뮬레이터는 `http://10.0.2.2:1025`
- API Path: `/api/app`
- 인증: 없음 (앱 API), 기기 식별은 `deviceId` (UUID)
- 전체 API 명세는 `FLUTTER_MVP_SPEC.md` 섹션 3 참조

## Key Dependencies

| 패키지 | 용도 |
|--------|------|
| `flutter_riverpod` | 상태 관리 |
| `dio` | HTTP 통신 |
| `go_router` | 선언적 라우팅 |
| `kakao_map_plugin` | 카카오 지도 표시 |
| `geolocator` + `geocoding` | 현위치/주소 변환 |
| `device_info_plus` | 기기 ID 생성 |
| `shared_preferences` | 로컬 설정 저장 |
| `url_launcher` | 전화/홈페이지 연결 |
| `google_fonts` | 폰트 |

## Flutter Performance Rules

### DO
- `const` 생성자 적극 사용 (리빌드 스킵)
- `setState()` 최소 범위로 호출
- 리스트/그리드는 `ListView.builder` / `GridView.builder` 사용
- 함수 대신 `StatelessWidget`으로 분리
- `AnimatedBuilder`의 정적 콘텐츠는 `child` 파라미터로 전달

### DON'T
- `build()` 안에서 무거운 연산 수행
- 애니메이션에 `Opacity` 위젯 직접 사용 (→ `AnimatedOpacity`)
- `ListView(children: [...])` 로 대량 아이템 한번에 빌드
- 루프에서 String `+` 연산 (→ `StringBuffer` 사용)
- `ClipRRect` 대신 `BoxDecoration.borderRadius` 사용

## Testing Strategy

```
Unit Test (많이) → Widget Test (많이) → Integration Test (주요 유스케이스)
```
- 모든 Provider, Repository에 unit test 작성
- 테스트 Fake는 입출력에 집중 (내부 구현 아닌)
- Linting: `flutter_lints: ^5.0.0` (`analysis_options.yaml`)
- `flutter analyze` 통과 필수
