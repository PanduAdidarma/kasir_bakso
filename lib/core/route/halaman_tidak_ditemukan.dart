import 'package:flutter/material.dart';

class HalamanTidakDitemukan extends StatelessWidget {
  const HalamanTidakDitemukan({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('404 - Halaman Tidak Ditemukan'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            const Text(
              'Oops!\nHalaman yang kamu cari tidak ada.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
