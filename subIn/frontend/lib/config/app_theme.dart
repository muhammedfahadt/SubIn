import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Athletic Pulse — dark-mode sports-tech design system.
///
/// Single central theme file. All raw hex values live here as named
/// `const` tokens. Screens must reference [AppTheme]/[AppColors] tokens
/// (or `Theme.of(context).colorScheme`) and never duplicate raw hex.
class AppColors {
  AppColors._();

  // Brand / accent.
  static const Color lime = Color(0xFF28F080);
  static const Color onLime = Color(0xFF080E1A);

  // Surfaces.
  static const Color appBackground = Color(0xFF0D131F);
  static const Color lowestSurface = Color(0xFF080E1A);
  static const Color lowContainer = Color(0xFF161C28);
  static const Color highContainer = Color(0xFF1E2638);
  static const Color brightHighlight = Color(0xFF333947);

  // Borders.
  static const Color outline = Color(0xFF222A38);

  // Text.
  static const Color primaryText = Color(0xFFF1F5F9);
  static const Color secondaryText = Color(0xFF94A3B8);
  static const Color tertiaryText = Color(0xFF64748B);

  // Sport / live status — kept separate from [lime] on purpose.
  static const Color soccerTurf = Color(0xFF28F080);
  static const Color basketballCourt = Color(0xFFF59E0B);
  static const Color liveRadar = Color(0xFF38BDF8);
  static const Color liveAvailable = Color(0xFF22C55E);

  // Retained for Material error role (spec does not define error color).
  static const Color error = Color(0xFFEF4444);
}

class AppTheme {
  AppTheme._();

  // ── Canonical Athletic Pulse tokens (preferred) ──
  static const Color lime = AppColors.lime;
  static const Color onLime = AppColors.onLime;
  static const Color appBackground = AppColors.appBackground;
  static const Color lowestSurface = AppColors.lowestSurface;
  static const Color lowContainer = AppColors.lowContainer;
  static const Color highContainer = AppColors.highContainer;
  static const Color brightHighlight = AppColors.brightHighlight;
  static const Color outline = AppColors.outline;
  static const Color primaryText = AppColors.primaryText;
  static const Color secondaryText = AppColors.secondaryText;
  static const Color tertiaryText = AppColors.tertiaryText;
  static const Color soccer = AppColors.soccerTurf;
  static const Color basketball = AppColors.basketballCourt;
  static const Color radarBlue = AppColors.liveRadar;
  static const Color liveEmerald = AppColors.liveAvailable;
  static const Color error = AppColors.error;

  // Shared restrained corner radius — 8px everywhere.
  static const double radius = 8.0;
  static BorderRadius get radiusBorder => BorderRadius.circular(radius);

  // ── Backward-compatible aliases (deprecated) ──
  // Kept so existing screens compile without per-screen edits in this task.
  // New code should use the canonical tokens above.
  @Deprecated('Use AppTheme.appBackground instead')
  static const Color background = appBackground;
  @Deprecated('Use AppTheme.lowContainer instead')
  static const Color surface = lowContainer;
  @Deprecated('Use AppTheme.lowContainer instead')
  static const Color cardBackground = lowContainer;
  @Deprecated('Use AppTheme.primaryText instead')
  static const Color textPrimary = primaryText;
  @Deprecated('Use AppTheme.secondaryText instead')
  static const Color textSecondary = secondaryText;
  @Deprecated('Use AppTheme.tertiaryText instead')
  static const Color textMuted = tertiaryText;
  @Deprecated('Use AppTheme.lime instead')
  static const Color primaryColor = lime;
  @Deprecated('Use AppTheme.lime instead')
  static const Color primaryDark = lime;
  @Deprecated('Use AppTheme.lime instead')
  static const Color primaryLight = lime;
  @Deprecated('Use AppTheme.basketball instead')
  static const Color accentColor = basketball;
  @Deprecated('Use AppTheme.basketball instead')
  static const Color accentLight = basketball;
  @Deprecated('Use AppTheme.liveEmerald instead')
  static const Color success = liveEmerald;
  @Deprecated('Use AppTheme.basketball instead')
  static const Color warning = basketball;
  @Deprecated('Use AppTheme.radarBlue instead')
  static const Color info = radarBlue;

  // Sport-specific colors.
  // Soccer/Basketball aligned to Athletic Pulse; remaining sports keep
  // legacy values centrally so screens do not hardcode hex.
  static const Map<String, Color> sportColors = {
    'Football': AppColors.soccerTurf,
    'Soccer': AppColors.soccerTurf,
    'Cricket': AppColors.liveRadar,
    'Basketball': AppColors.basketballCourt,
    'Tennis': Color(0xFFEC4899),
    'Badminton': Color(0xFF8B5CF6),
    'Volleyball': AppColors.basketballCourt,
    'Table Tennis': Color(0xFF06B6D4),
    'Running': AppColors.error,
    'Cycling': Color(0xFF14B8A6),
    'Swimming': Color(0xFF0EA5E9),
    'Yoga': Color(0xFFF472B6),
    'Gym': Color(0xFF6366F1),
    'Other': Color.fromARGB(255, 70, 235, 5),
  };

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final spaceText = GoogleFonts.spaceGroteskTextTheme(base.textTheme);

    final textTheme = spaceText
        .copyWith(
          displayLarge: spaceText.displayLarge?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
          displayMedium: spaceText.displayMedium?.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryText,
          ),
          titleLarge: spaceText.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryText,
          ),
          bodyLarge: spaceText.bodyLarge?.copyWith(
            fontSize: 16,
            color: primaryText,
          ),
          bodyMedium: spaceText.bodyMedium?.copyWith(
            fontSize: 14,
            color: secondaryText,
          ),
          labelLarge: spaceText.labelLarge?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: onLime,
          ),
        )
        .apply(bodyColor: primaryText, displayColor: primaryText);

    const colorScheme = ColorScheme.dark(
      primary: lime,
      onPrimary: onLime,
      secondary: radarBlue,
      onSecondary: onLime,
      tertiary: basketball,
      onTertiary: onLime,
      surface: lowContainer,
      onSurface: primaryText,
      error: error,
      onError: primaryText,
      outline: outline,
      outlineVariant: outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: appBackground,
      canvasColor: appBackground,
      primaryColor: lime,
      hintColor: tertiaryText,
      dividerColor: outline,
      colorScheme: colorScheme,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: appBackground,
        foregroundColor: primaryText,
        elevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
      ),
      cardTheme: CardThemeData(
        color: lowContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: const BorderSide(color: outline, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: lowContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: highContainer,
        contentTextStyle: GoogleFonts.spaceGrotesk(color: primaryText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: outline, thickness: 1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lime,
          foregroundColor: onLime,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          textStyle: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: lime,
          foregroundColor: onLime,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lime,
          side: const BorderSide(color: lime, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: lime),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lowContainer,
        labelStyle: GoogleFonts.spaceGrotesk(color: secondaryText),
        hintStyle: GoogleFonts.spaceGrotesk(color: tertiaryText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: lime, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: lowestSurface,
        selectedItemColor: lime,
        unselectedItemColor: secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lowestSurface,
        indicatorColor: lime,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.spaceGrotesk(fontSize: 12, color: secondaryText),
        ),
      ),
    );
  }
}
