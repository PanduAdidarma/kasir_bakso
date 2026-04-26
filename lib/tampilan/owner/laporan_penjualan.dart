import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/konstanta/warna.dart';
import '../../core/konstanta/default.dart';
import '../../core/layanan/layanan_firestore.dart';
import '../../core/route/daftar_rute.dart';
import '../../core/layanan/theme_provider.dart';
import '../component/sidebar_owner.dart';

class LaporanPenjualan extends StatefulWidget {
  const LaporanPenjualan({super.key});

  @override
  State<LaporanPenjualan> createState() => _LaporanPenjualanState();
}

class _LaporanPenjualanState extends State<LaporanPenjualan> {
  DateTime tanggalDipilih = DateTime.now();
  final layananfirestore = LayananFirestore();

  void _pilihTanggal() async {
    DateTime? hasil = await showDatePicker(
      context: context,
      initialDate: tanggalDipilih,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(data: Theme.of(context), child: child!);
      },
    );
    if (hasil != null) {
      setState(() {
        tanggalDipilih = hasil;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.appBarTheme.iconTheme?.color ?? Warna.latar;

    final formatRupiah = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan Penjualan',
          style: theme.appBarTheme.titleTextStyle,
        ),
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
      drawer: const SidebarOwner(judul: 'Laporan Penjualan'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(DefaultSetting.padding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Laporan Tanggal',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(tanggalDipilih),
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          tanggalDipilih = DateTime.now();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                        backgroundColor: theme.colorScheme.primary.withAlpha(60),
                        foregroundColor: theme.colorScheme.primary,
                        elevation: 0,
                      ),
                      child: const Icon(Icons.restart_alt),
                    ),
                    ElevatedButton.icon(
                      onPressed: _pilihTanggal,
                      icon: const Icon(Icons.date_range),
                      label: const Text('Tanggal'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: layananfirestore.ambilSemuaTransaksi(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada transaksi.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }

                final allTransaksi = snapshot.data!.docs;

                final awal = DateTime(tanggalDipilih.year, tanggalDipilih.month, tanggalDipilih.day);
                final akhir = awal.add(const Duration(days: 1));

                final filtered = allTransaksi.where((doc) {
                  final dibuatPada = (doc['dibuatPada'] as Timestamp).toDate();
                  return dibuatPada.isAfter(awal) && dibuatPada.isBefore(akhir);
                }).toList();

                final totalPemasukan = filtered.fold<double>(
                  0,
                  (sebelumnya, doc) => sebelumnya + (doc['totalBayar'] ?? 0),
                );

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada transaksi pada tanggal ini.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  );
                }

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: DefaultSetting.padding),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Warna.primer.withAlpha(20),
                        borderRadius: BorderRadius.circular(DefaultSetting.radius),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.summarize, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total Pemasukan :",
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatRupiah.format(totalPemasukan),
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(DefaultSetting.padding),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final transaksi = filtered[index];
                          final totalBayar = transaksi['totalBayar'] ?? 0;
                          final metode = transaksi['metodePembayaran'] ?? '-';
                          final adminNama = transaksi['adminNama'] ?? '-';
                          final dibuatPada = (transaksi['dibuatPada'] as Timestamp).toDate();

                          return Card(
                            elevation: DefaultSetting.elevasiCard,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(DefaultSetting.radius),
                            ),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(DefaultSetting.radius),
                              ),
                              title: Text(
                                formatRupiah.format(totalBayar),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '$metode • $adminNama\n${DateFormat('HH:mm').format(dibuatPada)}',
                                style: theme.textTheme.bodyMedium,
                              ),
                              isThreeLine: true,
                              trailing: Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Rute.detailTransaksi,
                                  arguments: transaksi.id,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
