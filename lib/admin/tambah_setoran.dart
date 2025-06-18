import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TambahSetoran extends StatefulWidget {
  final String namaNasabah;

  const TambahSetoran({super.key, required this.namaNasabah});

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

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd MMMM yyyy').format(pickedDate);
      setState(() {
        tanggalController.text = formattedDate;
      });
    }
  }

  Future<void> _simpanKeFirestore() async {
    final berat = int.tryParse(beratController.text) ?? 0;
    final pendapatan = berat * hargaPerKg;

    try {
      await FirebaseFirestore.instance.collection('setoran').add({
        'nama': widget.namaNasabah,
        'kategori': selectedKategori,
        'berat': berat,
        'pendapatan': pendapatan,
        'tanggalSetor':
            DateFormat('dd MMMM yyyy').parse(tanggalController.text),
        'alamat': alamatController.text,
        'catatan': catatanController.text,
        'status': 'Sudah di Konfirmasi',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Setoran berhasil disimpan')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
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
              _buildInputLabel("Nama Pengguna"),
              const SizedBox(height: 4),
              Text(widget.namaNasabah,
                  style: const TextStyle(fontSize: 16)),
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
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  hintText: 'Pilih tanggal',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
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
                    if (beratController.text.isEmpty ||
                        tanggalController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Berat dan Tanggal harus diisi')),
                      );
                      return;
                    }
                    _simpanKeFirestore();
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
