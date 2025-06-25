import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TambahSetoran extends StatefulWidget {
  final String namaNasabah;   // ganti ke uidNasabah kalau punya uid

  const TambahSetoran({super.key, required this.namaNasabah});

  @override
  State<TambahSetoran> createState() => _TambahSetoranState();
}

class _TambahSetoranState extends State<TambahSetoran> {
  String selectedKategori = 'Organik';
  final beratC   = TextEditingController();
  final tanggalC = TextEditingController();
  final alamatC  = TextEditingController();
  final catatanC = TextEditingController();

  final int hargaPerKg = 1000;
  int totalHarga = 0;

  @override
  void initState() {
    super.initState();
    beratC.addListener(_hitungTotal);
  }

  @override
  void dispose() {
    beratC.removeListener(_hitungTotal);
    beratC.dispose();
    tanggalC.dispose();
    alamatC.dispose();
    catatanC.dispose();
    super.dispose();
  }

  void _hitungTotal() {
    final b = int.tryParse(beratC.text) ?? 0;
    setState(() => totalHarga = b * hargaPerKg);
  }

  Future<void> _pilihTanggal() async {
    final now = DateTime.now();
    final pick = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (pick != null) {
      tanggalC.text = DateFormat('dd MMMM yyyy').format(pick);
    }
  }

  Future<void> _simpan() async {
    final berat = int.tryParse(beratC.text) ?? 0;
    if (berat == 0 || tanggalC.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Berat & tanggal wajib diisi')));
      return;
    }

    final pendapatan = berat * hargaPerKg;
    final fs = FirebaseFirestore.instance;

    try {
      await fs.runTransaction((t) async {
        /* =========================================================
           1. Tambah dokumen setoran
           ========================================================= */
        t.set(fs.collection('setoran').doc(), {
          'nama': widget.namaNasabah,
          'kategori': selectedKategori,
          'berat': berat,
          'pendapatan': pendapatan,
          'tanggalSetor': DateFormat('dd MMMM yyyy').parse(tanggalC.text),
          'alamat': alamatC.text,
          'catatan': catatanC.text,
          'status': 'Sudah di Konfirmasi',
        });

        /* =========================================================
           2. Tambah saldo nasabah
           ========================================================= */
        final q = await fs
            .collection('users')
            .where('nama', isEqualTo: widget.namaNasabah)
            .limit(1)
            .get();

        if (q.docs.isEmpty) throw 'User tidak ditemukan';

        final userRef  = q.docs.first.reference;
        final userData = q.docs.first.data();
        int saldoLama  = (userData['saldo'] ?? 0) as int;

        t.update(userRef, {'saldo': saldoLama + pendapatan});
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Setoran & saldo berhasil diperbarui')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  /* ─────────────────────────────  UI  ───────────────────────────── */
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          title: const Text('Setor Sampah'),
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Nama Pengguna'),
                const SizedBox(height: 4),
                Text(widget.namaNasabah, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),

                _label('Kategori Sampah'),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: selectedKategori,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                  items: const ['Organik', 'Anorganik']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedKategori = v!),
                ),
                const SizedBox(height: 16),

                Row(children: [
                  Expanded(child: _fieldBerat()),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _readOnlyBox('Harga (per Kg)', 'Rp $hargaPerKg'),
                  ),
                ]),
                const SizedBox(height: 16),

                _readOnlyBox('Total Harga', 'Rp $totalHarga'),
                const SizedBox(height: 16),

                _label('Tanggal Setor'),
                const SizedBox(height: 4),
                TextField(
                  controller: tanggalC,
                  readOnly: true,
                  onTap: _pilihTanggal,
                  decoration: const InputDecoration(
                    hintText: 'Pilih tanggal',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 16),

                _label('Alamat'),
                const SizedBox(height: 4),
                TextField(
                  controller: alamatC,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                _label('Catatan Tambahan (Opsional)'),
                const SizedBox(height: 4),
                TextField(
                  controller: catatanC,
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    onPressed: _simpan,
                    child: const Text('Setor Sekarang',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  /* helper widgets ------------------------------------------------ */
  Widget _label(String t) =>
      Text(t, style: const TextStyle(fontWeight: FontWeight.bold));

  Widget _fieldBerat() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Berat (Kg)'),
          const SizedBox(height: 4),
          TextField(
            controller: beratC,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: '0 Kg',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      );

  Widget _readOnlyBox(String title, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(title),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(value),
          ),
        ],
      );
}
