import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'tambah_setoran.dart';

class DaftarNasabah extends StatelessWidget {
  const DaftarNasabah({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Daftar Nasabah'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'Nasabah')
            .snapshots(), // Tanpa orderBy agar aman dari error
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan saat memuat data.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final nasabahList = snapshot.data!.docs;

          if (nasabahList.isEmpty) {
            return const Center(child: Text('Belum ada nasabah terdaftar.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: nasabahList.length,
            itemBuilder: (context, index) {
              final nasabah = nasabahList[index];
              final data = nasabah.data() as Map<String, dynamic>;

              final nama = data['nama'] ?? 'Tanpa Nama';
              final saldo = data['saldo'] ?? 0;
              final createdAt = data['createdAt'];
              final idShort = nasabah.id.substring(0, 5).toUpperCase();

              String tanggalFormatted = '-';
              if (createdAt != null && createdAt is Timestamp) {
                tanggalFormatted =
                    DateFormat('d MMMM yyyy').format(createdAt.toDate());
              }

              return _buildNasabahCard(
                context,
                nama: nama,
                saldo: saldo,
                tanggal: tanggalFormatted,
                id: idShort,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildNasabahCard(
    BuildContext context, {
    required String nama,
    required int saldo,
    required String tanggal,
    required String id,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.person, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nama,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('ID: N-$id'),
                  Text('Terdaftar, $tanggal'),
                  const SizedBox(height: 8),
                  const Text('Saldo Saat Ini:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    'Rp ${NumberFormat("#,##0", "id_ID").format(saldo)}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                TambahSetoran(namaNasabah: nama),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Tambah Setoran'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: Colors.black),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
