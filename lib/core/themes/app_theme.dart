import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Signature palette of MX Player: near-black surfaces with a vivid green accent.
class MxColors {
  const MxColors._();

  static const Color brand = Color(0xFF3DDC84);
  static const Color brandDeep = Color(0xFF12A05A);
  static const Color brandSoft = Color(0xFF1C3B2A);
  static const Color danger = Color(0xFFFF5A5F);

  static const Color background = Color(0xFF0B0C0E);
  static const Color surface = Color(0xFF14161A);
  static const Color surfaceAlt = Color(0xFF1B1E23);
  static const Color surfaceHigh = Color(0xFF23272E);

  static const Color textPrimary = Color(0xFFF5F6F7);
  static const Color textSecondary = Color(0xFF9AA1AA);
  static const Color textTertiary = Color(0xFF6C737C);
  static const Color divider = Color(0xFF23262C);

  static const Color lightBackground = Color(0xFFF6F7F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFEEF1F4);
  static const Color lightTextPrimary = Color(0xFF111418);
  static const Color lightTextSecondary = Color(0xFF5F6670);
  static const Color lightDivider = Color(0xFFE3E6EA);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF63F0A3), brand, brandDeep],
  );

  static const LinearGradient darkScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xE6000000), Color(0x00000000)],
  );

  static const LinearGradient bottomScrim = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: <Color>[Color(0xE6000000), Color(0x00000000)],
  );
}

class AppTheme {
  const AppTheme._();

  static ThemeData get darkTheme => _build(Brightness.dark);
  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;

    final Color background = isDark ? MxColors.background : MxColors.lightBackground;
    final Color surface = isDark ? MxColors.surface : MxColors.lightSurface;
    final Color surfaceAlt = isDark ? MxColors.surfaceAlt : MxColors.lightSurfaceAlt;
    final Color textPrimary = isDark ? MxColors.textPrimary : MxColors.lightTextPrimary;
    final Color textSecondary = isDark ? MxColors.textSecondary : MxColors.lightTextSecondary;
    final Color divider = isDark ? MxColors.divider : MxColors.lightDivider;

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: MxColors.brand,
      brightness: brightness,
    ).copyWith(
      primary: MxColors.brand,
      onPrimary: const Color(0xFF062814),
      secondary: MxColors.brand,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceAlt,
      outline: divider,
      error: MxColors.danger,
    );

    final TextTheme textTheme = (isDark ? Typography.material2021().white : Typography.material2021().black)
        .apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        )
        .copyWith(
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: textPrimary),
          titleLarge: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, letterSpacing: -0.2, color: textPrimary),
          titleMedium: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600, color: textPrimary),
          titleSmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.1, color: textSecondary),
          bodyMedium: TextStyle(fontSize: 13.5, height: 1.35, color: textPrimary),
          bodySmall: TextStyle(fontSize: 12, height: 1.3, color: textSecondary),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2, color: textSecondary),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      dividerColor: divider,
      splashFactory: InkSparkle.splashFactory,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: isDark ? Colors.white : MxColors.lightTextPrimary, size: 22),
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textPrimary,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? MxColors.surfaceAlt : MxColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? MxColors.surfaceAlt : MxColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: divider,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? MxColors.surfaceHigh : const Color(0xFF20242A),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: textTheme.bodySmall,
        labelStyle: textTheme.bodySmall,
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MxColors.brand, width: 1.2),
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 3,
        activeTrackColor: MxColors.brand,
        inactiveTrackColor: divider,
        thumbColor: MxColors.brand,
        overlayColor: MxColors.brand.withOpacity(0.16),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        trackShape: const RoundedRectSliderTrackShape(),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.selected) ? const Color(0xFF062814) : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.selected) ? MxColors.brand : divider,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.selected) ? MxColors.brand : textSecondary,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => states.contains(WidgetState.selected) ? MxColors.brand : Colors.transparent,
        ),
        side: BorderSide(color: textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        selectedColor: MxColors.brand.withOpacity(isDark ? 0.18 : 0.22),
        side: BorderSide(color: divider),
        labelStyle: textTheme.bodySmall,
        secondaryLabelStyle: TextStyle(
          color: isDark ? MxColors.brand : MxColors.brandDeep,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        showCheckmark: false,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecondary,
        textColor: textPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minVerticalPadding: 10,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 64,
        backgroundColor: isDark ? const Color(0xFF101215) : MxColors.lightSurface,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => TextStyle(
            fontSize: 10.5,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? MxColors.brand : textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (Set<WidgetState> states) => IconThemeData(
            size: 23,
            color: states.contains(WidgetState.selected) ? MxColors.brand : textSecondary,
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? MxColors.surfaceHigh : MxColors.lightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: textTheme.bodyMedium,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: MxColors.brand,
        linearTrackColor: Color(0xFF262A31),
      ),
    );
  }
}
