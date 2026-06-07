import 'package:flutter/material.dart';

/// Typography tokens from the Stitch design system.
///
/// Source: `docs/design_tokens.md`.
/// Fonts: `Inter` (body, headlines, amounts) + `Geist` (labels).
/// DO NOT EDIT MANUALLY — regenerate from design tokens.
class AppTypography {
  const AppTypography._();

  static const String _inter = 'Inter';
  static const String _geist = 'Geist';

  /// 32 / 40 / w700 / -0.02em — Display large.
  static const TextStyle displayLg = TextStyle(
    fontFamily: _inter,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02 * 32,
  );

  /// 24 / 32 / w600 / -0.01em — Headline medium.
  static const TextStyle headlineMd = TextStyle(
    fontFamily: _inter,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01 * 24,
  );

  /// 20 / 28 / w600 — Headline medium mobile.
  static const TextStyle headlineMdMobile = TextStyle(
    fontFamily: _inter,
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
  );

  /// 18 / 24 / w600 — Title large.
  static const TextStyle titleLg = TextStyle(
    fontFamily: _inter,
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );

  /// 16 / 24 / w400 — Body large.
  static const TextStyle bodyLg = TextStyle(
    fontFamily: _inter,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  /// 14 / 20 / w400 — Body small.
  static const TextStyle bodySm = TextStyle(
    fontFamily: _inter,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  /// 12 / 16 / w500 / +0.05em — Label medium (Geist).
  static const TextStyle labelMd = TextStyle(
    fontFamily: _geist,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.05 * 12,
  );

  /// 28 / 34 / w700 / -0.03em — Balance / amount display.
  static const TextStyle amountDisplay = TextStyle(
    fontFamily: _inter,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.03 * 28,
  );

  /// Convenience: Material `TextTheme` built from the tokens above.
  static TextTheme get textTheme => const TextTheme(
        displayLarge: displayLg,
        headlineMedium: headlineMd,
        titleLarge: titleLg,
        bodyLarge: bodyLg,
        bodyMedium: bodySm,
        labelMedium: labelMd,
      );
}
