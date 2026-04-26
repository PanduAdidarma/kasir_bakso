import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/konstanta/warna.dart';
import '../../core/konstanta/default.dart';
import '../../core/layanan/layanan_firestore.dart';
import '../../core/layanan/theme_provider.dart';
import '../component/sidebar_admin.dart';

class HistoriTransaksiAdmin extends StatefulWidget {
  const HistoriTransaksiAdmin({super.key});

  @override
  State<HistoriTransaksiAdmin> createState() => _HistoriTransaksiAdminState();
}

class _HistoriTransaksiAdminState extends State<HistoriTransaksiAdmin> {
  final layananFirestore = LayananFirestore();
  final user = FirebaseAuth.instance.currentUser;

  String? namaAdmin;
  DateTime? tanggalDipilih;

  @override
  void initState() {
    super.initState();
    ambilNamaAdmin();
  }

  Future<void> ambilNamaAdmin() async {
    if (user == null) return;

    final doc = await layananFirestore.ambilUser(user!.uid);
    final data = doc.data() as Map<String, dynamic>?;

    if (mounted) {
      setState(() {
        namaAdmin = data?['nama'] ?? 'Admin';
      });
    }
  }

  // ⬅️ FUNGSI BARU: Konfirmasi hapus transaksi
  Future<void> _konfirmasiHapusTransaksi(String transactionId, String totalBayar) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red[600],
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text('Konfirmasi Hapus'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withAlpha(100),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.error.withAlpha(100),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: theme.colorScheme.error,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total: $totalBayar',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Data yang dihapus tidak dapat dikembalikan.',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(150),
                  fontSize: 13,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface.withAlpha(150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _hapusTransaksi(transactionId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // ⬅️ FUNGSI BARU: Hapus transaksi
  Future<void> _hapusTransaksi(String transactionId) async {
    try {
      // Tampilkan loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await layananFirestore.hapusTransaksi(transactionId);
      
      // Tutup loading
      if (mounted) Navigator.of(context).pop();

      // Tampilkan sukses
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Transaksi berhasil dihapus'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      // Tutup loading
      if (mounted) Navigator.of(context).pop();

      // Tampilkan error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Gagal menghapus: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final iconColor = theme.appBarTheme.iconTheme?.color ?? Warna.latar;
  const pageTitle = 'Histori Transaksi';
  final uid = user?.uid;

  if (uid == null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gagal ambil UID admin'),
          backgroundColor: theme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(pageTitle),
        centerTitle: true,
        iconTheme: IconThemeData(color: iconColor),
      ),
      drawer: const SidebarAdmin(judul: pageTitle),
      body: const Center(child: Text('Kamu belum login')),
    );
  }

  return Scaffold(
   appBar: AppBar(
  centerTitle: true,
  iconTheme: IconThemeData(color: iconColor),
  title: SizedBox(
    width: MediaQuery.of(context).size.width * 0.8,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          pageTitle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '(${namaAdmin ?? '...'})',
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    ),
  ),
  actions: [
    IconButton(
      icon: Icon(
        isDark ? Icons.dark_mode : Icons.light_mode,
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
      padding: const EdgeInsets.all(DefaultSetting.padding),
      child: StreamBuilder<QuerySnapshot>(
        stream: layananFirestore.ambilTransaksiByAdmin(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Gagal memuat transaksi.'));
          }

          final allTransaksi = snapshot.data!.docs;
          final tanggalFilter = tanggalDipilih ?? DateTime.now();

          final transaksiList = allTransaksi.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['dibuatPada'];

            final waktu = timestamp is Timestamp
                ? timestamp.toDate()
                : DateTime.now();

            final awal = DateTime(tanggalFilter.year, tanggalFilter.month, tanggalFilter.day);
            final akhir = awal.add(const Duration(days: 1));

            return waktu.isAfter(awal.subtract(const Duration(milliseconds: 1))) &&
                   waktu.isBefore(akhir);
          }).toList();

          if (transaksiList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: theme.colorScheme.primary.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tanggalDipilih != null
                        ? 'Tidak ada transaksi pada ${DateFormat('dd MMM yyyy').format(tanggalDipilih!)}.'
                        : 'Belum ada transaksi.',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final totalPendapatan = transaksiList.fold<double>(
            0,
            (total, doc) {
              final data = doc.data() as Map<String, dynamic>;
              return total + (data['totalBayar'] ?? 0).toDouble();
            },
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced date filter chip
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: tanggalDipilih != null
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withAlpha(180),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: theme.colorScheme.primary.withAlpha(100),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Filter: ${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(tanggalDipilih!)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onPrimaryContainer,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => setState(() => tanggalDipilih = null),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onPrimaryContainer.withAlpha(60),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: theme.colorScheme.outline.withAlpha(80),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.today,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Transaksi (${DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(tanggalFilter)})',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              
              // Enhanced total revenue display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [
                            theme.colorScheme.primary.withAlpha(40),
                            theme.colorScheme.primary.withAlpha(20),
                          ]
                        : [
                            theme.colorScheme.primary.withAlpha(25),
                            theme.colorScheme.primary.withAlpha(10),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withAlpha(80),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(50),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Total Pendapatan',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${NumberFormat.decimalPattern('id').format(totalPendapatan)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // ⬅️ INFO: Tambahkan info cara hapus
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.blue.withAlpha(100),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tekan dan tahan transaksi untuk menghapus',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Enhanced transaction list
              Expanded(
                child: ListView.builder(
                  itemCount: transaksiList.length,
                  itemBuilder: (context, index) {
                    final transaksi = transaksiList[index];
                    final data = transaksi.data() as Map<String, dynamic>;

                    final dibuatPada = data['dibuatPada'];
                    final DateTime dateTime = dibuatPada is Timestamp
                        ? dibuatPada.toDate()
                        : (dibuatPada is DateTime ? dibuatPada : DateTime.now());

                    final total = (data['totalBayar'] ?? 0).toDouble();
                    final metode = data['metodePembayaran'] ?? '-';
                    final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
                    final transactionId = transaksi.id; // ⬅️ Ambil ID transaksi

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outline.withAlpha(60),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withAlpha(15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => showDetailTransaksi(context, data, theme),
                          // ⬅️ TAMBAHKAN: Long press untuk hapus
                          onLongPress: () {
                            final totalBayarFormatted = 'Rp ${NumberFormat.decimalPattern('id').format(total)}';
                            _konfirmasiHapusTransaksi(transactionId, totalBayarFormatted);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.green.withAlpha(40),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long,
                                    color: Colors.green,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rp ${NumberFormat.decimalPattern('id').format(total)}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.payment,
                                            size: 14,
                                            color: theme.colorScheme.onSurface.withAlpha(120),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            metode,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurface.withAlpha(150),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Icon(
                                            Icons.calendar_today,
                                            size: 14,
                                            color: theme.colorScheme.onSurface.withAlpha(120),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormat('dd MMM yyyy', 'id_ID').format(dateTime),
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurface.withAlpha(150),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.shopping_cart,
                                            size: 14,
                                            color: theme.colorScheme.onSurface.withAlpha(120),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${items.length} item${items.length > 1 ? 's' : ''}',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.primary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: theme.colorScheme.onSurface.withAlpha(100),
                                ),
                              ],
                            ),
                          ),
                        ),
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
    floatingActionButton: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (tanggalDipilih != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: FloatingActionButton(
              heroTag: 'resetTanggal',
              onPressed: () {
                setState(() => tanggalDipilih = null);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pencarian Tanggal Direset.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              tooltip: 'Reset Tanggal',
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.refresh),
            ),
          ),
        FloatingActionButton.extended(
          heroTag: 'pilihTanggal',
          onPressed: () async {
           final picked = await showDatePicker(
            context: context,
            initialDate: tanggalDipilih ?? DateTime.now(),
            firstDate: DateTime(2023),
            lastDate: DateTime.now(),
            helpText: 'Pilih Tanggal Transaksi',
            cancelText: 'Batal',
            confirmText: 'Pilih',
            builder: (context, child) {
              return Localizations.override(
                context: context,
                locale: const Locale('id', 'ID'),
                child: Theme(
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(
                      primary: theme.colorScheme.primary,
                      onPrimary: theme.colorScheme.onPrimary,
                      surface: theme.colorScheme.surface,
                      onSurface: theme.colorScheme.onSurface,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  child: child!,
                ),
              );
            },
          );

            if (picked != null) {
              setState(() => tanggalDipilih = picked);
            }
          },
          label: const Text('Pilih Tanggal'),
          icon: const Icon(Icons.date_range),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 4,
        ),
      ],
    ),
  );
  }
}

Future<void> showDetailTransaksi(
  BuildContext context,
  Map<String, dynamic> data,
  ThemeData theme,
) async {
  final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
  final totalBayar = (data['totalBayar'] ?? 0).toDouble();
  final metodePembayaran = data['metodePembayaran'] ?? '-';
  final dibuatPada = data['dibuatPada'];
  final DateTime dateTime = dibuatPada is Timestamp
      ? dibuatPada.toDate()
      : (dibuatPada is DateTime ? dibuatPada : DateTime.now());

  await showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Enhanced header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withAlpha(40),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.receipt_long,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Detail Transaksi',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: theme.colorScheme.onSurface.withAlpha(120),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy • HH:mm', 'id_ID').format(dateTime),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.payment,
                          size: 16,
                          color: theme.colorScheme.onSurface.withAlpha(120),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          metodePembayaran,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Enhanced items list
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daftar Item (${items.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, __) => Divider(
                            color: theme.colorScheme.outline.withAlpha(60),
                            height: 16,
                          ),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final nama = item['nama'] ?? '-';
                            final harga = item['harga'] ?? 0;
                            final qty = item['qty'] ?? 0;
                            final total = harga * qty;
                            final kategori = item['kategori'] ?? '-';

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.colorScheme.outline.withAlpha(40),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: (kategori == 'Minuman' ? Colors.blue : Colors.brown).withAlpha(40),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      kategori == 'Minuman'
                                          ? Icons.local_drink
                                          : Icons.restaurant,
                                      color: kategori == 'Minuman' ? Colors.blue : Colors.brown,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          nama,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Rp ${NumberFormat.decimalPattern('id').format(harga)} × $qty',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withAlpha(150),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withAlpha(70),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                    child: Text(
                                      'Rp ${NumberFormat.decimalPattern('id').format(total)}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
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
              ),

              // Enhanced total section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withAlpha(120),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Rp ${NumberFormat.decimalPattern('id').format(totalBayar)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}