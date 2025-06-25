import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'daftar_nasabah.dart';
import 'notifikasi_admin.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  int jumlahNasabah = 0;

  @override
  void initState() {
    super.initState();
    _ambilJumlahNasabah();
  }

  Future<void> _ambilJumlahNasabah() async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Nasabah')
        .get();
    setState(() => jumlahNasabah = snap.docs.length);
  }

  /* ───────────────────────────── UI ───────────────────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _ambilJumlahNasabah,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// ==== SALDO ADMIN (real-time) ====
           StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance
      .collection('settings')
      .doc('admin_saldo')
      .snapshots(),
  builder: (context, snap) {
    if (snap.hasError) {
      return _card(Icons.savings, 'Saldo Admin', '⚠️ ${snap.error}');
    }
    if (snap.connectionState == ConnectionState.waiting) {
      return _card(Icons.savings, 'Saldo Admin', 'Memuat...');
    }

    if (!snap.data!.exists) {
      return _card(Icons.savings, 'Saldo Admin', 'Dokumen admin_saldo belum dibuat.');
    }

    final data = snap.data!.data() as Map<String, dynamic>?;
    if (data == null || !data.containsKey('saldo')) {
      return _card(Icons.savings, 'Saldo Admin', 'Field "saldo" tidak ditemukan.');
    }

    final saldo = data['saldo'] as int;
    final rp = _rupiah(saldo);
    final juta = (saldo / 1e6).toStringAsFixed(2);

    return _card(Icons.savings, 'Saldo Admin', '$juta Juta\nRp $rp');
  },
),


            _card(Icons.group,     'Nasabah',  '$jumlahNasabah'),
            _card(Icons.recycling, 'Sampah',   '1,22 Ton\n1 220,00 Kg'),
            _card(Icons.delete,    'Kategori', 'Organik : 15 Kg\nAnorganik : 20 Kg'),
            const SizedBox(height: 20),

            _btn('Daftar Nasabah',  Colors.black, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DaftarNasabah()));
            }),
            const SizedBox(height: 12),
            _btn('Notifikasi Penarikan', Colors.red, () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotifikasiAdmin()));
            }),
          ],
        ),
      ),
    );
  }

  /* ---------- helper widget ---------- */
  Widget _card(IconData ic, String t, String c) => Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(ic, size: 38),
          title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(c),
        ),
      );

  Widget _btn(String label, Color color, VoidCallback onTap) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: onTap,
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
      );

  String _rupiah(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
}
