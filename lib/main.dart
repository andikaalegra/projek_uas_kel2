import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projek_uas_kel2/admin/daftar_nasabah.dart';
import 'package:projek_uas_kel2/firebase_options.dart';
import 'halaman_login.dart';
import 'halaman_daftar.dart';
import 'admin/dashboard_admin.dart';
import 'nasabah/dashboard_nasabah.dart';
import 'admin/tambah_setoran.dart';
import 'nasabah/halaman_transaksi.dart';
import 'nasabah/profil_nasabah.dart';

void main() async{
await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pilah-In',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home:HalamanLogin(),
    );
  }
}

