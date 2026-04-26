import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/konstanta/warna.dart';
import '../../core/layanan/layanan_firestore.dart';
import '../../core/layanan/theme_provider.dart';
import '../component/sidebar_owner.dart';

class KelolaAdmin extends StatefulWidget {
  const KelolaAdmin({super.key});

  @override
  State<KelolaAdmin> createState() => _KelolaAdminState();
}

class _KelolaAdminState extends State<KelolaAdmin> 
    with SingleTickerProviderStateMixin {
  final LayananFirestore layanan = LayananFirestore();
  final String uidLogin = FirebaseAuth.instance.currentUser?.uid ?? '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = theme.appBarTheme.iconTheme?.color ?? Warna.latar;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Admin'),
        centerTitle: true,
        iconTheme: IconThemeData(color: iconColor),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                ? [Warna.primerGelap, Warna.primerGelap.withAlpha(20)]
                : [Warna.primer, Warna.primer.withAlpha(20)],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  key: ValueKey(isDark),
                  color: iconColor,
                ),
              ),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
          ),
        ],
      ),
      drawer: const SidebarOwner(judul: 'Kelola Admin'),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark 
              ? [Warna.latarGelap, Warna.latarGelap.withAlpha(20)]
              : [Warna.latar.withAlpha(20), Warna.latar],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: layanan.ambilSemuaAdminDanOwner(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? Warna.kartuGelap : Warna.putih,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? Warna.primerGelap : Warna.primer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat data...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Warna.teksSekunderGelap : Warna.teksSekunder,
                      ),
                    ),
                  ],
                ),
              );
            }

            final admins = snapshot.data!.docs.where((doc) {
              final uid = doc['uid'] ?? '';
              return uid != uidLogin;
            }).toList();

            if (admins.isEmpty) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark ? Warna.kartuGelap : Warna.putih,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.admin_panel_settings_outlined,
                              size: 64,
                              color: isDark ? Warna.primerGelap : Warna.primer,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum Ada Admin Lain',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Daftar admin akan muncul di sini',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark ? Warna.teksSekunderGelap : Warna.teksSekunder,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return FadeTransition(
              opacity: _fadeAnimation,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: admins.length,
                itemBuilder: (context, index) {
                  final admin = admins[index];
                  final docId = admin.id;
                  final nama = admin['nama'] ?? '';
                  final role = admin['role'] ?? '';
                  final statusBool = admin['status'] == true;
                  final status = statusBool ? 'Disetujui' : 'Diblokir';

                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    curve: Curves.easeOutBack,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark 
                            ? [Warna.kartuGelap, Warna.kartuGelap.withAlpha(20)]
                            : [Warna.putih, Warna.putih.withAlpha(20)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 20 : 20),
                            blurRadius: 15,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Bisa ditambahkan aksi ketika card diklik
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Hero(
                                  tag: 'avatar_$docId',
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: role == 'owner'
                                          ? [Colors.amber, Colors.orange]
                                          : [
                                              isDark ? Warna.primerGelap : Warna.primer, 
                                              (isDark ? Warna.primerGelap : Warna.primer).withAlpha(20)
                                            ],
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isDark ? Warna.primerGelap : Warna.primer).withAlpha(20),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      role == 'owner'
                                          ? Icons.verified
                                          : Icons.admin_panel_settings,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nama,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: role == 'owner' 
                                                ? Colors.amber.withAlpha(20)
                                                : (isDark ? Warna.primerGelap : Warna.primer).withAlpha(20),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              role.toUpperCase(),
                                              style: TextStyle(
                                                color: role == 'owner' 
                                                  ? Colors.amber[700]
                                                  : isDark ? Warna.primerGelap : Warna.primer,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: statusBool 
                                                ? Colors.green.withAlpha(20)
                                                : Colors.red.withAlpha(20),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              status,
                                              style: TextStyle(
                                                color: statusBool 
                                                  ? Colors.green[700]
                                                  : Colors.red[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withAlpha(20),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: isDark ? Warna.teksUtamaGelap : Warna.teksUtama,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 8,
                                    onSelected: (value) async {
                                      await _handleMenuAction(value, docId, role, statusBool);
                                    },
                                    itemBuilder: (context) => [
                                      _buildPopupMenuItem(
                                        'Ubah Role',
                                        Icons.swap_horiz,
                                        Colors.blue,
                                      ),
                                      _buildPopupMenuItem(
                                        'Setujui',
                                        Icons.check_circle_outline,
                                        Colors.green,
                                      ),
                                      _buildPopupMenuItem(
                                        'Blokir',
                                        Icons.block,
                                        Colors.orange,
                                      ),
                                      _buildPopupMenuItem(
                                        'Hapus',
                                        Icons.delete_outline,
                                        Colors.red,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(String value, IconData icon, Color color) {
    return PopupMenuItem(
      value: value,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMenuAction(String value, String docId, String role, bool statusBool) async {
    if (value == 'Ubah Role') {
      final roleBaru = role == 'admin' ? 'owner' : 'admin';
      final confirmed = await _showKonfirmasi(
        'Yakin mau ubah role ke $roleBaru?',
        'Perubahan ini akan mengubah hak akses pengguna.',
      );
      if (confirmed == true) {
        await layanan.perbaruiRoleUser(docId, roleBaru);
        _showSnackbar('Role berhasil diubah ke $roleBaru', Colors.blue);
      }
    } else if (value == 'Setujui') {
      if (statusBool) {
        await _showInfo('${role[0].toUpperCase()}${role.substring(1)} ini sudah disetujui.');
      } else {
        final confirmed = await _showKonfirmasi(
          'Yakin mau menyetujui $role ini?',
          'Pengguna akan mendapat akses penuh setelah disetujui.',
        );
        if (confirmed == true) {
          await layanan.blokirUser(docId, true);
          _showSnackbar('${role[0].toUpperCase()}${role.substring(1)} berhasil disetujui', Colors.green);
        }
      }
    } else if (value == 'Blokir') {
      if (!statusBool) {
        await _showInfo('${role[0].toUpperCase()}${role.substring(1)} ini sudah diblokir.');
      } else {
        final confirmed = await _showKonfirmasi(
          'Yakin mau blokir $role ini?',
          'Pengguna tidak akan bisa mengakses sistem setelah diblokir.',
        );
        if (confirmed == true) {
          await layanan.blokirUser(docId, false);
          _showSnackbar('${role[0].toUpperCase()}${role.substring(1)} berhasil diblokir', Colors.orange);
        }
      }
    } else if (value == 'Hapus') {
      final confirmed = await _showKonfirmasi(
        'Yakin mau hapus $role ini?',
        'Data yang dihapus tidak dapat dikembalikan!',
      );
      if (confirmed == true) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .delete();
        _showSnackbar('${role[0].toUpperCase()}${role.substring(1)} berhasil dihapus', Colors.red);
      }
    }

    if (mounted) setState(() {});
  }

  Future<bool?> _showKonfirmasi(String judul, String deskripsi) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: isDark ? Warna.kartuGelap : Warna.putih,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Konfirmasi'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              judul,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              deskripsi,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Warna.teksSekunderGelap : Warna.teksSekunder,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Lanjut'),
          ),
        ],
      ),
    );
  }

  Future<void> _showInfo(String pesan) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: isDark ? Warna.kartuGelap : Warna.putih,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Informasi'),
          ],
        ),
        content: Text(pesan),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}