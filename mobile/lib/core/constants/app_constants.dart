/// Spacing tokens (multiples of 4 px on an 8 px baseline grid).
class AppSpacing {
  const AppSpacing._();

  static const double base = 4;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double marginMobile = 20;
  static const double gutterMobile = 12;
}

/// Border-radius tokens.
class AppRadius {
  const AppRadius._();

  static const double sm = 4;
  static const double md = 8;
  static const double lg = 12;
  static const double xl = 16;
  static const double card = 24;
  static const double full = 9999;
}

/// Elevation tokens (shadow + blur).
class AppElevation {
  const AppElevation._();

  static const double level0 = 0;
  static const double level1 = 12;
  static const double level2 = 20;

  static const List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  static const List<BoxShadow> shadowModal = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 48,
      offset: Offset(0, 20),
    ),
  ];
}

/// Component size tokens.
class AppSize {
  const AppSize._();

  static const double buttonPrimaryHeight = 56;
  static const double buttonSecondaryHeight = 48;
  static const double providerAvatar = 64;
  static const double quickSendAvatar = 56;
  static const double transactionIcon = 48;
  static const double touchTargetMin = 48;
}
