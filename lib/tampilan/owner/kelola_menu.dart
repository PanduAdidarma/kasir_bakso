import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kasir_bakso/tampilan/component/sidebar_owner.dart';
import 'package:provider/provider.dart';
import '../../core/konstanta/warna.dart';
import '../../core/layanan/theme_provider.dart';
import '../../core/layanan/layanan_firestore.dart';
import '../../core/route/daftar_rute.dart';
import 'package:intl/intl.dart';

class KelolaMenu extends StatefulWidget {
  const KelolaMenu({super.key});

  @override
  State<KelolaMenu> createState() => _KelolaMenuState();
}

class _KelolaMenuState extends State<KelolaMenu> with TickerProviderStateMixin {
  final layananFirestore = LayananFirestore();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String selectedKategori = 'Makanan';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> hapusMenu(String menuId) async {
    // Show confirmation dialog dengan design modern
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Theme.of(context).colorScheme.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Konfirmasi Hapus'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin menghapus menu ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await layananFirestore.hapusMenu(menuId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              const SizedBox(width: 8),
              const Text('Menu berhasil dihapus'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
     final iconColor = theme.appBarTheme.iconTheme?.color ?? Warna.latar;

    const pageTitle = 'kelola Menu';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 4,
        shadowColor: colorScheme.primary.withAlpha(100),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        iconTheme: IconThemeData(color: iconColor),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: IconButton(
               icon: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: iconColor,
                ),
              onPressed: () {
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
              },
            ),
          ),
        ],
      ),
      drawer: const SidebarOwner(judul: pageTitle),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header dengan gradient background
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withAlpha(15),
                    colorScheme.secondary.withAlpha(8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Kategori',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface.withAlpha(180),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildModernChoiceChip(
                          'Makanan',
                          Icons.restaurant_rounded,
                          selectedKategori == 'Makanan',
                          () => setState(() => selectedKategori = 'Makanan'),
                          colorScheme,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildModernChoiceChip(
                          'Minuman',
                          Icons.local_cafe_rounded,
                          selectedKategori == 'Minuman',
                          () => setState(() => selectedKategori = 'Minuman'),
                          colorScheme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: layananFirestore.ambilMenuByKategori(selectedKategori),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: colorScheme.primary,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat data...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withAlpha(150),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Icon(
                              selectedKategori == 'Makanan'
                                  ? Icons.restaurant_rounded
                                  : Icons.local_cafe_rounded,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada menu $selectedKategori',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withAlpha(180),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tambahkan menu pertama Anda',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withAlpha(120),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final menuList = snapshot.data!.docs;

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: menuList.length,
                    itemBuilder: (context, index) {
                      final menu = menuList[index];
                      final menuData = menu.data() as Map<String, dynamic>;

                      final kategori = (menuData['kategori'] ?? '').toString().toLowerCase();
                      final isMinuman = kategori == 'minuman';

                      return _buildModernMenuCard(
                        menuData,
                        isMinuman,
                        colorScheme,
                        theme,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 0,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Tambah Menu',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          onPressed: () {
            Navigator.pushNamed(context, Rute.tambahMenu);
          },
        ),
      ),
    );
  }

  Widget _buildModernChoiceChip(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withAlpha(50),
            width: isSelected ? 0 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurface.withAlpha(150),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface.withAlpha(180),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernMenuCard(
    Map<String, dynamic> menuData,
    bool isMinuman,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outline.withAlpha(30),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon dengan background modern
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMinuman
                    ? colorScheme.secondary.withAlpha(20)
                    : colorScheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isMinuman ? Icons.local_cafe_rounded : Icons.restaurant_rounded,
                color: isMinuman ? colorScheme.secondary : colorScheme.primary,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menuData['nama'] ?? 'Tanpa Nama',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                    
                    child: Text(
                      'Rp ${NumberFormat.decimalPattern('id').format(menuData['harga'])}',
                    ),
                  ),
                ],
              ),
            ),
            
            // Action buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    tooltip: 'Edit Menu',
                    icon: Icon(
                      Icons.edit_rounded,
                      color: colorScheme.primary,
                      size: 18,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        Rute.editMenu,
                        arguments: {
                          'menuId': menuData['menuId'],
                          'nama': menuData['nama'],
                          'harga': menuData['harga'],
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.error.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    tooltip: 'Hapus Menu',
                    icon: Icon(
                      Icons.delete_rounded,
                      color: colorScheme.error,
                      size: 18,
                    ),
                    onPressed: () {
                      hapusMenu(menuData['menuId']);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}