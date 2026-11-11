import 'package:flutter/material.dart';
import '../../models/transaction_model.dart';
import '../../services/firestore_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  String _selectedType = 'Pengeluaran';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final transaction = TransactionModel(
        id: '',
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        type: _selectedType,
        note: _noteController.text.trim(),
        date: _selectedDate,
      );

      await _firestoreService.addTransaction(transaction);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil ditambahkan!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan transaksi: $e')));
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Jenis Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                    value: 'Pemasukan',
                    child: Text('Pemasukan'),
                  ),
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

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Uang saku',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama transaksi wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'Jumlah (Rp)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 50000',
                  border: OutlineInputBorder(),
                  prefixText: 'Rp ',
                ),
                validator: (value) {
                  final amount = double.tryParse(value?.trim() ?? '');

                  if (amount == null || amount <= 0) {
                    return 'Masukkan jumlah yang valid';
                  }
                  return null;
                },
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
                'Catatan (Opsional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan Transaksi',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
