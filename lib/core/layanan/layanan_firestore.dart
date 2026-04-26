import 'package:cloud_firestore/cloud_firestore.dart';

class LayananFirestore {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // ============= USERS =============
  Future<void> tambahUser({
    required String nama,
    required String role,
    required bool status,
  }) async {
    final docRef = firestore.collection('users').doc();
    final userId = docRef.id;

    await docRef.set({
      'userId': userId,
      'nama': nama,
      'role': role,
      'status': status,
      'dibuatPada': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> ambilUserBelumDisetujui() {
    return firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .where('status', isEqualTo: false)
        .snapshots();
  }

  Future<DocumentSnapshot> ambilUser(String uid) {
    return firestore.collection('users').doc(uid).get();
  }

  Future<void> perbaruiRoleUser(String uid, String roleBaru) {
    return firestore.collection('users').doc(uid).update({'role': roleBaru});
  }

  Future<void> blokirUser(String uid, bool blokir) {
    return firestore.collection('users').doc(uid).update({'status': blokir});
  }

  Stream<QuerySnapshot> ambilSemuaAdminDanOwner() {
  return firestore
      .collection('users')
      .where('role', whereIn: ['admin', 'owner'])
      .orderBy('dibuatPada', descending: true)
      .snapshots();
}

  // ============= MENUS =============
  Future<void> tambahMenu({
    required String nama,
    required num harga,
    required String gambarUrl,
    required String kategori,
    required String dibuatOleh,
  }) async {
    final docRef = firestore.collection('menus').doc();
    final menuId = docRef.id;

    await docRef.set({
      'menuId': menuId,
      'nama': nama,
      'harga': harga,
      'gambarUrl': gambarUrl,
      'kategori': kategori,
      'dibuatPada': FieldValue.serverTimestamp(),
      'dibuatOleh': dibuatOleh,
    });
  }

  Future<void> updateMenu(String menuId, Map<String, dynamic> data) {
    return firestore.collection('menus').doc(menuId).update(data);
  }

  Future<void> hapusMenu(String menuId) {
    return firestore.collection('menus').doc(menuId).delete();
  }

  Stream<QuerySnapshot> ambilSemuaMenu() {
    return firestore
        .collection('menus')
        .orderBy('dibuatPada', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> ambilMenuByKategori(String kategori) {
  return FirebaseFirestore.instance
      .collection('menus')
      .where('kategori', isEqualTo: kategori)
      .snapshots();
}


  // ============= TRANSACTIONS =============
 
Future<void> catatTransaksi({
  required String adminId,
  required String adminNama, // ⬅️ tambahan
  required List<Map<String, dynamic>> items,
  required num totalBayar,
  required String metodePembayaran,
}) async {
  final docRef = firestore.collection('transactions').doc();
  final transactionId = docRef.id;

  await docRef.set({
    'transactionId': transactionId,
    'adminId': adminId,
    'adminNama': adminNama,
    'items': items,
    'totalBayar': totalBayar,
    'metodePembayaran': metodePembayaran,
    'dibuatPada': DateTime.now(),
    // 'dibuatPada': FieldValue.serverTimestamp(),
  });
}


 Stream<QuerySnapshot> ambilTransaksiByAdmin(String adminId) {
  return firestore
      .collection('transactions')
      .where('adminId', isEqualTo: adminId)
      .orderBy('dibuatPada', descending: true)
      .snapshots();
}

  Stream<QuerySnapshot> ambilSemuaTransaksi() {
    return firestore
        .collection('transactions')
        .orderBy('dibuatPada', descending: true)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> ambilTransaksiById(String id) {
  return firestore
      .collection('transactions')
      .doc(id)
      .get();
}
  Future<void> hapusTransaksi(String transactionId) async {
    try {
      await firestore.collection('transactions').doc(transactionId).delete();
    } catch (e) {
      throw Exception('Gagal menghapus transaksi: $e');
    }
  }

}


