
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const TransactionCard({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'Pemasukan';

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? Colors.green.shade100
              : Colors.red.shade100,
          child: Icon(
            isIncome
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${transaction.date.day}/'
          '${transaction.date.month}/'
          '${transaction.date.year}',
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'} Rp ${transaction.amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
