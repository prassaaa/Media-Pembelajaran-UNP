import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/theme.dart';

class FormIdentitasScreen extends StatefulWidget {
  const FormIdentitasScreen({Key? key}) : super(key: key);

  @override
  State<FormIdentitasScreen> createState() => _FormIdentitasScreenState();
}

class _FormIdentitasScreenState extends State<FormIdentitasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _absenController = TextEditingController();
  final _kelasController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _absenController.dispose();
    _kelasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String jenisKegiatan = args['jenisKegiatan']; // 'lkpd' atau 'evaluasi'
    final dynamic kegiatan = args['kegiatan']; // LKPD atau Evaluasi object
    final String routeTarget = args['routeTarget']; // route tujuan setelah form

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              backgroundColor: jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Data Diri Siswa',
                  style: AppTheme.subtitleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: jenisKegiatan == 'lkpd' 
                          ? [Colors.orange, Colors.orange.shade800]
                          : [AppTheme.successColor, AppTheme.successColor.withOpacity(0.8)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(
                          jenisKegiatan == 'lkpd' ? Icons.assignment_outlined : Icons.quiz,
                          size: 64,
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor).withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            jenisKegiatan == 'lkpd' ? Icons.assignment_outlined : Icons.quiz,
                            color: jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            jenisKegiatan == 'lkpd' ? 'LKPD' : 'Evaluasi',
                            style: AppTheme.subtitleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        jenisKegiatan == 'lkpd' ? kegiatan.judul : kegiatan.judul,
                        style: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Silakan isi data diri Anda sebelum memulai ${jenisKegiatan == 'lkpd' ? 'LKPD' : 'evaluasi'}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Diri',
                          style: AppTheme.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Nama Lengkap
                        TextFormField(
                          controller: _namaController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap',
                            hintText: 'Masukkan nama lengkap Anda',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama lengkap harus diisi';
                            }
                            if (value.length < 3) {
                              return 'Nama lengkap minimal 3 karakter';
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 16),

                        // Nomor Absen
                        TextFormField(
                          controller: _absenController,
                          decoration: InputDecoration(
                            labelText: 'Nomor Absen',
                            hintText: 'Masukkan nomor absen Anda',
                            prefixIcon: const Icon(Icons.numbers),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor,
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nomor absen harus diisi';
                            }
                            final absen = int.tryParse(value);
                            if (absen == null || absen <= 0) {
                              return 'Nomor absen harus berupa angka positif';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Kelas
                        TextFormField(
                          controller: _kelasController,
                          decoration: InputDecoration(
                            labelText: 'Kelas',
                            hintText: 'Contoh: X IPA 1, XI IPS 2',
                            prefixIcon: const Icon(Icons.class_),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kelas harus diisi';
                            }
                            if (value.length < 2) {
                              return 'Kelas minimal 2 karakter';
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.words,
                        ),
                        const SizedBox(height: 24),

                        // Info tambahan
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.infoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.infoColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppTheme.infoColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Data ini akan disimpan untuk keperluan evaluasi pembelajaran oleh guru',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.infoColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tombol
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Kembali'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor,
                          side: BorderSide(
                            color: jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Kirim data ke halaman tujuan
                            Navigator.pushNamed(
                              context,
                              routeTarget,
                              arguments: {
                                'kegiatan': kegiatan,
                                'identitasSiswa': {
                                  'namaLengkap': _namaController.text.trim(),
                                  'nomorAbsen': _absenController.text.trim(),
                                  'kelas': _kelasController.text.trim(),
                                },
                              },
                            );
                          }
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: Text('Mulai ${jenisKegiatan == 'lkpd' ? 'LKPD' : 'Evaluasi'}'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}