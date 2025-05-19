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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.purple,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'Identitas Pengembang',
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
                      colors: [
                        Colors.purple,
                        Colors.deepPurple,
                      ],
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
                      Positioned(
                        left: -40,
                        bottom: -40,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.people_alt_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tim Pengembang Aplikasi',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 50), // Space for title
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
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
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple.withOpacity(0.1),
                          Colors.deepPurple.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.purple.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Aplikasi Media Pembelajaran UNP',
                          style: AppTheme.headingSmall.copyWith(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Dikembangkan Oleh:',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mahasiswa
                  Text(
                    'Mahasiswa Pengembang',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 16),
                  _buildPersonCard(
                    nama: identitas.namaMahasiswa,
                    nip: identitas.nimMahasiswa,
                    prodi: identitas.prodiMahasiswa,
                    fotoUrl: identitas.fotoMahasiswaUrl,
                    role: 'Mahasiswa',
                    gradientColors: [Colors.purple, Colors.deepPurple],
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
                    gradientColors: [Colors.blue, Colors.lightBlue],
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
                      gradientColors: [Colors.teal, Colors.cyan],
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Footer info
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Aplikasi ini dikembangkan sebagai bagian dari tugas Universitas Nusantara PGRI Kediri.',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60), // Extra space at bottom
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPersonCard({
    required String nama,
    required String nip,
    String? prodi,
    String? fotoUrl,
    required String role,
    required List<Color> gradientColors,
  }) {
    return Card(
      elevation: 4,
      shadowColor: gradientColors[0].withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              gradientColors[0].withOpacity(0.05),
            ],
          ),
        ),
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
                          color: gradientColors[0].withOpacity(0.1),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: gradientColors[0],
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 120,
                          height: 150,
                          color: gradientColors[0].withOpacity(0.1),
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
                        color: gradientColors[0].withOpacity(0.1),
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
                        gradient: LinearGradient(
                          colors: gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        role,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      nama,
                      style: AppTheme.subtitleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: gradientColors[1],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.badge, 'NIP/NIM: $nip', gradientColors[0]),
                    if (prodi != null && prodi.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.school, 'Program Studi: $prodi', gradientColors[0]),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildSocialIcon(Icons.email, gradientColors[0]),
                        _buildSocialIcon(Icons.link, gradientColors[1]),
                        _buildSocialIcon(Icons.facebook, Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
      ),
    );
  }
}

class AppErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AppErrorWidget({
    Key? key,
    required this.message,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.errorColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: AppTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTheme.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.secondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}