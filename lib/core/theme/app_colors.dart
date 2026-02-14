import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Design Course style)
  static const Color primary = Color(0xFF00B6F0); // nearlyBlue
  static const Color primaryVariant = Color(0xFF0095C7);
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryVariant = Color(0xFFF57C00);

  // Surface Colors
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF2F3F8); // cool-tone
  static const Color card = Colors.white;

  // Text Colors
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onSurface = Color(0xFF253840); // nearlyBlack
  static const Color onBackground = Color(0xFF253840);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF00B6F0);

  // Gray Scale
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Kindergarten Type Colors
  static const Color publicType = Color(0xFF2196F3);
  static const Color privateType = Color(0xFFFF9800);
  static const Color corporationType = Color(0xFF4CAF50);
  static const Color otherType = Color(0xFF9E9E9E);

  // Map Marker Colors
  static const Color markerPublic = publicType;
  static const Color markerPrivate = privateType;
  static const Color markerCorporation = corporationType;
  static const Color markerOther = otherType;

  // Badge Colors
  static const Color mealBadge = Color(0xFF4CAF50);
  static const Color busBadge = Color(0xFF2196F3);
  static const Color extendedCareBadge = Color(0xFFFF9800);

  // Divider
  static const Color divider = gray300;

  // Shadow
  static const Color shadow = Color(0x1F000000);

  // Favorite
  static const Color favoriteActive = Color(0xFFE91E63);
  static const Color favoriteInactive = gray400;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00B6F0), Color(0xFF6078EA)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E3F6E), Color(0xFF00B6F0)],
  );
}
