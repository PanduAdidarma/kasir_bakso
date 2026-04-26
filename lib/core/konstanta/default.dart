import 'package:flutter/material.dart';

class DefaultSetting {
  // Radius border umum
  static const double radius = 12.0;
  static const double radiusKecil = 8.0;
  static const double radiusBesar = 20.0;

  // Padding & Margin umum
  static const double padding = 16.0;
  static const double paddingKecil = 8.0;
  static const double paddingBesar = 24.0;

  static const EdgeInsets marginHalaman = EdgeInsets.all(16);
  static const EdgeInsets marginKecil = EdgeInsets.all(8);
  static const EdgeInsets marginBesar = EdgeInsets.all(24);

  static const EdgeInsets paddingForm = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets paddingCard = EdgeInsets.all(12);
  static const EdgeInsets paddingList = EdgeInsets.symmetric(vertical: 8, horizontal: 16);

  // Durasi animasi standar
  static const Duration durasiAnimasi = Duration(milliseconds: 300);
  static const Duration durasiAnimasiCepat = Duration(milliseconds: 150);
  static const Duration durasiAnimasiLambat = Duration(milliseconds: 500);

  // Elevasi standar (shadow)
  static const double elevasiCard = 4.0;
  static const double elevasiAppBar = 0.0;
  static const double elevasiFloating = 6.0;

  // Ukuran default
  static const double lebarButton = double.infinity; // Tombol lebar penuh
  static const double tinggiButton = 48.0; // Tinggi tombol standar
}
