import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ============================================================
///  AppTheme — Tema centralizado UMAMI
/// ============================================================

class AppColors {
  // Marca
  static const Color primary = Color(0xFFE65100);
  static const Color primaryLight = Color(0xFFFF8A50);
  static const Color primaryDark = Color(0xFFBF360C);

  // Fondos
  static const Color background = Color(0xFFFAF9F6);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F0EB);

  // AppBar
  static const Color appBar = Color(0xFF1E1E1E);

  // Texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnDark = Colors.white;

  // Estados semánticos
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57F17);
  static const Color info = Color(0xFF1565C0);
  static const Color error = Color(0xFFC62828);
  static const Color neutral = Color(0xFF9E9E9E);
  static const Color cuentaPedida = Color(0xFF6A1B9A);

  // Bordes y variantes — faltaban estos, causaban error en pantallas
  static const Color outline = Color(0xFFD6CFC7);
  static const Color onSurfaceVariant = Color(0xFF757575);

  // Estados de mesa
  static const Color mesaLibre = neutral;
  static const Color mesaOrdenando = info;
  static const Color mesaEnCocina = warning;
  static const Color mesaLista = success;
  static const Color mesaCuentaPedida = cuentaPedida;
  static const Color mesaPagada = Color(0xFF4CAF50);

  // Overlay
  static const Color overlay = Color(0xB3000000);

  // Modo oscuro
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkSurfaceVariant = Color(0xFF2C2C2C);
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;
}

class AppElevation {
  static const double flat = 0.0;
  static const double low = 1.0;
  static const double medium = 3.0;
  static const double high = 6.0;
}

class AppTypography {
  static TextStyle get headline => GoogleFonts.poppins(
    fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static TextStyle get title => GoogleFonts.poppins(
    fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static TextStyle get subtitle => GoogleFonts.poppins(
    fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.textPrimary,
  );
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static TextStyle get bodyBold => GoogleFonts.inter(
    fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
  );
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary,
  );
  static TextStyle get label => GoogleFonts.inter(
    fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
  );
  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textOnPrimary,
  );
  static TextStyle get overline => GoogleFonts.inter(
    fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.5, color: AppColors.textSecondary,
  );

  static TextStyle headlineWith(Color c) => GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: c);
  static TextStyle titleWith(Color c) => GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: c);
  static TextStyle subtitleWith(Color c) => GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: c);
  static TextStyle bodyWith(Color c) => GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: c);
  static TextStyle captionWith(Color c) => GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: c);
}

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.surface,
      error: AppColors.error,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.appBar,
      foregroundColor: AppColors.textOnDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: AppElevation.low,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.lg),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: AppElevation.medium,
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xl),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: AppTypography.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xl),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
        textStyle: AppTypography.button.copyWith(color: AppColors.primary),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppTypography.subtitle.copyWith(color: AppColors.primary),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.error, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.error, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      hintStyle: AppTypography.body.copyWith(color: AppColors.textHint),
      labelStyle: AppTypography.caption.copyWith(color: AppColors.textSecondary),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceVariant,
      selectedColor: AppColors.primaryLight,
      labelStyle: AppTypography.caption,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.full)),
      side: BorderSide.none,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.surfaceVariant,
      thickness: 1,
      space: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: AppElevation.medium,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    // Quitado selectedItemColor que no existe en NavigationRailThemeData
    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: AppColors.surface,
      unselectedLabelTextStyle: TextStyle(color: AppColors.textSecondary),
      selectedLabelTextStyle: TextStyle(color: AppColors.primary),
      unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
      selectedIconTheme: IconThemeData(color: AppColors.primary),
      elevation: 0,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      elevation: AppElevation.low,
      color: AppColors.darkSurfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.lg),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceVariant,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
    ),
  );

  static Color estadoOrdenColor(String estado) {
    switch (estado) {
      case 'recibido': return AppColors.info;
      case 'preparando': return AppColors.warning;
      case 'listo': return AppColors.success;
      case 'entregado': return AppColors.success;
      case 'cancelado': return AppColors.error;
      default: return AppColors.neutral;
    }
  }

  static Color estadoMesaColor(String estado) {
    switch (estado) {
      case 'libre': return AppColors.mesaLibre;
      case 'ordenando': return AppColors.mesaOrdenando;
      case 'en_cocina': return AppColors.mesaEnCocina;
      case 'lista': return AppColors.mesaLista;
      case 'cuenta_pedida': return AppColors.mesaCuentaPedida;
      case 'pagada': return AppColors.mesaPagada;
      default: return AppColors.neutral;
    }
  }

  static IconData estadoOrdenIcon(String estado) {
    switch (estado) {
      case 'recibido': return Icons.receipt_long_rounded;
      case 'preparando': return Icons.restaurant_rounded;
      case 'listo': return Icons.check_circle_rounded;
      case 'entregado': return Icons.done_all_rounded;
      case 'cancelado': return Icons.cancel_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  static IconData estadoMesaIcon(String estado) {
    switch (estado) {
      case 'libre': return Icons.table_restaurant_rounded;
      case 'ordenando': return Icons.edit_note_rounded;
      case 'en_cocina': return Icons.soup_kitchen_rounded;
      case 'lista': return Icons.room_service_rounded;
      case 'cuenta_pedida': return Icons.receipt_long_rounded;
      case 'pagada': return Icons.paid_rounded;
      default: return Icons.table_restaurant_rounded;
    }
  }

  static String estadoOrdenLabel(String estado) {
    switch (estado) {
      case 'recibido': return 'Recibido';
      case 'preparando': return 'Preparando';
      case 'listo': return 'Listo';
      case 'entregado': return 'Entregado';
      case 'cancelado': return 'Cancelado';
      default: return estado;
    }
  }

  static String estadoMesaLabel(String estado) {
    switch (estado) {
      case 'libre': return 'Libre';
      case 'ordenando': return 'Ordenando';
      case 'en_cocina': return 'En cocina';
      case 'lista': return 'Lista';
      case 'cuenta_pedida': return 'Cuenta pedida';
      case 'pagada': return 'Pagada';
      default: return estado;
    }
  }
}
