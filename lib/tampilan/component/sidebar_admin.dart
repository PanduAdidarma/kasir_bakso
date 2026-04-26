import 'package:flutter/material.dart';
import '../../core/konstanta/teks.dart';
import '../../core/route/daftar_rute.dart';
import '../../core/layanan/auth_service.dart';

class SidebarAdmin extends StatelessWidget {
  final String judul; // bikin dinamis

  const SidebarAdmin({
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
              color: theme.primaryColor, // ikut tema
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
              Navigator.pushReplacementNamed(context, Rute.dashboardAdmin);
            },
          ),
          ListTile(
            leading: Icon(Icons.restaurant_menu, color: iconColor),
            title: const Text('Lihat Menu'),
            onTap: () {
              Navigator.pushReplacementNamed(context, Rute.lihatMenuAdmin);
            },
          ),
          ListTile(
            leading: Icon(Icons.receipt, color: iconColor),
            title: const Text('Catat Transaksi'),
            onTap: () {
              Navigator.pushReplacementNamed(context, Rute.catatTransaksi);
            },
          ),
          ListTile(
            leading: Icon(Icons.history, color: iconColor),
            title: const Text('Histori Transaksi'),
            onTap: () {
              Navigator.pushReplacementNamed(context, Rute.historiTransaksiAdmin);
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
