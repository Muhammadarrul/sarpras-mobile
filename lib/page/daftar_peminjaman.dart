import 'package:flutter/material.dart';
import 'package:pbo_mobile/model/daftar_peminjaman.dart';
import 'package:pbo_mobile/service/daftar_peminjaman.dart';
import 'package:pbo_mobile/service/barang_service.dart';
import 'pengembalian_page.dart';

class DaftarPeminjamanPage extends StatefulWidget {
  final String token;
  final int userId;

  const DaftarPeminjamanPage({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<DaftarPeminjamanPage> createState() => _DaftarPeminjamanPageState();
}

class _DaftarPeminjamanPageState extends State<DaftarPeminjamanPage> {
  List<Peminjaman> _peminjamanList = [];
  Map<int, String> _barangMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final peminjamanService = PeminjamanService();
      final barangService = BarangService();

      final peminjamans = await peminjamanService.fetchPeminjaman(widget.token);
      final barangs = await barangService.fetchBarangs(widget.token);

      final filtered = peminjamans.where((p) => p.userId == widget.userId).toList();
      final barangMap = {for (var b in barangs) b.id: b.nama};

      setState(() {
        _peminjamanList = filtered;
        _barangMap = barangMap;
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

  bool _isApproved(String status) {
    final s = status.toLowerCase();
    return ['setuju', 'approved', 'approve', 'disetujui'].contains(s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'List Peminjaman',
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
              child: _peminjamanList.isEmpty
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
                      itemCount: _peminjamanList.length,
                      itemBuilder: (context, index) {
                        final p = _peminjamanList[index];
                        final nama = _barangMap[p.barangId] ?? 'Tidak diketahui';
                        return _buildPeminjamanCard(p, nama);
                      },
                    ),
            ),
    );
  }

  Widget _buildPeminjamanCard(Peminjaman p, String namaBarang) {
    final status = p.status;
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
                    namaBarang,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildDetailRow(Icons.format_list_numbered, 'Jumlah: ${p.jumlah}'),
            _buildDetailRow(Icons.calendar_today, 'Pinjam: ${p.tanggalPinjam}'),
            _buildDetailRow(Icons.calendar_today_outlined, 'Kembali: ${p.tanggalKembali}'),
            if (_isApproved(status))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PengembalianPage(
                            peminjamanId: p.id,
                            token: widget.token,
                          ),
                        ),
                      );
                      if (result == true) _loadData();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Kembalikan Barang',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'setuju' || s == 'approved') return Colors.green;
    if (s == 'pending') return Colors.orange;
    if (s == 'ditolak') return Colors.red;
    return Colors.grey;
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