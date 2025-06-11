import 'package:flutter/material.dart';
import 'daftar_nasabah.dart';

class DashboardAdmin extends StatelessWidget {
  const DashboardAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildCard(Icons.group, "Nasabah", "3"),
              _buildCard(Icons.recycling, "Sampah", "1,22 Ton\n1.220,00 Kg"),
              _buildCard(Icons.attach_money, "Saldo", "30.25 Juta\nRp 30.250.000,-"),
              _buildCard(Icons.delete_outline, "Kategori", "Organik : 15 Kg\nAnorganik : 20 Kg"),
              const SizedBox(height: 20),
              ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.black,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DaftarNasabah()),
    );
  },
  child: const Text("Daftar Nasabah", style: TextStyle(color: Colors.white)),
),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.black),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(content, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
