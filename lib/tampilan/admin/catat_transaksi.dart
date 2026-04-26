import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/konstanta/warna.dart';
import '../../core/konstanta/default.dart';
import '../../core/layanan/layanan_firestore.dart';
import '../../core/layanan/theme_provider.dart';
import '../component/sidebar_admin.dart';

class CatatTransaksi extends StatefulWidget {
  const CatatTransaksi({super.key});

  @override
  State<CatatTransaksi> createState() => _CatatTransaksiState();
}

class _CatatTransaksiState extends State<CatatTransaksi>
    with SingleTickerProviderStateMixin {
  final layananFirestore = LayananFirestore();
  late TabController tabController;

  String metodePembayaran = 'Tunai';
  final List<Map<String, dynamic>> keranjang = [];
  String kategoriTerpilih = 'Semua';

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  num get totalBayar =>
      keranjang.fold(0, (total, item) => total + item['subtotal']);

  void tambahKeKeranjang(Map<String, dynamic> menu, int qty) {
    final nama = menu['nama'];
    final harga = menu['harga'];

    final index = keranjang.indexWhere((item) => item['nama'] == nama);

    if (index != -1) {
      keranjang[index]['qty'] += qty;
      keranjang[index]['subtotal'] =
          keranjang[index]['harga'] * keranjang[index]['qty'];
    } else {
      keranjang.add({
        'nama': nama,
        'harga': harga,
        'qty': qty,
        'subtotal': harga * qty,
        'kategori': menu['kategori'] ?? 'Makanan',
      });
    }

    setState(() {});
    
    // Haptic feedback untuk memberikan respons sentuhan
    HapticFeedback.lightImpact();
  }
Future<void> simpanTransaksi() async {
  if (keranjang.isEmpty) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Keranjang masih kosong'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DefaultSetting.radius),
        ),
      ),
    );
    return;
  }

  final uid = FirebaseAuth.instance.currentUser?.uid;

  if (uid == null) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Gagal ambil UID admin'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  try {
    final doc = await layananFirestore.ambilUser(uid);
    final namaAdmin = doc.get('nama');

    await layananFirestore.catatTransaksi(
      adminId: uid,
      adminNama: namaAdmin,
      items: keranjang,
      totalBayar: totalBayar,
      metodePembayaran: metodePembayaran,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Transaksi berhasil dicatat'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DefaultSetting.radius),
        ),
      ),
    );

    keranjang.clear();
    if (mounted) setState(() {}); // hanya setState jika masih mounted

    HapticFeedback.mediumImpact();
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

Future<void> showInputQtyDialog(Map<String, dynamic> menu) async {
  final qtyController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DefaultSetting.radius * 2),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(DefaultSetting.radius),
            ),
            child: Icon(
              menu['kategori'] == 'Minuman' ? Icons.local_drink : Icons.restaurant,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  menu['nama'],
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Rp ${NumberFormat.decimalPattern('id').format(menu['harga'])}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Jumlah',
            prefixIcon: const Icon(Icons.shopping_cart),
            suffixText: menu['kategori'] == 'Minuman' ? 'gelas' : 'porsi',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DefaultSetting.radius),
            ),
          ),
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Batal'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_shopping_cart),
          label: const Text('Tambah'),
          onPressed: () {
            final qty = int.tryParse(qtyController.text) ?? 0;
            if (qty > 0) {
              tambahKeKeranjang(menu, qty);
              Navigator.pop(context);
            } else {
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jumlah harus lebih dari 0'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
    ),
  );
}

