import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class HalamanTransaksi extends StatefulWidget {
  const HalamanTransaksi({super.key});

  @override
  State<HalamanTransaksi> createState() => _HalamanTransaksiState();
}

class _HalamanTransaksiState extends State<HalamanTransaksi> {
  final _auth = FirebaseAuth.instance;
  final _fs   = FirebaseFirestore.instance;

  String uid = '', nama = '';

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      uid = user.uid;
    }
  }

  /* ───────────── Tarik Saldo Dialog ───────────── */
  void _tarikSaldoDialog(int saldoSaatIni) {
    final c = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tarik Saldo'),
        content: TextField(
          controller: c,
          decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final jumlah = int.tryParse(c.text);
              if (jumlah == null || jumlah <= 0) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Nominal tidak valid')));
                return;
              }
              if (jumlah > saldoSaatIni) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Saldo tidak cukup')));
                return;
              }

              try {
                await _fs.collection('penarikan').add({
                  'uid'    : uid,
                  'nama'   : nama,
                  'jumlah' : jumlah,
                  'status' : 'pending',
                  'tanggal': Timestamp.now(),
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Permintaan dikirim, tunggu persetujuan')));
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Gagal: $e')));
              }
            },
            child: const Text('Kirim'),
          )
        ],
      ),
    );
  }

  /* ───────────── UI ───────────── */
  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) {
      return const Scaffold(body: Center(child: Text('User tidak ditemukan')));
    }

    /*  Stream dokumen user → saldo & nama selalu up-to-date  */
    return StreamBuilder<DocumentSnapshot>(
      stream: _fs.collection('users').doc(uid).snapshots(),
      builder: (context, userSnap) {
        if (userSnap.hasError) {
          return const Scaffold(body: Center(child: Text('Gagal memuat data')));
        }
        if (!userSnap.hasData || !userSnap.data!.exists) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final uData = userSnap.data!;
        final saldo = (uData['saldo'] ?? 0) as int;
        nama = uData['nama'] ?? 'Nasabah';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Riwayat Transaksi'),
            foregroundColor: Colors.black,
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          backgroundColor: Colors.grey[200],
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _saldoCard(saldo),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    icon: const Icon(Icons.money),
                    label: const Text('Tarik Saldo'),
                    onPressed: () => _tarikSaldoDialog(saldo),
                  ),
                ),
                const SizedBox(height: 16),

                /*  Stream list setoran user  */
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _fs
                        .collection('setoran')
                        .where('nama', isEqualTo: nama)
                        .orderBy('tanggalSetor', descending: true)
                        .snapshots(),
                    builder: (ctx, snap) {
                      if (snap.hasError) {
                        return const Center(child: Text('Terjadi kesalahan'));
                      }
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final list = snap.data!.docs;
                      if (list.isEmpty) {
                        return const Center(child: Text('Belum ada transaksi.'));
                      }

                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final d = list[i];
                          final tgl =
                              (d['tanggalSetor'] as Timestamp).toDate();
                          final tglTxt =
                              DateFormat('dd MMM yyyy').format(tgl);
                          final kat = d['kategori'];
                          final berat = d['berat'];
                          final pend = d['pendapatan'];

                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nama,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(tglTxt),
                                  const SizedBox(height: 4),
                                  Text('Sampah $kat'),
                                  const SizedBox(height: 4),
                                  const Text('Sudah di Konfirmasi',
                                      style:
                                          TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('Berat : $berat Kg'),
                                  Text(
                                    'Pendapatan : Rp ${NumberFormat("#,##0", "id_ID").format(pend)}',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /* kartu saldo */
  Widget _saldoCard(int saldo) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet),
            const SizedBox(width: 12),
            const Text('Saldo Anda :'),
            const SizedBox(width: 8),
            Text(
              'Rp ${NumberFormat("#,##0", "id_ID").format(saldo)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );

  /* hapus setoran (opsional) */
  void _hapusData(String id) {
    _fs.collection('setoran').doc(id).delete();
  }
}
