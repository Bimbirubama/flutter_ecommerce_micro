import 'package:flutter/material.dart';

class AppTheme {
  // Warna-warna Lilac
  static const Color primaryLilac = Color(0xFFC8A2C8); // Lilac asli
  static const Color lightLilac = Color(0xFFF3E5F5);   // Sangat muda
  static const Color deepLilac = Color(0xFF9575CD);    // Ungu agak gelap untuk teks/tombol
  static const Color surfaceWhite = Color(0xFFFFFBFF);

  static ThemeData lilacTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryLilac,
      primary: primaryLilac,
      secondary: deepLilac,
      surface: surfaceWhite,
    ),
    scaffoldBackgroundColor: lightLilac,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: primaryLilac.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: deepLilac, width: 2),
      ),
      labelStyle: const TextStyle(color: deepLilac),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryLilac,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
  );
}