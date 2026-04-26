import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/konstanta/warna.dart';
import '../../core/konstanta/default.dart';
import '../component/sidebar_owner.dart';
import '../../core/layanan/theme_provider.dart';
import '../../core/layanan/layanan_firestore.dart';

class DashboardOwner extends StatefulWidget {
  const DashboardOwner({super.key});

  @override
  State<DashboardOwner> createState() => _DashboardOwnerState();
}

class _DashboardOwnerState extends State<DashboardOwner> {
  final LayananFirestore layanan = LayananFirestore();
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final warnaikon = tema.appBarTheme.iconTheme?.color ?? Warna.latar;
    final gelap = tema.brightness == Brightness.dark;

    const judulhalaman = 'Dashboard Owner';

    return Scaffold(
      appBar: AppBar(
        title: const Text(judulhalaman),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: warnaikon,
        ),
        actions: [
          IconButton(
            icon: Icon(
              gelap ? Icons.dark_mode : Icons.light_mode,
              color: warnaikon,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      drawer: const SidebarOwner(judul: judulhalaman),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(DefaultSetting.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header ringkasan statistik - Tetap dalam baris
            buatHeaderStatistik(),
            const SizedBox(height: 20),
            
            // Grafik Penjualan - Full width
            buatGrafikPenjualan(context,layanan),
            const SizedBox(height: 20),
            
            // Baris untuk grafik pembayaran dan performa admin
           // Grafik metode pembayaran dan performa admin - Atas bawah
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buatGrafikPembayaran(),
                const SizedBox(height: 16),
                // buatPerformaAdmin(),
              ],
            ),

            const SizedBox(height: 20),
            
            // Menu Populer - Full width
            buatMenuPopuler(context,layanan),
            
            // Tambahan padding bawah
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buatHeaderStatistik() {
    return StreamBuilder<QuerySnapshot>(
      stream: layanan.ambilSemuaTransaksi(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final transaksi = snapshot.data!.docs;
        final hariini = DateTime.now();
        final awalbulan = DateTime(hariini.year, hariini.month, 1);
        
        // Hitung statistik
        double totalhariini = 0;
        double totalbulanini = 0;
        int jumlahhari = 0;
        int jumlahtotal = transaksi.length;

        for (var doc in transaksi) {
          final data = doc.data() as Map<String, dynamic>;
          DateTime tanggal;
          
          if (data['dibuatPada'] is Timestamp) {
            tanggal = (data['dibuatPada'] as Timestamp).toDate();
          } else if (data['dibuatPada'] is DateTime) {
            tanggal = data['dibuatPada'] as DateTime;
          } else {
            continue; // Skip if date is null or invalid
          }
          
          final total = (data['totalBayar'] as num?)?.toDouble() ?? 0.0;

          if (tanggal.isAfter(awalbulan)) {
            totalbulanini += total;
          }

          if (tanggal.day == hariini.day &&
              tanggal.month == hariini.month &&
              tanggal.year == hariini.year) {
            totalhariini += total;
            jumlahhari++;
          }
        }

        return Column(
          children: [
            // Baris pertama - 2 kartu
            Row(
              children: [
                _buatKartuStat(
                  'Penjualan Hari Ini',
                  formatter.format(totalhariini),
                  Icons.today,
                ),
                const SizedBox(width: 16),
                _buatKartuStat(
                  'Penjualan Bulan Ini',
                  formatter.format(totalbulanini),
                  Icons.calendar_month,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Baris kedua - 2 kartu
            Row(
              children: [
                _buatKartuStat(
                  'Transaksi Hari Ini',
                  '$jumlahhari',
                  Icons.receipt
                ),
                const SizedBox(width: 16),
                _buatKartuStat(
                  'Total Transaksi Keseluruhan',
                  '$jumlahtotal',
                  Icons.assessment
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buatKartuStat(String judul, String nilai, IconData ikon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(DefaultSetting.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(ikon, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      judul,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                nilai,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 Widget buatGrafikPenjualan(BuildContext context, LayananFirestore layanan) {
  final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
 final hariini = DateTime.now();
final hariiniTanggal = DateTime(hariini.year, hariini.month, hariini.day);

  return Card(
    child: Padding(
      padding: EdgeInsets.all(DefaultSetting.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Penjualan 7 Hari Terakhir',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: StreamBuilder<QuerySnapshot>(
              stream: layanan.ambilSemuaTransaksi(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final transaksi = snapshot.data!.docs;
                Map<int, double> penjualanhari = {};

                // Inisialisasi 7 hari
                for (int i = 6; i >= 0; i--) {
                  penjualanhari[i] = 0;
                }

                // Hitung total penjualan per hari
               for (var doc in transaksi) {
  final data = doc.data() as Map<String, dynamic>;
  DateTime tanggal;

  // Handle Timestamp dan DateTime
  if (data['dibuatPada'] is Timestamp) {
    tanggal = (data['dibuatPada'] as Timestamp).toDate();
  } else if (data['dibuatPada'] is DateTime) {
    tanggal = data['dibuatPada'] as DateTime;
  } else {
    continue;
  }

  final tanggalTransaksi = DateTime(tanggal.year, tanggal.month, tanggal.day);
  final total = (data['totalBayar'] as num?)?.toDouble() ?? 0.0;
  final selisihHari = hariiniTanggal.difference(tanggalTransaksi).inDays;

  if (selisihHari >= 0 && selisihHari < 7) {
    penjualanhari[6 - selisihHari] =
        (penjualanhari[6 - selisihHari] ?? 0) + total;
  }
}

                final titik = penjualanhari.entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value))
                    .toList();

                return LineChart(
                  LineChartData(
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            return LineTooltipItem(
                              formatter.format(spot.y),
                              const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              formatter.format(value).replaceAll('Rp ', ''),
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final hari = hariini.subtract(Duration(days: 6 - value.toInt()));
                            return Text(
                              '${hari.day}/${hari.month}',
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true,border: Border.all(
                      color: Colors.grey,
                      width: 1,
                         ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: titik,
                        isCurved: true,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Warna.primer.withAlpha(25),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget buatGrafikPembayaran() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(DefaultSetting.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metode Pembayaran',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: StreamBuilder<QuerySnapshot>(
                stream: layanan.ambilSemuaTransaksi(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final transaksi = snapshot.data!.docs;
                  Map<String, int> metodepembayaran = {};

                  // Hitung metode pembayaran
                  for (var doc in transaksi) {
                    final data = doc.data() as Map<String, dynamic>;
                    final metode = data['metodePembayaran'] as String? ?? 'Tidak Diketahui';
                    metodepembayaran[metode] = (metodepembayaran[metode] ?? 0) + 1;
                  }

                  final warnalist = [Warna.aksen, Warna.info];
                  int indekswarna = 0;

                  final bagian = metodepembayaran.entries.map((entry) {
                    final warna = warnalist[indekswarna % warnalist.length];
                    indekswarna++;
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.key}\n${entry.value}',
                      color: warna,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList();

                  return PieChart(
                    PieChartData(
                      sections: bagian,
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

//   Widget buatPerformaAdmin() {
//   return Card(
//     child: Padding(
//       padding: EdgeInsets.all(DefaultSetting.padding),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Performa Admin',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 250,
//             child: StreamBuilder<QuerySnapshot>(
//               stream: layanan.ambilSemuaTransaksi(),
//               builder: (context, snapshot) {
//                 if (!snapshot.hasData) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final transaksi = snapshot.data!.docs;
//                 Map<String, double> performaadmin = {};

//                 // Hitung performa admin
//                 for (var doc in transaksi) {
//                   final data = doc.data() as Map<String, dynamic>;
//                   final namadmin = data['adminNama'] as String? ?? 'Admin Tidak Diketahui';
//                   final total = (data['totalBayar'] as num?)?.toDouble() ?? 0.0;
//                   performaadmin[namadmin] = (performaadmin[namadmin] ?? 0) + total;
//                 }

//                 if (performaadmin.isEmpty) {
//                   return const Center(child: Text('Tidak ada data'));
//                 }

//                 double maxnilai = 0;
//                 for (var nilai in performaadmin.values) {
//                   if (nilai > maxnilai) {
//                     maxnilai = nilai;
//                   }
//                 }

//                  // Urutkan berdasarkan nilai terbesar
//                 final urutkan = performaadmin.entries.toList()
//                   ..sort((a, b) => b.value.compareTo(a.value)); 

//                 return ListView.builder(
//                   itemCount: urutkan.length,
//                   itemBuilder: (context, index) {
//                     final entry = urutkan[index];
//                     final persentase = entry.value / maxnilai;

//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 4),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(entry.key),
//                               Text(formatter.format(entry.value)),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           LinearProgressIndicator(
//                             value: persentase,
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
Widget buatMenuPopuler(BuildContext context, LayananFirestore layanan) {
  final tema = Theme.of(context);
  final teksUtama = tema.textTheme.titleLarge;

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    child: Padding(
      padding: const EdgeInsets.all(DefaultSetting.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Menu Populer', style: teksUtama),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: StreamBuilder<QuerySnapshot>(
              stream: layanan.ambilSemuaTransaksi(),
              builder: (context, snapshotTransaksi) {
                if (!snapshotTransaksi.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: layanan.ambilSemuaMenu(),
                  builder: (context, snapshotMenu) {
                    if (!snapshotMenu.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final transaksi = snapshotTransaksi.data!.docs;
                    final menuDocs = snapshotMenu.data!.docs;

                    // Buat map nama menu -> harga
                    final Map<String, num> hargaMenu = {
                      for (var doc in menuDocs)
                        (doc.data() as Map<String, dynamic>)['nama']: 
                        (doc.data() as Map<String, dynamic>)['harga']
                    };

                    // Hitung jumlah pemesanan per menu
                    Map<String, int> populermenu = {};
                    for (var doc in transaksi) {
                      final data = doc.data() as Map<String, dynamic>;
                      final items = data['items'] as List<dynamic>? ?? [];

                      for (var item in items) {
                        if (item is Map<String, dynamic>) {
                          final nama = item['nama'] ?? 'Menu Tidak Diketahui';
                          final qty = (item['qty'] as num?)?.toInt() ?? 0;
                          populermenu[nama] = (populermenu[nama] ?? 0) + qty;
                        }
                      }
                    }

                    if (populermenu.isEmpty) {
                      return const Center(child: Text('Tidak ada data'));
                    }

                    // Urutkan dan ambil 5 menu terlaris
                    final toplima = populermenu.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));
                    final populer = toplima.take(5).toList();

                    return ListView.separated(
                      itemCount: populer.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final entry = populer[index];
                        final harga = hargaMenu[entry.key] ?? 0;

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(entry.key),
                          subtitle: Text(
                            'Rp ${harga.toStringAsFixed(0).replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (m) => '${m[1]}.',
                            )}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text('${entry.value}x'),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

}