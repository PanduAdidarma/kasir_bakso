import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/konstanta/default.dart';
import '../../core/route/daftar_rute.dart';
import '../../core/layanan/theme_provider.dart';
import '../../core/layanan/auth_service.dart';

class HalamanDaftar extends StatefulWidget {
  const HalamanDaftar({super.key});

  @override
  State<HalamanDaftar> createState() => HalamanDaftarState();
}

class HalamanDaftarState extends State<HalamanDaftar> {
  final formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> daftar() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final auth = AuthService();

      final credential = await auth.createAccount(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        nama: namaController.text.trim(),
      );

      final user = credential.user;

      if (user != null) {
        await auth.updateUsername(namaBaru: namaController.text.trim());

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green.shade600,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pendaftaran berhasil. Menunggu persetujuan owner!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );

        Navigator.pushReplacementNamed(context, Rute.login);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal daftar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark 
              ? [
                  // Dark mode: gradient dengan warna aksen/cream
                  theme.colorScheme.secondary.withAlpha(40), // Aksen dengan transparansi
                  theme.colorScheme.surface.withAlpha(200),
                  theme.scaffoldBackgroundColor,
                  const Color(0xFFF5E6D3).withAlpha(25), // Cream color untuk aksen
                ]
              : [
                  theme.primaryColor.withAlpha(30),
                  theme.scaffoldBackgroundColor,
                  Colors.white.withAlpha(150),
                ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(DefaultSetting.padding),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  elevation: isDark ? 12 : 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: isDark 
                        ? LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              theme.cardTheme.color!,
                              theme.cardTheme.color!.withAlpha(240),
                            ],
                          )
                        : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header Section dengan desain yang lebih menarik
                            Container(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Daftar Akun',
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
                                        ),
                                      ),
                                      Container(
                                        height: 3,
                                        width: 40,
                                        margin: const EdgeInsets.only(top: 4),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              theme.primaryColor,
                                              theme.primaryColor.withAlpha(100),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: isDark 
                                        ? theme.primaryColor.withAlpha(30)
                                        : theme.primaryColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        isDark ? Icons.light_mode : Icons.dark_mode,
                                        color: theme.primaryColor,
                                      ),
                                      onPressed: () {
                                        Provider.of<ThemeProvider>(context, listen: false)
                                            .toggleTheme();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),
                            
                            // Logo Section dengan efek shadow
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: isDark
                                  ? LinearGradient(
                                      colors: [
                                        theme.colorScheme.secondary.withAlpha(40),
                                        const Color(0xFFF5E6D3).withAlpha(30),
                                      ],
                                    )
                                  : LinearGradient(
                                      colors: [
                                        theme.primaryColor.withAlpha(15),
                                        theme.primaryColor.withAlpha(5),
                                      ],
                                    ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withAlpha(20),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/onepiece.jpg', 
                                height: 75,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Name Field dengan design yang lebih baik
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withAlpha(15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: namaController,
                                decoration: InputDecoration(
                                  labelText: 'Nama Lengkap',
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.person_outline,
                                      color: theme.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.isEmpty 
                                      ? 'Nama wajib diisi' 
                                      : null,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Email Field dengan design yang lebih baik
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withAlpha(15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.email_outlined,
                                      color: theme.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email wajib diisi';
                                  }
                                  if (!value.contains('@')) {
                                    return 'Format email salah';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Password Field dengan design yang lebih baik
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withAlpha(15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Kata Sandi',
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.lock_outline,
                                      color: theme.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword 
                                        ? Icons.visibility_off 
                                        : Icons.visibility,
                                      color: theme.primaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Kata sandi wajib diisi';
                                  }
                                  if (value.length < 6) {
                                    return 'Minimal 6 karakter';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Confirm Password Field dengan design yang lebih baik
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withAlpha(15),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                decoration: InputDecoration(
                                  labelText: 'Konfirmasi Kata Sandi',
                                  prefixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.lock_outline,
                                      color: theme.primaryColor,
                                      size: 20,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirmPassword 
                                        ? Icons.visibility_off 
                                        : Icons.visibility,
                                      color: theme.primaryColor,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword = !_obscureConfirmPassword;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Konfirmasi kata sandi wajib diisi';
                                  }
                                  if (value != passwordController.text) {
                                    return 'Kata sandi tidak cocok';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Register Button dengan gradient dan shadow
                            Container(
                              width: double.infinity,
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.primaryColor,
                                    theme.primaryColor.withAlpha(200),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primaryColor.withAlpha(60),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: loading ? null : daftar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: loading
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                theme.colorScheme.onPrimary,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Memproses...',
                                            style: TextStyle(
                                              color: theme.colorScheme.onPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        'DAFTAR',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Login Link dengan design yang lebih menarik
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20, 
                                    vertical: 12
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: theme.textTheme.bodyMedium,
                                    children: [
                                      const TextSpan(text: "Sudah punya akun? "),
                                      TextSpan(
                                        text: "Masuk",
                                        style: TextStyle(
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          decorationColor: theme.primaryColor.withAlpha(100),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}