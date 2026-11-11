
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String note;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.note,
    required this.date,
  });

  // Mengubah data Firestore menjadi object
  factory TransactionModel.fromMap(
    String id,
    Map<String, dynamic> data,
  ) {
    final rawDate = data['date'];

    DateTime transactionDate;

    if (rawDate is Timestamp) {
      transactionDate = rawDate.toDate();
    } else {
      transactionDate = DateTime.parse(rawDate.toString());
    }

    return TransactionModel(
      id: id,
      title: data['title'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      type: data['type'] ?? 'Pengeluaran',
      note: data['note'] ?? '',
      date: transactionDate,
    );
  }

  // Mengubah object menjadi Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'note': note,
      'date': date,
    };
  }
}
