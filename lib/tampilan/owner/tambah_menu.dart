import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/konstanta/warna.dart';
import '../../core/konstanta/default.dart';
import '../../core/layanan/layanan_firestore.dart';
import '../../core/layanan/theme_provider.dart';
import 'package:intl/intl.dart'; // Format Rupiah

class TambahMenu extends StatefulWidget {
  const TambahMenu({super.key});

  @override
  State<TambahMenu> createState() => TambahMenuState();
}

class TambahMenuState extends State<TambahMenu> {
  final _formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final hargaController = TextEditingController();

  String? selectedKategori;

  final layananFirestore = LayananFirestore();
  bool isLoading = false;

  @override
  void dispose() {
    namaController.dispose();
    hargaController.dispose();
    super.dispose();
  }

  Future<void> simpanMenu() async {
    if (!_formKey.currentState!.validate()) return;

    final hargaString = hargaController.text.replaceAll('.', '');
    final harga = num.tryParse(hargaString) ?? 0;

    final nama = namaController.text.trim();
    final kategori = selectedKategori ?? '';

    setState(() => isLoading = true);

    await layananFirestore.tambahMenu(
      nama: nama,
      harga: harga,
      gambarUrl: '',
      kategori: kategori,
      dibuatOleh: 'admin',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Menu berhasil ditambahkan!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.appBarTheme.iconTheme?.color ?? Warna.latar;

    const pageTitle = 'Tambah Menu';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
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
      body: Padding(
        padding: const EdgeInsets.all(DefaultSetting.padding),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Menu'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama menu wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  ThousandsSeparatorInputFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  prefixText: 'Rp ',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga wajib diisi';
                  }
                  final clean = value.replaceAll('.', '');
                  final parsed = num.tryParse(clean);
                  if (parsed == null) {
                    return 'Harga harus berupa angka';
                  }
                  if (parsed > 1000000) {
                    return 'Harga maksimal Rp 1.000.000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedKategori,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: const [
                  DropdownMenuItem(value: 'Makanan', child: Text('Makanan')),
                  DropdownMenuItem(value: 'Minuman', child: Text('Minuman')),
                ],
                onChanged: (value) {
                  setState(() => selectedKategori = value);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori wajib dipilih';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Warna.putih,
                          ),
                        )
                      : const Text('Simpan'),
                  onPressed: isLoading ? null : simpanMenu,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// SEPARATOR FORMAT CUSTOM
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat formatter = NumberFormat.decimalPattern('id');
  final int maxValue;

  ThousandsSeparatorInputFormatter({this.maxValue = 1000000});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll('.', '');
    if (text.isEmpty) return newValue.copyWith(text: '');
    num value = num.tryParse(text) ?? 0;

    // Batasin ke maxValue
    if (value > maxValue) {
      value = maxValue;
    }

    final newText = formatter.format(value);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

