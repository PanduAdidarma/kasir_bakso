import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ Untuk dukungan lokal (termasuk DatePicker)

import 'core/layanan/theme_provider.dart';
import 'core/tema/tema_aplikasi.dart';
import 'core/route/generator_rute.dart';
import 'core/route/daftar_rute.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Wajib kalau ada async di main()
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ Inisialisasi Firebase dari file generated
  );

  await initializeDateFormatting('id_ID', null); // ✅ Biar intl ngerti format tanggal Indonesia

  runApp(
    ChangeNotifierProvider( // ✅ Provider untuk nyimpen state ThemeMode (gelap/terang)
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // ✅ Ambil status theme dari provider

    return MaterialApp(
      title: 'KasirKita',
      debugShowCheckedModeBanner: false,
      theme: TemaAplikasi.temaTerang, // ✅ Tema default terang
      darkTheme: TemaAplikasi.temaGelap, // ✅ Tema gelap
      themeMode: themeProvider.themeMode, // ✅ Theme mode dynamic sesuai toggle
      onGenerateRoute: GeneratorRute.generate, // ✅ Pakai custom route generator
      initialRoute: Rute.splash, // ✅ Route pertama waktu app start
      locale: const Locale('id', 'ID'), // ✅ Paksa locale Indo ke semua widget
      supportedLocales: const [
        Locale('id', 'ID'), // ✅ Locale Indonesia
        Locale('en', 'US'), // ✅ Fallback English
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate, // ✅ Support Material widget lokal
        GlobalWidgetsLocalizations.delegate, // ✅ Support widget framework lokal
        GlobalCupertinoLocalizations.delegate, // ✅ Support Cupertino widget lokal
      ],
    );
  }
}
