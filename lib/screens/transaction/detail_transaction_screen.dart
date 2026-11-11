import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';

class DetailTransactionScreen extends StatefulWidget {
  final TransactionModel transaction;

  const DetailTransactionScreen({super.key, required this.transaction});

  @override
  State<DetailTransactionScreen> createState() =>
      _DetailTransactionScreenState();
}

class _DetailTransactionScreenState extends State<DetailTransactionScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late String _selectedType;
  late DateTime _selectedDate;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.transaction.title);

    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );

    _noteController = TextEditingController(text: widget.transaction.note);

    _selectedType = widget.transaction.type;
    _selectedDate = widget.transaction.date;
  }

  Future<void> _updateTransaction() async {
    final amount = double.tryParse(_amountController.text.trim());

    if (_titleController.text.trim().isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Periksa kembali nama dan jumlah transaksi.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedTransaction = TransactionModel(
        id: widget.transaction.id,
        title: _titleController.text.trim(),
        amount: amount,
        type: _selectedType,
        note: _noteController.text.trim(),
        date: _selectedDate,
      );

      await _firestoreService.updateTransaction(updatedTransaction);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil diperbarui!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui transaksi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: const Text('Apakah kamu yakin ingin menghapus transaksi ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestoreService.deleteTransaction(widget.transaction.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dihapus!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus transaksi: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                transaction.type == 'Pemasukan'
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                size: 60,
                color: transaction.type == 'Pemasukan'
                    ? Colors.green
                    : Colors.red,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Jenis Transaksi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'Pemasukan', child: Text('Pemasukan')),
                DropdownMenuItem(
                  value: 'Pengeluaran',
                  child: Text('Pengeluaran'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Nama Transaksi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 20),

            const Text(
              'Jumlah (Rp)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixText: 'Rp ',
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Tanggal Transaksi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: _selectDate,
              icon: const Icon(Icons.calendar_month),
              label: Text(
                '${_selectedDate.day}/'
                '${_selectedDate.month}/'
                '${_selectedDate.year}',
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Catatan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Tambahkan catatan...',
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Perubahan'),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _deleteTransaction,
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Hapus Transaksi',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
