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

  final int hargaPerKg = 1000;
  int totalHarga = 0;

  @override
  void initState() {
    super.initState();
    beratController.addListener(_hitungTotalHarga);
  }

  @override
  void dispose() {
    beratController.removeListener(_hitungTotalHarga);
    beratController.dispose();
    tanggalController.dispose();
    alamatController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  void _hitungTotalHarga() {
    final berat = int.tryParse(beratController.text) ?? 0;
    setState(() {
      totalHarga = berat * hargaPerKg;
    });
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.info, color: Colors.black),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mohon isi data di bawah ini dengan benar',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInputLabel("Nama Pengguna"),
              const SizedBox(height: 4),
              const Text("Andika", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),

              _buildInputLabel("Kategori Sampah"),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: selectedKategori,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
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
                        const SizedBox(height: 4),
                        TextField(
                          controller: beratController,
                          decoration: const InputDecoration(
                            hintText: '0 Kg',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputLabel("Harga (per Kg)"),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text("Rp $hargaPerKg"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _buildInputLabel("Total Harga"),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text("Rp $totalHarga"),
              ),

              const SizedBox(height: 16),
              _buildInputLabel("Tanggal Setor"),
              const SizedBox(height: 4),
              TextField(
                controller: tanggalController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan tanggal',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16),

              _buildInputLabel("Alamat"),
              const SizedBox(height: 4),
              TextField(
                controller: alamatController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              _buildInputLabel("Catatan Tambahan (Opsional)"),
              const SizedBox(height: 4),
              TextField(
                controller: catatanController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Aksi setor
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: const Text(
                    'Setor Sekarang',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
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