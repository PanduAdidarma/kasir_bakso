import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/layanan/theme_provider.dart';

import '../../core/konstanta/warna.dart';
import '../../core/layanan/layanan_firestore.dart';
import '../component/sidebar_admin.dart';
import 'package:intl/intl.dart';

class LihatMenuAdmin extends StatefulWidget {
  const LihatMenuAdmin({super.key});

  @override
  State<LihatMenuAdmin> createState() => _LihatMenuAdminState();
}

class _LihatMenuAdminState extends State<LihatMenuAdmin> with TickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
     final iconColor = theme.appBarTheme.iconTheme?.color ?? Warna.latar;

    const pageTitle = 'Lihat Menu';

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
      drawer: const SidebarAdmin(judul: pageTitle),
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
                            'Menu akan ditampilkan di sini',
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
          ],
        ),
      ),
    );
  }
}