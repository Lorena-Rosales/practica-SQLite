import 'package:flutter/material.dart';

class ColoresApp {
  static const fondo = Color(0xFF1B2A4E);
  static const panel = Color(0xFF233561);
  static const cian = Color(0xFF63DAFB);
  static const borde = Color(0x99FFFFFF);
  static const divisor = Color(0x33FFFFFF);
  static const textoSecundario = Color(0xB3FFFFFF);
}

ThemeData crearTema() {
  final esquema = ColorScheme.fromSeed(
    seedColor: ColoresApp.cian,
    brightness: Brightness.dark,
  ).copyWith(
    primary: ColoresApp.cian,
    onPrimary: ColoresApp.fondo,
    surface: ColoresApp.fondo,
    onSurface: Colors.white,
  );

  final bordeCampo = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: ColoresApp.borde),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    scaffoldBackgroundColor: ColoresApp.fondo,
    appBarTheme: const AppBarTheme(
      backgroundColor: ColoresApp.fondo,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.w400,
      ),
      shape: Border(bottom: BorderSide(color: ColoresApp.divisor)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(color: ColoresApp.textoSecundario),
      floatingLabelStyle: const TextStyle(color: ColoresApp.cian),
      border: bordeCampo,
      enabledBorder: bordeCampo,
      focusedBorder: bordeCampo.copyWith(
        borderSide: const BorderSide(color: ColoresApp.cian, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ColoresApp.cian,
        foregroundColor: ColoresApp.fondo,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: ColoresApp.cian),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (estados) => estados.contains(WidgetState.selected)
            ? ColoresApp.cian
            : Colors.transparent,
      ),
      checkColor: const WidgetStatePropertyAll(ColoresApp.fondo),
      side: WidgetStateBorderSide.resolveWith(
        (estados) => BorderSide(
          color: estados.contains(WidgetState.selected)
              ? ColoresApp.cian
              : ColoresApp.borde,
          width: 1.5,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: ColoresApp.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ColoresApp.cian),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: ColoresApp.panel,
      contentTextStyle: TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: ColoresApp.cian,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: ColoresApp.cian,
    ),
  );
}
