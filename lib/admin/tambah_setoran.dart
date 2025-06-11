import 'package:flutter/material.dart';

class TambahSetoran extends StatefulWidget {
  const TambahSetoran({super.key});

  @override
  State<TambahSetoran> createState() => _TambahSetoranState();
}

class _TambahSetoranState extends State<TambahSetoran> {
  String selectedKategori = 'Organik';
  final TextEditingController beratController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Setor Sampah'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                children: const [
                  Icon(Icons.info, color: Colors.black),
                  SizedBox(width: 8),
                  Text(
                    'Mohon isi data di bawah ini dengan benar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
              const SizedBox(height: 16),
              _buildInputLabel("Nama Pengguna"),
              const Text("Andika", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              _buildInputLabel("Kategori Sampah"),
              DropdownButtonFormField<String>(
                value: selectedKategori,
                items: ['Organik', 'Anorganik'].map((kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedKategori = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel("Berat (Kg)"),
                        TextField(
                          controller: beratController,
                          decoration: const InputDecoration(hintText: '5 Kg'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Harga (per Kg)", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text("Rp 1.000"),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInputLabel("Tanggal Setor"),
              TextField(
                controller: tanggalController,
                decoration: const InputDecoration(hintText: 'Masukkan tanggal'),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16),
              _buildInputLabel("Alamat"),
              TextField(
                controller: alamatController,
              ),
              const SizedBox(height: 16),
              _buildInputLabel("Catatan Tambahan (Opsional)"),
              TextField(
                controller: catatanController,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Aksi setor
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Setor Sekarang', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold),
    );
  }
}
