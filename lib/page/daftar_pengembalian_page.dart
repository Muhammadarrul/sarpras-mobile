import 'package:flutter/material.dart';
import '../model/daftar_pengembalian_model.dart';
import '../service/daftar_pengembalian_service.dart';

class DaftarPengembalianPage extends StatefulWidget {
  final String token;
  final int userId;

  const DaftarPengembalianPage({
    Key? key,
    required this.token,
    required this.userId,
  }) : super(key: key);

  @override
  State<DaftarPengembalianPage> createState() => _DaftarPengembalianPageState();
}

class _DaftarPengembalianPageState extends State<DaftarPengembalianPage> {
  List<DaftarPengembalian> _pengembalianList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final data = await DaftarPengembalianService().fetchData(widget.token);
      final filtered = data.where((e) => e.userId == widget.userId).toList();

      setState(() {
        _pengembalianList = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'approved' || s == 'setuju') return Colors.green;
    if (s == 'pending') return Colors.orange;
    if (s == 'rejected' || s == 'ditolak') return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'List Pengembalian',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _pengembalianList.isEmpty
                  ? Center(
                      child: Text(
                        "Belum ada data",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _pengembalianList.length,
                      itemBuilder: (context, index) {
                        final p = _pengembalianList[index];
                        return _buildPengembalianCard(p);
                      },
                    ),
            ),
    );
  }

  Widget _buildPengembalianCard(DaftarPengembalian p) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    p.barang.namaBarang,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(p.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    p.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (p.image != null) ...[
              const SizedBox(height: 12),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    'http://127.0.0.1:8000/storage/${p.image}',
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.calendar_today,
              'Tanggal: ${p.tanggalPengembalian.toLocal().toString().split(" ")[0]}',
            ),
            _buildDetailRow(
              Icons.description,
              'Keterangan: ${p.keterangan?.isNotEmpty == true ? p.keterangan! : "-"}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.black87),
          ),
        ],
      ),
    );
  }
}