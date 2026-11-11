
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mengambil collection transaksi milik pengguna aktif
  CollectionReference<Map<String, dynamic>>
      get _transactions {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transactions');
  }

  // Menambahkan transaksi
  Future<void> addTransaction(
    TransactionModel transaction,
  ) async {
    await _transactions.add(transaction.toMap());
  }

  // Menampilkan transaksi secara real-time
  Stream<List<TransactionModel>> getTransactions() {
    return _transactions
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // Mengubah transaksi
  Future<void> updateTransaction(
    TransactionModel transaction,
  ) async {
    await _transactions
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  // Menghapus transaksi
  Future<void> deleteTransaction(String id) async {
    await _transactions.doc(id).delete();
  }
}
