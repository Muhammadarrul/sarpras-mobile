import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbo_mobile/service/login_service.dart';
import 'package:pbo_mobile/service/barang_service.dart';
import 'package:pbo_mobile/model/barang_model.dart';
import 'package:pbo_mobile/page/login_page.dart';
import 'package:pbo_mobile/page/peminjaman_page.dart';
import 'package:pbo_mobile/page/daftar_peminjaman.dart';
import 'package:pbo_mobile/page/daftar_pengembalian_page.dart';

class HomePage extends StatefulWidget {
  final String token;
  final Map<String, dynamic> user;
  final String title;

  const HomePage({
    Key? key,
    required this.token,
    required this.user,
    required this.title,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  late final LoginService _loginService;
  late final BarangService _barangService;

  bool _isLoggingOut = false;
  bool _isLoadingBarang = true;
  List<Barang> _barangList = [];
  List<Barang> _filteredBarangList = [];
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loginService = LoginService();
    _barangService = BarangService();
    _verifyTokenAndUser();
    _fetchBarang();
    _searchController.addListener(_filterBarang);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _verifyTokenAndUser() async {
    if (widget.token.isEmpty || widget.user.isEmpty || widget.user['id'] == null) {
      _forceLogout('Token atau data user tidak valid');
    }
  }

  Future<void> _fetchBarang() async {
    try {
      final list = await _barangService.fetchBarangs(widget.token);
      setState(() {
        _barangList = list;
        _filteredBarangList = list;
        _isLoadingBarang = false;
      });
    } catch (e) {
      setState(() => _isLoadingBarang = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat barang: ${e.toString()}')),
      );
    }
  }

  void _filterBarang() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBarangList = _barangList.where((barang) {
        return barang.nama.toLowerCase().contains(query) ||
            barang.deskripsi.toLowerCase().contains(query);
      }).toList();
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      if (widget.token.isNotEmpty) {
        await _loginService.logout(widget.token);
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (r) => false,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  void _forceLogout(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (r) => false,
      );
    }
  }

  void _onItemTapped(int idx) => setState(() => _selectedIndex = idx);

  void _handlePinjam(Barang barang) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PeminjamanPage(
          barangId: barang.id,
          token: widget.token,
        ),
      ),
    ).then((_) => _fetchBarang());
  }

  Widget _buildHome() {
    if (_isLoadingBarang) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari barang...',
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black54),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              filled: true,
              fillColor: Colors.grey[100],
            ),
          ),
        ),
        Expanded(
          child: _filteredBarangList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada barang yang ditemukan',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _filteredBarangList.length,
                  itemBuilder: (ctx, i) {
                    final barang = _filteredBarangList[i];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showBarangDetail(barang),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: barang.gambar != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          'http://127.0.0.1:8000/storage/${barang.gambar}',
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                color: Colors.grey[200],
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.broken_image, color: Colors.grey),
                                            );
                                          },
                                        ),
                                      )
                                    : Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                      ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                barang.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                barang.deskripsi,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'Stok: ${barang.stock}',
                                      style: TextStyle(
                                        color: Colors.grey[800],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _handlePinjam(barang),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      minimumSize: const Size(0, 32),
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text(
                                      'Pinjam',
                                      style: TextStyle(fontSize: 12, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showBarangDetail(Barang barang) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    barang.nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (barang.gambar != null)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'http://127.0.0.1:8000/storage/${barang.gambar}',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Deskripsi:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                barang.deskripsi,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Stok: ${barang.stock}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _handlePinjam(barang);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Pinjam Sekarang'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DaftarPeminjamanPage(token: widget.token, userId: widget.user['id']),
      _buildHome(),
      DaftarPengembalianPage(token: widget.token, userId: widget.user['id']),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          ['Daftar Peminjaman', 'Daftar Barang', 'Riwayat Pengembalian'][_selectedIndex],
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _isLoggingOut ? null : _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        elevation: 4,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_rounded),
            label: 'Peminjaman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_rounded),
            label: 'Barang',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}