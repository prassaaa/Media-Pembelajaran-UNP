import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';
class EvaluasiScreen extends StatefulWidget {
  const EvaluasiScreen({Key? key}) : super(key: key);

  @override
  State<EvaluasiScreen> createState() => _EvaluasiScreenState();
}

class _EvaluasiScreenState extends State<EvaluasiScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.successColor,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  'Evaluasi Pembelajaran',
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
                        AppTheme.successColor,
                        const Color(0xFF004D40), // Darker shade of success color
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
                                Icons.quiz_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Uji Pemahaman Anda',
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
        body: StreamBuilder<List<Evaluasi>>(
          stream: _firebaseService.getEvaluasi(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget(
                message: 'Memuat daftar evaluasi...',
              );
            }

            if (snapshot.hasError) {
              return AppErrorWidget(
                message: 'Terjadi kesalahan: ${snapshot.error}',
                onRetry: () {
                  setState(() {});
                },
              );
            }

            final List<Evaluasi> evaluasiList = snapshot.data ?? [];

            if (evaluasiList.isEmpty) {
              return const EmptyStateWidget(
                title: 'Belum Ada Evaluasi',
                subtitle: 'Evaluasi pembelajaran belum tersedia saat ini.',
                icon: Icons.assignment,
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih Evaluasi Pembelajaran',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kerjakan soal evaluasi untuk menguji pemahaman Anda',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: evaluasiList.length,
                      itemBuilder: (context, index) {
                        final evaluasi = evaluasiList[index];
                        return _buildEvaluasiCard(context, evaluasi);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEvaluasiCard(BuildContext context, Evaluasi evaluasi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppConstants.routeEvaluasiDetail,
              arguments: evaluasi,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.assignment,
                        color: AppTheme.successColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Info Evaluasi
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            evaluasi.judul,
                            style: AppTheme.subtitleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2, // Mencegah judul terlalu panjang
                            overflow: TextOverflow.ellipsis, //
                          ),
                          const SizedBox(height: 4),
                          Text(
                            evaluasi.deskripsi,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.secondaryTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Flexible( // FIX: Dibungkus Flexible
                                child: _buildEvaluasiStat(
                                  '${evaluasi.soalIds.length}',
                                  'Soal',
                                  Icons.help_outline,
                                ),
                              ),
                              const SizedBox(width: 12), // Sedikit mengurangi spasi jika perlu
                              Flexible( // FIX: Dibungkus Flexible
                                child: _buildEvaluasiStat(
                                  _getDifficultyLevel(evaluasi.soalIds.length),
                                  'Tingkat',
                                  Icons.fitness_center,
                                ),
                              ),
                              const SizedBox(width: 12), // Sedikit mengurangi spasi jika perlu
                              Flexible( // FIX: Dibungkus Flexible
                                child: _buildEvaluasiStat(
                                  _getEstimatedTime(evaluasi.soalIds.length),
                                  'Waktu',
                                  Icons.timer,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Terakhir diperbarui: ${_formatDate(evaluasi.updatedAt)}',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Mulai',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Widget _buildEvaluasiStat(String value, String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Agar Row tidak mengambil lebar maksimal jika tidak perlu
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.successColor,
        ),
        const SizedBox(width: 4),
        Flexible( // FIX: Dibungkus Flexible
          child: Text(
            '$value $label',
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis, // FIX: Tambahkan overflow handling
            softWrap: false, // FIX: Cegah wrap, prioritaskan ellipsis
          ),
        ),
      ],
    );
  }

  String _getDifficultyLevel(int soalCount) {
    if (soalCount <= 5) {
      return 'Mudah';
    } else if (soalCount <= 10) {
      return 'Sedang';
    } else {
      return 'Sulit';
    }
  }

  String _getEstimatedTime(int soalCount) {
    // Estimasi waktu pengerjaan
    int minutes = soalCount * 2; // 2 menit per soal
    return '$minutes Menit';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
                color: AppTheme.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: AppTheme.successColor,
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