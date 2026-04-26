import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/layanan/theme_provider.dart';
import '../../core/layanan/layanan_firestore.dart';
import '../../core/konstanta/warna.dart';

class DetailTransaksi extends StatefulWidget {
  final String id;

  const DetailTransaksi({super.key, required this.id});

  @override
  State<DetailTransaksi> createState() => _DetailTransaksiState();
}

class _DetailTransaksiState extends State<DetailTransaksi> with TickerProviderStateMixin {
  late Future<DocumentSnapshot<Map<String, dynamic>>> future;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final layananFirestore = LayananFirestore();

  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    future = layananFirestore.ambilTransaksiById(widget.id);

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
    final iconColor = theme.appBarTheme.iconTheme?.color ?? Warna.latar;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        centerTitle: true,
        iconTheme: IconThemeData(color: iconColor),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.light_mode),
              color: iconColor,
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat data transaksi...',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: theme.colorScheme.primary.withAlpha((255 * 0.5).round()),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Transaksi tidak ditemukan',
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data()!;
          final total = data['totalBayar'] ?? 0;
          final admin = data['adminNama'] ?? '-';
          final metode = data['metodePembayaran'] ?? '-';
          final waktu = (data['dibuatPada'] as Timestamp).toDate();
          final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card dengan Total
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withAlpha((255 * 0.8).round()),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha((255 * 0.3).round()),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                   
child: Column(
  children: [
    Icon(
      Icons.receipt,
      color: theme.colorScheme.surface,
      size: 32,
    ),
    const SizedBox(height: 8),
    Text(
      'Total Pembayaran',
      style: TextStyle(
        color: theme.colorScheme.surface,
        fontSize: 14,
      ),
    ),
    const SizedBox(height: 4),
    Text(
      formatter.format(total),
      style: TextStyle(
        color: theme.colorScheme.surface,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
)
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Informasi Transaksi
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withAlpha((255 * 0.1).round()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Warna.borderGelap.withAlpha((255 * 0.1).round()),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Informasi Transaksi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                       
                      Padding(
  padding: const EdgeInsets.all(16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person_outline, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                admin,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.payment_outlined, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Metode Pembayaran',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                metode,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha((255 * 0.1).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.access_time, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Waktu Transaksi',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('dd MMM yyyy – HH:mm', 'id_ID').format(waktu),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
)


                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Daftar Item
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withAlpha((255 * 0.1).round()),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha((255 * 0.1).round()),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Daftar Item (${items.length})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 48,
                                    color: theme.colorScheme.primary.withAlpha((255 * 0.5).round()),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tidak ada item dalam transaksi ini',
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          Column(
                            children: items.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;
                              final nama = item['nama'] ?? '-';
                              final harga = item['harga'] ?? 0;
                              final qty = item['qty'] ?? 0;
                              final subtotal = harga * qty;
                              final isLast = index == items.length - 1;

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  border: isLast ? null : Border(
                                    bottom: BorderSide(
                                      color: theme.dividerColor.withAlpha((255 * 0.3).round()),
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.onPrimary.withAlpha((255 * 0.1).round()),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: TextStyle(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nama,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                formatter.format(harga),
                                                style: TextStyle(
                                                  color: theme.textTheme.bodyMedium?.color,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              Text(
                                                ' × $qty',
                                                style: TextStyle(
                                                  color: theme.colorScheme.primary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withAlpha((255 * 0.1).round()),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        formatter.format(subtotal),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// class BuildTile extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;

//   const BuildTile({
//     super.key,
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
    
//     return Row(
//       children: [
//         Container(
//           width: 32,
//           height: 32,
//           decoration: BoxDecoration(
//             color: theme.colorScheme.primary.withAlpha((255 * 0.1).round()),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(
//             icon,
//             color: theme.colorScheme.primary,
//             size: 18,
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: theme.textTheme.bodyMedium?.color,
//                   fontSize: 13,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 15,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }