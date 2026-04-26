import 'package:flutter/material.dart';
import '../../core/konstanta/teks.dart';
import '../../core/route/daftar_rute.dart';
import '../../core/layanan/auth_service.dart';


class SidebarOwner extends StatelessWidget {
  final String judul; 

  const SidebarOwner({
    super.key,
    required this.judul,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final iconColor = theme.iconTheme.color ?? Colors.black;

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.primaryColor, // Ikut theme primary
            ),
            child: Text(
              judul,
              style: TextStyle(
                color: theme.appBarTheme.titleTextStyle?.color ?? Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard, color: iconColor),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacementNamed(context, Rute.dashboardOwner);
            },
          ),
          ListTile(
            leading: Icon(Icons.people, color: iconColor),
            title: const Text('Kelola Admin'),
            onTap: () {
              Navigator.pushReplacementNamed(context, Rute.kelolaAdmin);
            },
          ), ListTile(
            leading: Icon(Icons.people, color: iconColor),
            title: const Text('Kelola Menu'),
            onTap: () {
              Navigator.pushReplacementNamed(context, Rute.kelolaMenu);
            },
          ),
          ListTile(
            leading: Icon(Icons.bar_chart, color: iconColor),
            title: const Text('Laporan Penjualan'),
            onTap: () {
              Navigator.pushReplacementNamed(context, Rute.laporanPenjualan);
            },
          ),
          ListTile(
            leading: Icon(Icons.check_circle, color: iconColor),
            title: const Text('Persetujuan Admin Baru'),
            onTap: () {
              Navigator.pushReplacementNamed(context, Rute.persetujuanAdminBaru);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.logout, color: iconColor),
            title: const Text(Teks.tombolLogout),
           onTap: () async {
                await AuthService().signOut();

                if (!context.mounted) return;

                Navigator.pushReplacementNamed(context, Rute.login);
              },
          ),
        ],
      ),
    );
  }
}
