import 'package:flutter/material.dart';

// Brand Colors — Material 3 tonal ramps seeded from Keiko blue #215278.
//
// Scale: 100 = lightest … 900 = darkest, aligned to M3 tone values so the
// ColorScheme mapping in branded_theme.dart works in both brightnesses:
//   100 ≈ tone 97 · 200 ≈ tone 92 · 300 ≈ tone 90 · 400 ≈ tone 80
//   500 ≈ tone 40 (brand) · 600 ≈ tone 30 · 700 ≈ tone 25
//   800 ≈ tone 18 · 900 ≈ tone 12
class BrandColors {
  // Primary colors — Keiko blue (seed #215278)
  static const Color primary100 = Color(0xFFF2F6FB);
  static const Color primary200 = Color(0xFFD8E5F2);
  static const Color primary300 = Color(0xFFC3D8EC);
  static const Color primary400 = Color(0xFF9CC0DF);
  static const Color primary500 = Color(0xFF215278);
  static const Color primary600 = Color(0xFF1B4566);
  static const Color primary700 = Color(0xFF143A57);
  static const Color primary800 = Color(0xFF0E2D45);
  static const Color primary900 = Color(0xFF081F31);

  // Secondary colors — desaturated blue-gray companion
  static const Color secondary100 = Color(0xFFF1F5F9);
  static const Color secondary200 = Color(0xFFDEE7EE);
  static const Color secondary300 = Color(0xFFCBD9E4);
  static const Color secondary400 = Color(0xFFA5BACB);
  static const Color secondary500 = Color(0xFF51687C);
  static const Color secondary600 = Color(0xFF43586A);
  static const Color secondary700 = Color(0xFF364857);
  static const Color secondary800 = Color(0xFF283845);
  static const Color secondary900 = Color(0xFF1B2832);

  // Accent colors — teal tertiary (also semantic "success")
  static const Color accent100 = Color(0xFFEFF8F5);
  static const Color accent200 = Color(0xFFD2ECE4);
  static const Color accent300 = Color(0xFFB0DCD0);
  static const Color accent400 = Color(0xFF7FC0AF);
  static const Color accent500 = Color(0xFF2E7D6B);
  static const Color accent600 = Color(0xFF266A5A);
  static const Color accent700 = Color(0xFF1E5648);
  static const Color accent800 = Color(0xFF164237);
  static const Color accent900 = Color(0xFF0E2E26);

  // Warning colors — amber
  static const Color warning100 = Color(0xFFFDF6E8);
  static const Color warning200 = Color(0xFFF9E7C3);
  static const Color warning300 = Color(0xFFF3D597);
  static const Color warning400 = Color(0xFFE3B254);
  static const Color warning500 = Color(0xFF8A6500);
  static const Color warning600 = Color(0xFF735400);
  static const Color warning700 = Color(0xFF5C4300);
  static const Color warning800 = Color(0xFF463300);
  static const Color warning900 = Color(0xFF302300);

  // Error colors — M3 baseline red
  static const Color error100 = Color(0xFFFCEEEE);
  static const Color error200 = Color(0xFFF9DEDC);
  static const Color error300 = Color(0xFFF2B8B5);
  static const Color error400 = Color(0xFFEC928E);
  static const Color error500 = Color(0xFFB3261E);
  static const Color error600 = Color(0xFF8C1D18);
  static const Color error700 = Color(0xFF6E1713);
  static const Color error800 = Color(0xFF52110E);
  static const Color error900 = Color(0xFF3A0A08);
}

// Typography constants
class BrandTypography {
  // Heading styles
  static const TextStyle headingBold = TextStyle(
    fontFamily: 'sans-serif',
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: 'sans-serif',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle headingRegular = TextStyle(
    fontFamily: 'sans-serif',
    fontWeight: FontWeight.w400,
  );

  // Body styles
  static const TextStyle bodyRegular = TextStyle(
    fontFamily: 'sans-serif',
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'sans-serif',
    fontWeight: FontWeight.w500,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'sans-serif',
    fontWeight: FontWeight.w400,
    fontSize: 12.0,
  );

  // Accent styles
  static const TextStyle accentRegular = TextStyle(
    fontFamily: 'monospace',
    fontWeight: FontWeight.w400,
  );

  static const TextStyle accentMedium = TextStyle(
    fontFamily: 'monospace',
    fontWeight: FontWeight.w500,
  );

  // Label style
  static const TextStyle label = TextStyle(
    fontFamily: 'sans-serif',
    fontWeight: FontWeight.w500,
    fontSize: 14.0,
  );
}
