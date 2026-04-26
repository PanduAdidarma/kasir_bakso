import 'package:flutter/material.dart';
import '../../tampilan/auth/halaman_login.dart';
import '../../tampilan/auth/halaman_daftar.dart';
import '../../tampilan/admin/dashboard_admin.dart';
import '../../tampilan/admin/lihat_menu_admin.dart';
import '../../tampilan/owner/kelola_menu.dart';
import '../../tampilan/owner/tambah_menu.dart';
import '../../tampilan/owner/edit_menu.dart';
import '../../tampilan/admin/catat_transaksi.dart';
import '../../tampilan/admin/histori_transaksi_admin.dart';
import '../../tampilan/owner/dashboard_owner.dart';
import '../../tampilan/owner/kelola_admin.dart';
import '../../tampilan/owner/detail_transaksi.dart';
import '../../tampilan/owner/laporan_penjualan.dart';
import '../../tampilan/auth/splash_halaman.dart';
import '../../tampilan/owner/persetujuan_admin_baru.dart';
import 'daftar_rute.dart';
import 'halaman_tidak_ditemukan.dart';

class GeneratorRute {
  static Route<dynamic> generate(RouteSettings settings) {
    switch (settings.name) {
      case Rute.splash:
        return MaterialPageRoute(builder: (_) => const SplashHalaman());
      case Rute.login:
        return MaterialPageRoute(builder: (_) => const HalamanLogin());
      case Rute.daftar:
        return MaterialPageRoute(builder: (_) => const HalamanDaftar());
    

      case Rute.dashboardAdmin:
        return MaterialPageRoute(builder: (_) => const DashboardAdmin());
      case Rute.kelolaMenu:
        return MaterialPageRoute(builder: (_) => const KelolaMenu());
      case Rute.lihatMenuAdmin:
        return MaterialPageRoute(builder: (_) => const LihatMenuAdmin());
      case Rute.tambahMenu:
        return MaterialPageRoute(builder: (_) => const TambahMenu());
      case Rute.editMenu:
        final menuData = settings.arguments as Map<String, dynamic>; 
        return MaterialPageRoute(
          builder: (_) => EditMenu(menuData: menuData)
        );
      case Rute.catatTransaksi:
        return MaterialPageRoute(builder: (_) => const CatatTransaksi());
      case Rute.historiTransaksiAdmin:
        return MaterialPageRoute(builder: (_) => const HistoriTransaksiAdmin());

      case Rute.dashboardOwner:
        return MaterialPageRoute(builder: (_) => const DashboardOwner());
      case Rute.kelolaAdmin:
        return MaterialPageRoute(builder: (_) => const KelolaAdmin());
      case Rute.detailTransaksi:
  final id = settings.arguments as String;
  return MaterialPageRoute(builder: (_) => DetailTransaksi(id: id));
      case Rute.laporanPenjualan:
        return MaterialPageRoute(builder: (_) => const LaporanPenjualan());
      case Rute.persetujuanAdminBaru:
        return MaterialPageRoute(builder: (_) => const PersetujuanAdminBaru());

      default:
        return MaterialPageRoute(builder: (_) => const HalamanTidakDitemukan());
    }
  }
}
