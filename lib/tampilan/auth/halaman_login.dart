import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import '../../core/konstanta/teks.dart';
import '../../core/konstanta/default.dart';
import '../../core/route/daftar_rute.dart';
import '../../core/layanan/theme_provider.dart';
import '../../core/layanan/auth_service.dart';

class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key});

  @override
  State<HalamanLogin> createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool ingatSaya = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');

    if (savedEmail != null) {
      emailController.text = savedEmail;
    }
    if (savedPassword != null) {
      passwordController.text = savedPassword;
    }
    if (savedEmail != null || savedPassword != null) {
      ingatSaya = true;
      setState(() {});
    }
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final auth = AuthService();
      await auth.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = auth.currentUser;
      if (user == null) throw Exception('User tidak ditemukan.');
      final uid = user.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!snapshot.exists) {
        throw ('Akun belum terdaftar.');
      }

      final data = snapshot.data()!;
      final role = data['role'];
      final isActive = data['status'] ?? false;
    
      if (!isActive) {
        throw ('Akun ini belum disetujui oleh owner untuk LOGIN.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          'lastLoginMillis', DateTime.now().millisecondsSinceEpoch);

      if (ingatSaya == true) {
        await prefs.setString('saved_email', emailController.text.trim());
        await prefs.setString('saved_password', passwordController.text.trim());
        TextInput.finishAutofillContext();
      } else {
        await prefs.remove('saved_email');
        await prefs.remove('saved_password');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  Teks.berhasilLogin,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );

      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, Rute.catatTransaksi);
      } else if (role == 'owner') {
        Navigator.pushReplacementNamed(context, Rute.dashboardOwner);
      } else {
        throw Exception('Role tidak dikenal.');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal: email belum terdaftar / dihapus owner'),
          backgroundColor: const Color.fromARGB(255, 237, 107, 104),
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
                      child: AutofillGroup(
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
                                          Teks.loginJudul,
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
                              const SizedBox(height: 32),
                              
                              // Logo Section dengan efek shadow
                              Container(
                                padding: const EdgeInsets.all(20),
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
                                  height: 85,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 36),

                              // Email Field dengan design yang lebih baik
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.primaryColor.withAlpha(15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [
                                    AutofillHints.email,
                                    AutofillHints.username,
                                  ],
                                  decoration: InputDecoration(
                                    labelText: Teks.emailLabel,
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
                                      return Teks.errorFieldKosong;
                                    }
                                    if (!value.contains('@')) {
                                      return Teks.errorEmail;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Password Field dengan design yang lebih baik
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.primaryColor.withAlpha(15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: passwordController,
                                  obscureText: _obscurePassword,
                                  autofillHints: const [AutofillHints.password],
                                  decoration: InputDecoration(
                                    labelText: Teks.passwordLabel,
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
                                      return Teks.errorFieldKosong;
                                    }
                                    if (value.length < 6) {
                                      return Teks.errorPassword;
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Remember Me Checkbox dengan design yang lebih baik
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Row(
                                  children: [
                                    Transform.scale(
                                      scale: 1.1,
                                      child: Checkbox(
                                        value: ingatSaya,
                                        onChanged: (value) {
                                          setState(() {
                                            ingatSaya = value!;
                                          });
                                        },
                                        activeColor: theme.primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Ingat Saya",
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Login Button dengan gradient dan shadow
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
                                  onPressed: loading ? null : login,
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
                                          Teks.tombolLogin,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Register Link dengan design yang lebih menarik
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, Rute.daftar);
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
                                        const TextSpan(text: "Belum punya akun? "),
                                        TextSpan(
                                          text: "Daftar",
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
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}