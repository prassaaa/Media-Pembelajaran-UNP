import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class IdentitasScreen extends StatelessWidget {
  const IdentitasScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final FirebaseService _firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Identitas Pengembang'),
        centerTitle: true,
      ),
      body: FutureBuilder<Identitas?>(
        future: _firebaseService.getIdentitas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget(message: 'Memuat data identitas...');
          }

          if (snapshot.hasError) {
            return AppErrorWidget(
              message: 'Terjadi kesalahan: ${snapshot.error}',
              onRetry: () {
                // Refresh the data
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const IdentitasScreen(),
                  ),
                );
              },
            );
          }

          final identitas = snapshot.data;

          if (identitas == null) {
            return const EmptyStateWidget(
              title: 'Data Identitas Belum Tersedia',
              subtitle: 'Data identitas pengembang belum diatur oleh admin.',
              icon: Icons.person_off,
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Aplikasi Media Pembelajaran UNP',
                        style: AppTheme.headingSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dikembangkan Oleh:',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Mahasiswa
                Text(
                  'Identitas Mahasiswa',
                  style: AppTheme.headingSmall,
                ),
                const SizedBox(height: 16),
                _buildPersonCard(
                  nama: identitas.namaMahasiswa,
                  nip: identitas.nimMahasiswa,
                  prodi: identitas.prodiMahasiswa,
                  fotoUrl: identitas.fotoMahasiswaUrl,
                  role: 'Mahasiswa',
                ),
                const SizedBox(height: 24),

                // Dosen Pembimbing 1
                Text(
                  'Dosen Pembimbing 1',
                  style: AppTheme.headingSmall,
                ),
                const SizedBox(height: 16),
                _buildPersonCard(
                  nama: identitas.namaDospem1,
                  nip: identitas.nipDospem1,
                  fotoUrl: identitas.fotoDospem1Url,
                  role: 'Dosen Pembimbing 1',
                ),
                const SizedBox(height: 24),

                // Dosen Pembimbing 2 (jika ada)
                if (identitas.namaDospem2 != null &&
                    identitas.namaDospem2!.isNotEmpty) ...[
                  Text(
                    'Dosen Pembimbing 2',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildPersonCard(
                    nama: identitas.namaDospem2!,
                    nip: identitas.nipDospem2 ?? '',
                    fotoUrl: identitas.fotoDospem2Url,
                    role: 'Dosen Pembimbing 2',
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPersonCard({
    required String nama,
    required String nip,
    String? prodi,
    String? fotoUrl,
    required String role,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: fotoUrl != null && fotoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: fotoUrl,
                      width: 120,
                      height: 150,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 120,
                        height: 150,
                        color: Colors.grey.withOpacity(0.3),
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 120,
                        height: 150,
                        color: Colors.grey.withOpacity(0.3),
                        child: const Icon(
                          Icons.person,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 150,
                      color: Colors.grey.withOpacity(0.3),
                      child: const Icon(
                        Icons.person,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      role,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nama,
                    style: AppTheme.subtitleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NIP/NIM: $nip',
                    style: AppTheme.bodyMedium,
                  ),
                  if (prodi != null && prodi.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Program Studi: $prodi',
                      style: AppTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}