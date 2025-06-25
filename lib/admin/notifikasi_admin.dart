import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotifikasiAdmin extends StatelessWidget {
  const NotifikasiAdmin({super.key});

  /* ──────────────── UI ──────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi Penarikan'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[300],
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('penarikan')
            .orderBy('tanggal', descending: true)
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          }
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Tidak ada permintaan penarikan.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final id      = docs[i].id;
              final uid     = d['uid'];
              final nama    = d['nama'];
              final jumlah  = d['jumlah'] ?? 0;
              final status  = d['status'] ?? 'pending';
              final tglTxt  = DateFormat('dd MMM yyyy')
                  .format((d['tanggal'] as Timestamp).toDate());

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama,  style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Rp ${NumberFormat("#,##0","id_ID").format(jumlah)}'),
                      Text(tglTxt),
                      Text('Status: $status'),
                      if (status == 'pending') ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.cancel, color: Colors.red),
                              label: const Text('Tolak', style: TextStyle(color: Colors.red)),
                              onPressed: () => _tolak(id, ctx),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              label: const Text('Setujui', style: TextStyle(color: Colors.green)),
                              onPressed: () =>
                                  _setujui(uid: uid, docId: id, jumlah: jumlah, ctx: ctx),
                            ),
                          ],
                        )
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /* ──────────────── PROSES SETUJUI ──────────────── */
  Future<void> _setujui(
      {required String uid,
      required String docId,
      required int jumlah,
      required BuildContext ctx}) async {
    final fs = FirebaseFirestore.instance;
    final userRef   = fs.collection('users').doc(uid);
    final adminRef  = fs.collection('settings').doc('admin_saldo');
    final tarikRef  = fs.collection('penarikan').doc(docId);

    try {
      await fs.runTransaction((t) async {
        /* ---------- ambil saldo admin ---------- */
        final adminSnap = await t.get(adminRef);
        if (!adminSnap.exists) throw 'Saldo admin belum diset';
        int saldoAdmin  = (adminSnap['saldo'] ?? 0) as int;

        /* ---------- ambil saldo user ---------- */
        final userSnap  = await t.get(userRef);
        if (!userSnap.exists) throw 'User tidak ditemukan';
        int saldoUser   = (userSnap['saldo'] ?? 0) as int;

        /* ---------- cek kecukupan ---------- */
        if (saldoUser < jumlah) throw 'Saldo nasabah tidak cukup';
        if (saldoAdmin < jumlah) throw 'Saldo admin tidak cukup';

        /* ---------- update kedua saldo ---------- */
        t.update(adminRef, {'saldo': saldoAdmin - jumlah}); // admin berkurang
        t.update(userRef,  {'saldo': saldoUser  - jumlah}); // nasabah berkurang

        /* ---------- ubah status penarikan ---------- */
        t.update(tarikRef, {'status': 'approved'});
      });

      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(content: Text('Penarikan disetujui ✅')),
      );
    } catch (e) {
      ScaffoldMessenger.of(ctx)
          .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  /* ──────────────── PROSES TOLAK ──────────────── */
  Future<void> _tolak(String docId, BuildContext ctx) async {
    try {
      await FirebaseFirestore.instance
          .collection('penarikan')
          .doc(docId)
          .update({'status': 'rejected'});

      ScaffoldMessenger.of(ctx)
          .showSnackBar(const SnackBar(content: Text('Penarikan ditolak ❌')));
    } catch (e) {
      ScaffoldMessenger.of(ctx)
          .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }
}
