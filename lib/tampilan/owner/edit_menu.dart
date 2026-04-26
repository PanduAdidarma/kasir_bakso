import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/konstanta/warna.dart';
import '../../core/layanan/theme_provider.dart';
import '../../core/layanan/layanan_firestore.dart';

class EditMenu extends StatefulWidget {
  final Map<String, dynamic> menuData;

  const EditMenu({
    super.key,
    required this.menuData,
  });

  @override
  State<EditMenu> createState() => _EditMenuState();
}

class _EditMenuState extends State<EditMenu> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController namaController;
  late TextEditingController hargaController;
  final LayananFirestore layananFirestore = LayananFirestore();

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.menuData['nama'] ?? '');
    hargaController = TextEditingController(
      text: NumberFormat.decimalPattern('id').format(widget.menuData['harga'] ?? 0),
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    hargaController.dispose();
    super.dispose();
  }

  Future<void> simpanPerubahan() async {
    if (!_formKey.currentState!.validate()) return;

    final namaBaru = namaController.text.trim();
    final hargaBaruString = hargaController.text.replaceAll('.', '');
    final hargaBaru = num.tryParse(hargaBaruString) ?? 0;

    await layananFirestore.updateMenu(widget.menuData['menuId'], {
      'nama': namaBaru,
      'harga': hargaBaru,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perubahan berhasil disimpan')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = theme.appBarTheme.iconTheme?.color ?? Warna.latar;

    const pageTitle = 'Edit Menu';

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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Menu',
                  border: OutlineInputBorder(),
                ),
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
                  labelText: 'Harga Menu',
                  border: OutlineInputBorder(),
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
                  if (parsed <= 0) {
                    return 'Harga harus lebih besar dari 0';
                  }
                  if (parsed > 1000000) {
                    return 'Harga maksimal Rp 1.000.000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Perubahan'),
                  onPressed: simpanPerubahan,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

    if (value > maxValue) value = maxValue;

    final newText = formatter.format(value);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
