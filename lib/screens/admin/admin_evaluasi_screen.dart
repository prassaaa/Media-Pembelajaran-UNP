import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class AdminEvaluasiScreen extends StatefulWidget {
  const AdminEvaluasiScreen({Key? key}) : super(key: key);

  @override
  State<AdminEvaluasiScreen> createState() => _AdminEvaluasiScreenState();
}

class _AdminEvaluasiScreenState extends State<AdminEvaluasiScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

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
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppConstants.routeAdminEvaluasiForm,
                    ).then((_) => setState(() {}));
                  },
                  icon: const Icon(Icons.add),
                  tooltip: 'Tambah Evaluasi',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Kelola Evaluasi',
                  style: AppTheme.subtitleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
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
                                Icons.assignment,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kelola Evaluasi dan Soal',
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
        body: _isLoading
            ? const LoadingWidget(message: 'Memuat data evaluasi...')
            : StreamBuilder<List<Evaluasi>>(
                stream: _firebaseService.getEvaluasi(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingWidget(
                        message: 'Memuat data evaluasi...');
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
                      subtitle:
                          'Tambahkan evaluasi pembelajaran untuk ditampilkan pada aplikasi.',
                      icon: Icons.assignment,
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Evaluasi Pembelajaran',
                          style: AppTheme.headingSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kelola dan tambahkan evaluasi pembelajaran baru',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: evaluasiList.length,
                            itemBuilder: (context, index) {
                              final evaluasi = evaluasiList[index];
                              return _buildEvaluasiItem(context, evaluasi);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppConstants.routeAdminEvaluasiForm,
          ).then((_) => setState(() {}));
        },
        backgroundColor: AppTheme.successColor,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Evaluasi'),
      ),
    );
  }

  Widget _buildEvaluasiItem(BuildContext context, Evaluasi evaluasi) {
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.assignment,
                      color: AppTheme.successColor,
                      size: 32,
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
                        ),
                        const SizedBox(height: 8),
                        Text(
                          evaluasi.deskripsi,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Info tambahan
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem(
                      'Jumlah Soal',
                      '${evaluasi.soalIds.length}',
                      Icons.question_answer,
                    ),
                    _buildInfoItem(
                      'Dibuat',
                      _formatDate(evaluasi.createdAt),
                      Icons.calendar_today,
                    ),
                    _buildInfoItem(
                      'Diperbarui',
                      _formatDate(evaluasi.updatedAt),
                      Icons.update,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              // Tombol Aksi
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppConstants.routeAdminEvaluasiForm,
                          arguments: evaluasi,
                        ).then((_) => setState(() {}));
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showDeleteConfirmation(context, evaluasi),
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppTheme.successColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, Evaluasi evaluasi) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus evaluasi "${evaluasi.judul}"? Tindakan ini juga akan menghapus semua soal terkait dan tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                _deleteEvaluasi(evaluasi);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEvaluasi(Evaluasi evaluasi) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.deleteEvaluasi(evaluasi.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evaluasi berhasil dihapus'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus evaluasi: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}