Future<void> showEditQtyDialog(int index) async {
  final item = keranjang[index];
  final qtyController = TextEditingController(text: item['qty'].toString());

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DefaultSetting.radius * 2),
      ),
      title: Text('Edit Jumlah: ${item['nama']}'),
      content: SingleChildScrollView(
        child: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Jumlah',
            prefixIcon: const Icon(Icons.edit),
            suffixText: 'pcs',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DefaultSetting.radius),
            ),
          ),
          autofocus: true,
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Batal'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.save),
          label: const Text('Simpan'),
          onPressed: () {
            final qtyBaru = int.tryParse(qtyController.text) ?? 0;
            if (qtyBaru > 0) {
              item['qty'] = qtyBaru;
              item['subtotal'] = item['harga'] * qtyBaru;
              setState(() {});
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            } else {
              HapticFeedback.heavyImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jumlah harus lebih dari 0'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
    ),
  );
}

  Widget buildMenuCard(Map<String, dynamic> data) {
    final isMinuman = data['kategori'] == 'Minuman';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6), // Reduced margin
      child: Card(
        elevation: 1, // Reduced elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DefaultSetting.radius),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(DefaultSetting.radius),
          onTap: () => showInputQtyDialog(data),
          child: Padding(
            padding: const EdgeInsets.all(6), // Reduced padding
            child: Row(
              children: [
                Container(
                  width: 48, // Reduced from 60
                  height: 32, // Reduced from 40
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isMinuman
                          ? [Colors.blue.shade100, Colors.blue.shade300]
                          : [Colors.orange.shade100, Colors.orange.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8), // Smaller radius
                  ),
                  child: Icon(
                    isMinuman ? Icons.local_drink : Icons.restaurant,
                    color: isMinuman ? Colors.blue.shade700 : Colors.orange.shade700,
                    size: 20, // Reduced from 30
                  ),
                ),
                const SizedBox(width: 12), // Reduced spacing
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['nama'],
                        style: Theme.of(context).textTheme.titleSmall?.copyWith( // Changed to titleSmall
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2), // Reduced spacing
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), // Reduced padding
                       decoration: BoxDecoration(
                          color: isMinuman 
                              ? Colors.blue.withAlpha(25)
                              : Colors.orange.withAlpha(25),
                          borderRadius: BorderRadius.circular(8), // Smaller radius
                        ),
                        child: Text(
                          data['kategori'] ?? 'Makanan',
                          style: TextStyle(
                            fontSize: 10, // Reduced from 12
                            color: isMinuman ? const Color.fromARGB(255, 137, 196, 245) : Colors.orange.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4), // Reduced spacing
                      Text(
                        'Rp ${NumberFormat.decimalPattern('id').format(data['harga'])}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith( // Changed to bodyMedium
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36, 
                  decoration: BoxDecoration(
                    color: Theme.of(context).secondaryHeaderColor,
                    borderRadius: BorderRadius.circular(18), 
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildKeranjangItem(int index) {
    final item = keranjang[index];
    final isMinuman = item['kategori'] == 'Minuman';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DefaultSetting.radius),
           side: BorderSide(
          color: const Color.fromARGB(255, 145, 145, 145), // Warna border
          width: 1,
        ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isMinuman 
                      ? Colors.blue.withAlpha(20)
                      : Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  isMinuman ? Icons.local_drink : Icons.restaurant,
                  color: isMinuman ? Colors.blue.shade600 : Colors.orange.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item['nama']} (x${item['qty']})',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Subtotal: Rp ${NumberFormat.decimalPattern('id').format(item['subtotal'])}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    color: Colors.blue,
                    onPressed: () => showEditQtyDialog(index),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.withAlpha(30),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    color: Colors.red,
                    onPressed: () {
                      keranjang.removeAt(index);
                      setState(() {});
                      HapticFeedback.lightImpact();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withAlpha(35),
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.appBarTheme.iconTheme?.color ?? Warna.latar;

    const pageTitle = 'Catat Transaksi';

    return Scaffold(
      appBar: AppBar(
        title: const Text(pageTitle),
        centerTitle: true,
       iconTheme: IconThemeData(
          color: iconColor,
        ),
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
              HapticFeedback.lightImpact();
            },
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          indicatorColor: iconColor,
          labelColor: iconColor,
          unselectedLabelColor: iconColor.withAlpha(35),
          tabs: const [
            Tab(text: 'Makanan', icon: Icon(Icons.restaurant, size: 20)),
            Tab(text: 'Minuman', icon: Icon(Icons.local_drink, size: 20)),
          ],
        ),
      ),
      drawer: const SidebarAdmin(judul: pageTitle),
      body: Column(
        children: [
          // Menu List Section - Keep original flex ratio
          Expanded(
            flex: 2,
            child: TabBarView(
              controller: tabController,
              children: [
                buildMenuList('Makanan'),
                buildMenuList('Minuman'),
              ],
            ),
          ),
          // Bottom Cart Section - Fixed height with SafeArea
          SafeArea(
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(35),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0), // Reduced padding
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Important: minimize height
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metode Pembayaran - Compact version
                 DropdownButtonFormField<String>(
                      value: metodePembayaran,
                      decoration: InputDecoration(
                        labelText: 'Metode Pembayaran',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        labelStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(DefaultSetting.radius),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Tunai',
                          child: Row(
                            children: [
                              Icon(Icons.money, size: 16),
                              SizedBox(width: 8),
                              Text('Tunai'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'Non Tunai',
                          child: Row(
                            children: [
                              Icon(Icons.credit_card, size: 16),
                              SizedBox(width: 8),
                              Text('Non Tunai'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => metodePembayaran = value);
                          HapticFeedback.selectionClick();
                        }
                      },
                    ),


                    const SizedBox(height: 10), // Reduced spacing
                    
                    // Header Keranjang
                    Row(
                      children: [
                        Icon(Icons.shopping_cart, color: theme.primaryColor, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Keranjang',
                          style: theme.textTheme.titleSmall?.copyWith( // Smaller text
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (keranjang.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${keranjang.length}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8), // Reduced spacing
                    
                    // Daftar Keranjang - Increased height
                    SizedBox(
                      height: 140, // Increased from 100 to 140
                      child: keranjang.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 32, // Reduced icon size
                                    color: theme.disabledColor,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Keranjang masih kosong',
                                    style: TextStyle(
                                      color: theme.disabledColor,
                                      fontSize: 12, // Smaller text
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: keranjang.length,
                              itemBuilder: (context, index) => buildKeranjangItem(index),
                            ),
                    ),
                    const SizedBox(height: 8), // Reduced spacing
                    
                    // Total dan Tombol Simpan - More compact
                    Container(
                      padding: const EdgeInsets.all(8), // Reduced padding
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.primaryColor.withAlpha(25),
                            theme.primaryColor.withAlpha(25),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(DefaultSetting.radius),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Bayar:',
                                style: theme.textTheme.titleSmall?.copyWith( // Smaller text
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Rp ${NumberFormat.decimalPattern('id').format(totalBayar)}',
                                style: theme.textTheme.titleMedium?.copyWith( // Smaller text
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6), // Reduced spacing
                          SizedBox(
                            width: double.infinity,
                            height: 44, // Reduced from 60 to 44
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.save_outlined, size: 18),
                              label: const Text(
                                'Simpan Transaksi',
                                style: TextStyle(
                                  fontSize: 14, // Smaller text
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: keranjang.isEmpty
                                  ? null
                                  : () async {
                                      final konfirmasi = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Konfirmasi Simpan'),
                                          content: const Text('Apakah Anda yakin ingin menyimpan transaksi ini?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context, false),
                                              child: const Text('Batal'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context, true),
                                              child: const Text('Ya, Simpan'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (konfirmasi == true) {
                                        simpanTransaksi();
                                      }
                                    },

                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(DefaultSetting.radius),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuList(String? kategoriFilter) {
    return Padding(
      padding: const EdgeInsets.all(10.0), // Reduced padding from DefaultSetting.padding
      child: StreamBuilder<QuerySnapshot>(
        stream: layananFirestore.ambilSemuaMenu(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 22,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada menu tersedia',
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                ],
              ),
            );
          }

          final menuList = snapshot.data!.docs.where((doc) {
            if (kategoriFilter == null) return true;
            final data = doc.data() as Map<String, dynamic>;
            return (data['kategori'] ?? 'Makanan') == kategoriFilter;
          }).toList();

          if (menuList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    kategoriFilter == 'Minuman' 
                        ? Icons.local_drink_outlined 
                        : Icons.restaurant_outlined,
                    size: 64,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada ${kategoriFilter?.toLowerCase()} tersedia',
                    style: TextStyle(color: Theme.of(context).disabledColor),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: menuList.length,
            itemBuilder: (context, index) {
              final menu = menuList[index];
              final data = menu.data() as Map<String, dynamic>;
              return buildMenuCard(data);
            },
          );
        },
      ),
    );
  }
}