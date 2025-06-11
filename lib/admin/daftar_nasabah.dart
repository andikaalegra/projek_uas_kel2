import 'package:flutter/material.dart';
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(3, (index) => _buildNasabahCard(context)),
      ),
    );
  }

  Widget _buildNasabahCard(BuildContext context) {
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
                  const Text('Andika', style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('ID: N-001'),
                  const Text('Terdaftar, 3 Juni 2025'),
                  const SizedBox(height: 8),
                  const Text('Saldo Saat Ini:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Rp 0,00', style: TextStyle(color: Colors.black)),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () {
                         Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TambahSetoran()),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
