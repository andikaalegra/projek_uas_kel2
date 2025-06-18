import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HalamanTransaksi extends StatefulWidget {
  const HalamanTransaksi({super.key});

  @override
  State<HalamanTransaksi> createState() => _HalamanTransaksiState();
}

class _HalamanTransaksiState extends State<HalamanTransaksi> {
  String namaPengguna = 'Andika'; // Bisa diganti dari user auth jika ada
  int saldo = 95000; // Dummy data. Nanti bisa diganti dinamis dari Firestore

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSaldoCard(),

            const SizedBox(height: 16),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('setoran')
                    .orderBy('tanggalSetor', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Terjadi kesalahan');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final item = data[index];
                      final tanggal = (item['tanggalSetor'] as Timestamp).toDate();
                      final tanggalFormatted =
                          DateFormat('dd MMMM yyyy').format(tanggal);
                      final kategori = item['kategori'];
                      final berat = item['berat'];
                      final pendapatan = item['pendapatan'];

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(namaPengguna,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text(tanggalFormatted),
                              const SizedBox(height: 4),
                              Text('Sampah $kategori'),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Sudah di Konfirmasi',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.grey),
                                    onPressed: () {
                                      _hapusData(item.id);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('Berat : $berat Kg'),
                              Text(
                                  'Pendapatan : Rp ${NumberFormat("#,##0", "id_ID").format(pendapatan)}'),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSaldoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet, color: Colors.black),
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
  }

  void _hapusData(String id) {
    FirebaseFirestore.instance.collection('setoran').doc(id).delete();
  }
}
