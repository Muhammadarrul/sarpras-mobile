import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/barang_model.dart';
import '../service/pengembalian_service.dart';

class PengembalianPage extends StatefulWidget {
  final int peminjamanId;
  final String token;
  final Barang? barang;

  const PengembalianPage({
    super.key,
    required this.peminjamanId,
    required this.token,
    this.barang,
  });

  @override
  State<PengembalianPage> createState() => _PengembalianPageState();
}

class _PengembalianPageState extends State<PengembalianPage> {
  final _keteranganController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  Uint8List? _webImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImage = bytes;
          _selectedImage = null;
        });
      } else {
        setState(() {
          _selectedImage = File(picked.path);
          _webImage = null;
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        (_selectedImage == null && _webImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi keterangan dan pilih gambar.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await PengembalianService().kirimPengembalian(
        id: widget.peminjamanId,
        keterangan: _keteranganController.text,
        imageFile: _selectedImage,
        webImageBytes: _webImage,
        token: widget.token,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Pengembalian berhasil dikirim.'
              : 'Gagal mengirim pengembalian.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Form Pengembalian',
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
                  'Mengembalikan: ${widget.barang!.nama}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 40),
              ],
              TextFormField(
                controller: _keteranganController,
                validator: (val) =>
                    val == null || val.isEmpty ? "Wajib diisi" : null,
                decoration: InputDecoration(
                  labelText: 'Keterangan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: _pickImageFromGallery,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.image, size: 20),
                      const SizedBox(width: 16),
                      Text(
                        (_selectedImage == null && _webImage == null)
                            ? 'Pilih Gambar dari Galeri'
                            : 'Gambar Terpilih',
                      ),
                      const Spacer(),
                      Text(
                        'Pilih',
                        style: TextStyle(color: Colors.blue[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_selectedImage != null || _webImage != null)
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = constraints.maxWidth < 300
                          ? constraints.maxWidth
                          : 200.0;
                      return Container(
                        width: size,
                        height: size,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                          image: DecorationImage(
                            image: kIsWeb
                                ? MemoryImage(_webImage!)
                                : FileImage(_selectedImage!)
                                    as ImageProvider<Object>,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
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
                          'Kirim Pengembalian',
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