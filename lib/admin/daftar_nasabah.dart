import 'package:flutter/material.dart';
import 'tambah_setoran.dart';

class DaftarNasabah extends StatelessWidget {
  const DaftarNasabah({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50], // Lebih segar
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Daftar Nasabah'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(3, (index) => _buildNasabahCard(context, index)),
      ),
    );
  }

  Widget _buildNasabahCard(BuildContext context, int index) {
    // Data dummy bisa diganti dengan data asli dari Firestore
    final List<Map<String, String>> dataNasabah = [
      {"nama": "Andika", "id": "N-001", "saldo": "Rp 0,00", "tanggal": "3 Juni 2025"},
      {"nama": "Bella", "id": "N-002", "saldo": "Rp 125.000", "tanggal": "5 Juni 2025"},
      {"nama": "Ega", "id": "N-003", "saldo": "Rp 98.000", "tanggal": "10 Juni 2025"},
    ];

    final nasabah = dataNasabah[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nasabah['nama']!,
                      style:
                          const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("ID: ${nasabah['id']}"),
                  Text("Terdaftar: ${nasabah['tanggal']}"),
                  const SizedBox(height: 8),
                  const Text('Saldo Saat Ini:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(nasabah['saldo']!,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TambahSetoran()),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah Setoran'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
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
