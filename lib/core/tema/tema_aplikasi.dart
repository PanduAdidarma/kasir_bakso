import 'package:flutter/material.dart';
import '../konstanta/warna.dart';
import '../konstanta/default.dart';

class TemaAplikasi {
  static ThemeData temaTerang = ThemeData(
    brightness: Brightness.light,
    primaryColor: Warna.primer,
    scaffoldBackgroundColor: Warna.latar,
    appBarTheme: const AppBarTheme(
      backgroundColor: Warna.primer,
      foregroundColor: Warna.putih,
      elevation: DefaultSetting.elevasiAppBar,
      iconTheme: IconThemeData(color: Warna.putih),
      titleTextStyle: TextStyle(
        color: Warna.putih,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: Warna.primer,
      secondary: Warna.aksen,
      surface: Warna.latar,
      error: Warna.gagal,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Warna.primer,
        foregroundColor: Warna.putih,
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: DefaultSetting.padding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DefaultSetting.radius),
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Warna.teksUtama,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Warna.teksSekunder,
        fontSize: 14,
      ),
      titleLarge: TextStyle(
        color: Warna.teksUtama,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Warna.putih,
      contentPadding: EdgeInsets.all(DefaultSetting.padding),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DefaultSetting.radius),
        borderSide: const BorderSide(color: Warna.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DefaultSetting.radius),
        borderSide: const BorderSide(color: Warna.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DefaultSetting.radius),
        borderSide: const BorderSide(color: Warna.primer, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: Warna.putih,
      elevation: DefaultSetting.elevasiCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DefaultSetting.radius),
      ),
    ),
  );

  static ThemeData temaGelap = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Warna.primerGelap,
    scaffoldBackgroundColor: Warna.latarGelap,
    appBarTheme: const AppBarTheme(
      backgroundColor: Warna.primerGelap,
      foregroundColor: Warna.putih,
      elevation: DefaultSetting.elevasiAppBar,
      iconTheme: IconThemeData(color: Color.fromARGB(255, 10, 10, 10)),
      titleTextStyle: TextStyle(
        color: Warna.primer,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: Warna.primerGelap,
      secondary: Warna.aksenGelap,
      surface: Warna.permukaanGelap,
      error: Warna.gagal,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Warna.primerGelap,
        foregroundColor: Warna.primer,
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: DefaultSetting.padding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DefaultSetting.radius),
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        color: Warna.teksUtamaGelap,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: Warna.teksSekunderGelap,
        fontSize: 14,
      ),
      titleLarge: TextStyle(
        color: Warna.teksUtamaGelap,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Warna.inputFillGelap,
      contentPadding: EdgeInsets.all(DefaultSetting.padding),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DefaultSetting.radius),
        borderSide: const BorderSide(color: Warna.borderGelap),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DefaultSetting.radius),
        borderSide: const BorderSide(color: Warna.borderGelap),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DefaultSetting.radius),
        borderSide: const BorderSide(color: Warna.primerGelap, width: 2),
      ),
    ),
    cardTheme: CardThemeData(
      color: Warna.kartuGelap,
      elevation: DefaultSetting.elevasiCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DefaultSetting.radius),
      ),
    ),
  );
}
