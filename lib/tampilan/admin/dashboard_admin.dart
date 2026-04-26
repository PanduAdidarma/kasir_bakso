

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/konstanta/warna.dart';
import '../../core/layanan/layanan_firestore.dart';
import '../../core/layanan/theme_provider.dart';
import '../component/sidebar_admin.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  final layananFirestore = LayananFirestore();
  User? user;
  late String uid;

  String selectedChart = 'Ringkasan Transaksi';

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user!.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.appBarTheme.iconTheme?.color ?? Warna.latar;

    const pageTitle = 'Dashboard Admin';

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User tidak ditemukan')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(pageTitle),
        centerTitle: true,
        iconTheme: IconThemeData(color: iconColor),
        actions: [
          IconButton(
            icon: Icon(
              theme.brightness == Brightness.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: iconColor,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      drawer: const SidebarAdmin(judul: pageTitle),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔽 Dropdown Switch
            DropdownButton<String>(
              value: selectedChart,
              items: const [
                DropdownMenuItem(
                  value: 'Ringkasan Transaksi',
                  child: Text('Ringkasan Transaksi'),
                ),
                DropdownMenuItem(
                  value: 'Menu Paling Laku',
                  child: Text('Menu Paling Laku'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedChart = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            // 🔽 StreamBuilder
           Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: selectedChart == 'Ringkasan Transaksi'
                    ? layananFirestore.ambilTransaksiByAdmin(uid)
                    : layananFirestore.ambilSemuaTransaksi(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Belum ada transaksi'));
                  }

                  final transaksi = snapshot.data!.docs;

                  if (selectedChart == 'Ringkasan Transaksi') {
                    return PenjualanRingkasan(transaksi: transaksi);
                  } else {
                    return MenuLakuChart(transaksi: transaksi);
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
class PenjualanRingkasan extends StatelessWidget {
  final List<QueryDocumentSnapshot> transaksi;

  const PenjualanRingkasan({
    super.key,
    required this.transaksi,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final user = FirebaseAuth.instance.currentUser;
    final adminIdLogin = user?.uid ?? '';

    final transaksiKamu = transaksi.where((doc) {
      final adminId = (doc['adminId'] ?? '') as String;
      return adminId.trim() == adminIdLogin.trim();
    }).toList();

    final totalTransaksiKamu = transaksiKamu.length;

    // 🔑 Map tanggal -> jumlah transaksi
    final Map<String, int> tanggalTransaksi = {};

    for (var doc in transaksiKamu) {
      final createdAt = (doc['dibuatPada'] as Timestamp).toDate();
      final hari = DateFormat('EEEE', 'id_ID').format(createdAt); 
      final tanggal = DateFormat('dd-MM-yyyy').format(createdAt);

      final tanggalLengkap = '$hari, $tanggal';


     tanggalTransaksi[tanggalLengkap] = (tanggalTransaksi[tanggalLengkap] ?? 0) + 1;

    }

    final sortedTanggal = tanggalTransaksi.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Transaksi Kamu :',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Total Transaksi Kamu'),
            trailing: Text(
              '$totalTransaksiKamu Transaksi',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Tanggal Transaksi',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...sortedTanggal.map(
          (tgl) => Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Warna.aksen),
              title: Text(
                tgl,
                style: theme.textTheme.bodyLarge,
              ),
              trailing: Text(
                '${tanggalTransaksi[tgl]} transaksi',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MenuLakuChart extends StatelessWidget {

  final List<QueryDocumentSnapshot> transaksi;

  const MenuLakuChart({super.key, required this.transaksi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final kategoriMap = <String, int>{};

    for (var doc in transaksi) {
      for (var item in doc['items']) {
        final nama = item['nama'] as String;
        kategoriMap[nama] = (kategoriMap[nama] ?? 0) + (item['qty'] as int);
      }
    }

    if (kategoriMap.isEmpty) {
      return const Center(child: Text('Belum ada data menu terjual'));
    }

    final data = kategoriMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    const maxSlices = 6;
    
    final mainSlices = data.take(maxSlices).toList();
   final otherTotal = data.skip(maxSlices).fold(0, (total, item) => total + item.value);

    if (otherTotal > 0) {
      mainSlices.add(MapEntry('Lainnya', otherTotal));
    }

    final colors = [
      const Color.fromARGB(255, 112, 122, 23),
      Warna.aksen,
      Colors.green,
      Colors.orange,
      Colors.blue,
      Colors.purple,
      Colors.grey, 
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Menu Paling Laku',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: mainSlices.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return PieChartSectionData(
                  title: '',
                  value: item.value.toDouble(),
                  color: colors[index % colors.length],
                  radius: 60,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Keterangan:',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView(
            children: mainSlices.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: colors[index % colors.length],
                  radius: 8,
                ),
                title: Text(item.key),
                trailing: Text('${item.value} terjual'),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
