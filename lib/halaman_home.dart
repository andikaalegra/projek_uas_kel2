import 'package:flutter/material.dart';

class HalamanHome extends StatelessWidget {
  final String namaUser;

  const HalamanHome({Key? key, required this.namaUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black, width: 1),
            ),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Selamat Datang", style: TextStyle(fontSize: 16)),
                        Text(
                          namaUser,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    Icon(Icons.logout, size: 24),
                  ],
                ),
                SizedBox(height: 20),

                // Edukasi Box
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Tukarkan sampah plastikmu sekarang!!!",
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Icon(Icons.delete_outline, size: 60),
                      SizedBox(height: 10),
                      Text(
                        "Aplikasi Bank Sampah adalah solusi untuk menyelesaikan masalah sosial tentang kebersihan lingkungan.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Menu buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MenuButton(
                      icon: Icons.swap_horiz,
                      label: "Transaksi",
                      onTap: () {
                        // Navigasi ke halaman transaksi
                      },
                    ),
                    _MenuButton(
                      icon: Icons.person_outline,
                      label: "Profile",
                      onTap: () {
                        // Navigasi ke halaman profile
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30),
            SizedBox(height: 10),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
