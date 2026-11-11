import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/transaction_model.dart';
import 'login_screen.dart';
import 'transaction/add_transaction_screen.dart';
import 'transaction/detail_transaction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah kamu yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService().logout();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyFinance',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),

      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .snapshots(),
        builder: (context, profileSnapshot) {
          final name =
              profileSnapshot.data?.data()?['name'] ??
              user.displayName ??
              'Pengguna';

          return StreamBuilder<List<TransactionModel>>(
            stream: firestoreService.getTransactions(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Gagal mengambil data transaksi.'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final transactions = snapshot.data ?? [];

              double income = 0;
              double expense = 0;

              for (var transaction in transactions) {
                if (transaction.type == 'Pemasukan') {
                  income += transaction.amount;
                } else {
                  expense += transaction.amount;
                }
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $name!',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Selamat datang di Personal Finance Tracker.',
                      style: TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 25),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7655C8), Color(0xFF9B7BE8)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Transaksi',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${transactions.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Transaksi tercatat',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            'Pemasukan',
                            income,
                            Colors.green,
                            Icons.arrow_downward,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _summaryCard(
                            'Pengeluaran',
                            expense,
                            Colors.red,
                            Icons.arrow_upward,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Riwayat Transaksi',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${transactions.length} data',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    if (transactions.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(30),
                          child: Text(
                            'Belum ada transaksi.\nYuk, catat transaksi pertamamu!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ...transactions.map((transaction) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.white,
                          child: ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailTransactionScreen(
                                    transaction: transaction,
                                  ),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundColor: transaction.type == 'Pemasukan'
                                  ? Colors.green.shade100
                                  : Colors.red.shade100,
                              child: Icon(
                                transaction.type == 'Pemasukan'
                                    ? Icons.arrow_downward
                                    : Icons.arrow_upward,
                                color: transaction.type == 'Pemasukan'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            title: Text(
                              transaction.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${transaction.type} • '
                              '${transaction.date.day}/'
                              '${transaction.date.month}/'
                              '${transaction.date.year}',
                            ),
                            trailing: Text(
                              'Rp ${transaction.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: transaction.type == 'Pemasukan'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7655C8),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _summaryCard(String title, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 5),
          Text(
            'Rp ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
