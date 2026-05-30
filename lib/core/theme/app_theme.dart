import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get light => _buildTheme(brightness: Brightness.light);
  static ThemeData get dark => _buildTheme(brightness: Brightness.dark);

  static ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;

    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final surface = isDark ? AppColors.darkSurface : AppColors.surface;
    final surfaceVar = isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
    final onSurface = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final onSurfaceVar = isDark ? AppColors.darkOnSurfaceVariant : AppColors.onSurfaceVariant;
    final divider = isDark ? AppColors.darkDivider : AppColors.divider;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: isDark ? AppColors.primaryDark : AppColors.primaryLight.withOpacity(0.2),
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondary.withOpacity(0.15),
      onSecondaryContainer: AppColors.secondaryDark,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.error.withOpacity(0.15),
      onErrorContainer: AppColors.error,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVar,
      onSurfaceVariant: onSurfaceVar,
      outline: divider,
      outlineVariant: divider.withOpacity(0.5),
      shadow: isDark ? AppColors.darkShadow : AppColors.shadow,
      scrim: Colors.black54,
      inverseSurface: isDark ? AppColors.surface : AppColors.darkSurface,
      onInverseSurface: isDark ? AppColors.onSurface : AppColors.darkOnSurface,
      inversePrimary: AppColors.primaryLight,
    );

    final base = GoogleFonts.interTextTheme(
      isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      brightness: brightness,
      textTheme: base.copyWith(
        displayLarge: base.displayLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w700, letterSpacing: -1.5),
        displayMedium: base.displayMedium?.copyWith(color: onSurface, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        displaySmall: base.displaySmall?.copyWith(color: onSurface, fontWeight: FontWeight.w700),
        headlineLarge: base.headlineLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w700),
        headlineMedium: base.headlineMedium?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
        headlineSmall: base.headlineSmall?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
        titleLarge: base.titleLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
        titleMedium: base.titleMedium?.copyWith(color: onSurface, fontWeight: FontWeight.w500),
        titleSmall: base.titleSmall?.copyWith(color: onSurface, fontWeight: FontWeight.w500),
        bodyLarge: base.bodyLarge?.copyWith(color: onSurface),
        bodyMedium: base.bodyMedium?.copyWith(color: onSurfaceVar),
        bodySmall: base.bodySmall?.copyWith(color: onSurfaceVar),
        labelLarge: base.labelLarge?.copyWith(color: onSurface, fontWeight: FontWeight.w600),
        labelMedium: base.labelMedium?.copyWith(color: onSurfaceVar, fontWeight: FontWeight.w500),
        labelSmall: base.labelSmall?.copyWith(color: onSurfaceVar),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVar,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: divider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: onSurfaceVar),
        labelStyle: GoogleFonts.inter(fontSize: 14, color: onSurfaceVar),
        floatingLabelStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
        prefixIconColor: onSurfaceVar,
        suffixIconColor: onSurfaceVar,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVar,
        selectedColor: AppColors.primary.withOpacity(0.15),
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: onSurfaceVar,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 0),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isDark ? AppColors.darkSurfaceVariant : AppColors.onSurface,
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.darkOnSurface : Colors.white),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        titleTextStyle: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
        contentTextStyle: GoogleFonts.inter(fontSize: 14, color: onSurfaceVar),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        modalBackgroundColor: surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: divider,
        dragHandleSize: const Size(40, 4),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.primary : onSurfaceVar),
        trackColor: WidgetStateProperty.resolveWith((s) =>
          s.contains(WidgetState.selected) ? AppColors.primary.withOpacity(0.4) : surfaceVar),
      ),
    );
  }
}
