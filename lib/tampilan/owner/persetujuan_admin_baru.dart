import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/konstanta/warna.dart';
import '../../core/layanan/theme_provider.dart';
import '../../core/layanan/layanan_firestore.dart';
import '../component/sidebar_owner.dart';

class PersetujuanAdminBaru extends StatelessWidget {
  const PersetujuanAdminBaru({super.key});

  void _tampilkanKonfirmasi(BuildContext context, String userId, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: Text("Setujui admin dengan nama \"$nama\"?"),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          ElevatedButton(
            child: const Text("Setujui"),
            onPressed: () async {
              Navigator.of(ctx).pop(); // tutup dialog
              await LayananFirestore().blokirUser(userId, true);

              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Admin \"$nama\" telah disetujui."),
                  backgroundColor: Warna.primer,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.appBarTheme.iconTheme?.color ?? Warna.latar;
    const pageTitle = 'Persetujuan Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text(pageTitle),
        centerTitle: true,
        iconTheme: IconThemeData(color: iconColor),
        actions: [
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark ? Icons.dark_mode : Icons.light_mode,
              color: iconColor,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      drawer: const SidebarOwner(judul: pageTitle),
      body: StreamBuilder<QuerySnapshot>(
        stream: LayananFirestore().ambilUserBelumDisetujui(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Tidak ada admin yang menunggu persetujuan.',
                style: theme.textTheme.bodyMedium,
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final user = docs[index];
              final nama = user['nama'] ?? '-';
              final email = user['email'] ?? '-';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(nama, style: theme.textTheme.titleLarge),
                  subtitle: Text(email, style: theme.textTheme.bodyMedium),
                  trailing: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Setujui'),
                    onPressed: () => _tampilkanKonfirmasi(context, user.id, nama),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
