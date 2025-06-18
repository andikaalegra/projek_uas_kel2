import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../halaman_login.dart';

class ProfilNasabah extends StatefulWidget {
  const ProfilNasabah({super.key});

  @override
  State<ProfilNasabah> createState() => _ProfilNasabahState();
}

class _ProfilNasabahState extends State<ProfilNasabah> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _ambilDataUser();
  }

  Future<void> _ambilDataUser() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        setState(() {
          _errorMsg = "User tidak ditemukan.";
          _isLoading = false;
        });
        return;
      }

      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        setState(() {
          _errorMsg = "Data user tidak ditemukan di database.";
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _userData = doc.data();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = "Terjadi kesalahan: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMsg != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Profil Nasabah"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Center(child: Text(_errorMsg!)),
      );
    }

    final nama = _userData!['nama'] ?? 'Tidak diketahui';
    final email = _userData!['email'] ?? '-';
    final noHp = _userData!['noHp'] ?? '-';
    final saldo = _userData!['saldo'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Nasabah'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black,
              child: Icon(Icons.person, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 16),
            Text(nama, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(email),
            const SizedBox(height: 24),

            _buildInfoTile("Nomor HP", noHp),
            const SizedBox(height: 10),
            _buildInfoTile("Saldo Anda",
              'Rp ${NumberFormat("#,##0", "id_ID").format(saldo)}',
              icon: Icons.account_balance_wallet,
            ),
            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _auth.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HalamanLogin()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text("Keluar"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(icon ?? Icons.info, color: Colors.black54),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text(value),
        ],
      ),
    );
  }
}
