import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kasir_bakso/tampilan/admin/catat_transaksi.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/konstanta/teks.dart';
import '../../core/konstanta/warna.dart';
import '../../core/layanan/layanan_firestore.dart';
import '../../tampilan/auth/halaman_login.dart';
import '../../tampilan/owner/dashboard_owner.dart';

class SplashHalaman extends StatefulWidget {
  const SplashHalaman({super.key});

  @override
  State<SplashHalaman> createState() => _SplashHalamanState();
}

class _SplashHalamanState extends State<SplashHalaman> {
  @override
  void initState() {
    super.initState();
    _cekStatusUser();
  }

  // Future<void> _cekStatusUser() async {
  //   debugPrint("⏳ Menunggu splash...");
  //   await Future.delayed(const Duration(seconds: 3)); // Waktu splash

  //   final user = FirebaseAuth.instance.currentUser;

  //   if (user == null || await _sudahLewatBatasWaktu()) {
  //     debugPrint("🔐 Belum login atau sesi habis (user == null / timeout)");
  //     await FirebaseAuth.instance.signOut();
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.clear();
  //     _navigasiGantiHalaman(const HalamanLogin());
  //     return;
  //   }

  //   try {
  //     debugPrint("🔍 Cek user: ${user.uid}");

  //     final doc = await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid)
  //         .get();

  //     if (!doc.exists) {
  //       debugPrint("❌ Data user tidak ditemukan di Firestore");
  //       await FirebaseAuth.instance.signOut();
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.clear();
  //       _navigasiGantiHalaman(const HalamanLogin());
  //       return;
  //     }

  //     final data = doc.data()!;
  //     final role = data['role'] ?? 'unknown';
  //     final disetujui = data['status'] ?? false;

  //     debugPrint("✅ Role: $role | Disetujui: $disetujui");

  //     if (role == 'admin' && !disetujui) {
  //       debugPrint("⛔ Admin belum disetujui");
  //       await FirebaseAuth.instance.signOut();
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.clear();
  //       _navigasiGantiHalaman(const HalamanLogin());
  //     } else if (role == 'admin') {
  //       _navigasiGantiHalaman(const DashboardAdmin());
  //     } else if (role == 'owner') {
  //       _navigasiGantiHalaman(const DashboardOwner());
  //     } else {
  //       debugPrint("⚠️ Role tidak dikenal: $role");
  //       await FirebaseAuth.instance.signOut();
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.clear();
  //       _navigasiGantiHalaman(const HalamanLogin());
  //     }
  //   } catch (e) {
  //     debugPrint("🔥 ERROR saat cek user: $e");
  //     await FirebaseAuth.instance.signOut();
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.clear();
  //     _navigasiGantiHalaman(const HalamanLogin());
  //   }
  // }

  Future<void> _cekStatusUser() async {
  debugPrint("⏳ Menunggu splash...");
  await Future.delayed(const Duration(seconds: 3)); 

  final user = FirebaseAuth.instance.currentUser;

  if (user == null || await _sudahLewatBatasWaktu()) {
    debugPrint("🔐 Belum login atau sesi habis (user == null / timeout)");
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _navigasiGantiHalaman(const HalamanLogin());
    return;
  }

  try {
    debugPrint("🔍 Cek user: ${user.uid}");

    final doc = await LayananFirestore().ambilUser(user.uid);

    if (!doc.exists) {
      debugPrint("❌ Data user tidak ditemukan di Firestore");
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _navigasiGantiHalaman(const HalamanLogin());
      return;
    }

    final data = doc.data() as Map<String, dynamic>; 
    final role = data['role'] ?? 'unknown';
    final disetujui = data['status'] ?? false;

    debugPrint("✅ Role: $role | Disetujui: $disetujui");

    if (role == 'admin' && !disetujui) {
      debugPrint("⛔ Admin belum disetujui");
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _navigasiGantiHalaman(const HalamanLogin());
    } else if (role == 'admin') {
      _navigasiGantiHalaman(const CatatTransaksi());
    } else if (role == 'owner') {
      _navigasiGantiHalaman(const DashboardOwner());
    } else {
      debugPrint("⚠️ Role tidak dikenal: $role");
      await FirebaseAuth.instance.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      _navigasiGantiHalaman(const HalamanLogin());
    }
  } catch (e) {
    debugPrint("🔥 ERROR saat cek user: $e");
    await FirebaseAuth.instance.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _navigasiGantiHalaman(const HalamanLogin());
  }
}


  Future<bool> _sudahLewatBatasWaktu() async {
    final prefs = await SharedPreferences.getInstance();
    final lastLogin = prefs.getInt('lastLoginMillis') ?? 0;
    final sekarang = DateTime.now().millisecondsSinceEpoch;
    return sekarang - lastLogin > 30 * 60 * 1000; // 30 menit
  }

  void _navigasiGantiHalaman(Widget tujuan) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => tujuan),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Warna.primer,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.store, size: size.width * 0.25, color: Warna.aksen),
                const SizedBox(height: 24),
                Text(
                  Teks.appJudul,
                  textAlign: TextAlign.center,
                  style: tema.textTheme.titleLarge?.copyWith(
                    color: Warna.putih,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Warna.putih),
                    strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Memuat, tunggu sebentar...',
                  style: tema.textTheme.bodyMedium?.copyWith(color: Warna.putih),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
