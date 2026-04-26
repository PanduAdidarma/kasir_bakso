import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Ambil user saat ini
  User? get currentUser => firebaseAuth.currentUser;

  /// Stream perubahan status auth
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  /// Login dengan email & password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Buat akun baru: FirebaseAuth + Firestore sinkron
  Future<UserCredential> createAccount({
    required String email,
    required String password,
    required String nama,
  }) async {
    final credential = await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Gagal membuat akun.');
    }

    // Update displayName di FirebaseAuth
    await user.updateDisplayName(nama);
    await user.reload();

    // Simpan ke Firestore
    await firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'nama': nama,
      'role': 'admin',
      'status': false,
      'dibuatPada': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  /// Logout
 Future<void> signOut() async {
  await firebaseAuth.signOut();

  // Bersihkan semua sesi lokal
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}


  /// Kirim email reset password
  Future<void> resetPassword({required String email}) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Update displayName user
  Future<void> updateUsername({required String namaBaru}) async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(namaBaru);
      await user.reload();

      // Opsional: sinkron Firestore juga (kalau mau)
      await firestore.collection('users').doc(user.uid).update({
        'nama': namaBaru,
      });
    }
  }

  /// Hapus akun user
  /// Hapus akun dari Firestore dan Firebase Auth
Future<void> deleteAccount({required String password}) async {
  final user = firebaseAuth.currentUser;

  if (user == null) {
    throw Exception('Tidak ada user yang login.');
  }

  // Lakukan re-auth untuk keamanan (diperlukan untuk hapus akun)
  final credential = EmailAuthProvider.credential(
    email: user.email!,
    password: password,
  );

  try {
    await user.reauthenticateWithCredential(credential);
    
    // Hapus data dari Firestore
    await firestore.collection('users').doc(user.uid).delete();

    // Hapus akun dari Firebase Auth
    await user.delete();
  } catch (e) {
    throw Exception('Gagal menghapus akun: $e');
  }
}


  /// Reset password dengan reauth dulu
  Future<void> resetPasswordFromCurrentPassword({
    required String email,
    required String sandiLama,
    required String sandiBaru,
  }) async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: sandiLama,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(sandiBaru);
    }
  }
}
