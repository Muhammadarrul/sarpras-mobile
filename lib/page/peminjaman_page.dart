import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/peminjaman_service.dart';
import '../model/barang_model.dart';

class PeminjamanPage extends StatefulWidget {
  final int barangId;
  final String token;
  final Barang? barang;

  const PeminjamanPage({
    super.key,
    required this.barangId,
    required this.token,
    this.barang,
  });

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  final TextEditingController _jumlahController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final jumlah = int.tryParse(_jumlahController.text);
    if (jumlah == null || jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah tidak valid')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await PeminjamanService().kirimPeminjaman(
        barangId: widget.barangId,
        jumlah: jumlah,
        jatuhTempo: DateFormat('yyyy-MM-dd').format(_selectedDate),
        token: widget.token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Peminjaman berhasil' : 'Gagal meminjam')),
      );
      if (success) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Form Peminjaman',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.barang != null) ...[
                Text(
                  'Meminjam: ${widget.barang!.nama}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stok tersedia: ${widget.barang!.stock}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Divider(height: 40),
              ],
              TextFormField(
                controller: _jumlahController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Jumlah',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Harap masukkan jumlah';
                  final jumlah = int.tryParse(value);
                  if (jumlah == null || jumlah <= 0) return 'Jumlah harus lebih dari 0';
                  if (widget.barang != null && jumlah > widget.barang!.stock) {
                    return 'Jumlah melebihi stok tersedia';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 16),
                      Text(
                        DateFormat('dd MMMM yyyy').format(_selectedDate),
                      ),
                      const Spacer(),
                      Text(
                        'Ubah',
                        style: TextStyle(color: Colors.blue[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Kirim Permohonan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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