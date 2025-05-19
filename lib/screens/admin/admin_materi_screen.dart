import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class AdminMateriScreen extends StatefulWidget {
  const AdminMateriScreen({Key? key}) : super(key: key);

  @override
  State<AdminMateriScreen> createState() => _AdminMateriScreenState();
}

class _AdminMateriScreenState extends State<AdminMateriScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  late Stream<List<Materi>> _materiStream;

  @override
  void initState() {
    super.initState();
    _materiStream = _firebaseService.getMateri();
  }

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
              backgroundColor: AppTheme.primaryColor,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppConstants.routeAdminMateriForm,
                    ).then((_) => setState(() {
                          _materiStream = _firebaseService.getMateri();
                        }));
                  },
                  icon: const Icon(Icons.add),
                  tooltip: 'Tambah Materi',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Kelola Materi',
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
                        AppTheme.primaryColor,
                        AppTheme.primaryColorDark,
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
                                Icons.menu_book_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kelola Konten Materi Pembelajaran',
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
            ? const LoadingWidget(message: 'Memuat data materi...')
            : StreamBuilder<List<Materi>>(
                stream: _materiStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingWidget(
                        message: 'Memuat data materi...');
                  }

                  if (snapshot.hasError) {
                    return AppErrorWidget(
                      message: 'Terjadi kesalahan: ${snapshot.error}',
                      onRetry: () {
                        setState(() {
                          _materiStream = _firebaseService.getMateri();
                        });
                      },
                    );
                  }

                  final List<Materi> materiList = snapshot.data ?? [];

                  if (materiList.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'Belum Ada Materi',
                      subtitle:
                          'Tambahkan materi pembelajaran untuk ditampilkan pada aplikasi.',
                      icon: Icons.book,
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Materi Pembelajaran',
                          style: AppTheme.headingSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kelola dan tambahkan materi pembelajaran baru',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: materiList.length,
                            itemBuilder: (context, index) {
                              final materi = materiList[index];
                              return _buildMateriItem(context, materi);
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
            AppConstants.routeAdminMateriForm,
          ).then((_) => setState(() {
                _materiStream = _firebaseService.getMateri();
              }));
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Materi'),
      ),
    );
  }

  Widget _buildMateriItem(BuildContext context, Materi materi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
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
                  // Gambar Materi
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: materi.gambarUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: materi.gambarUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 100,
                              height: 100,
                              color: AppTheme.primaryColorLight.withOpacity(0.2),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              print("Error loading admin materi image: $error");
                              return Container(
                                width: 100,
                                height: 100,
                                color: AppTheme.primaryColorLight.withOpacity(0.2),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: AppTheme.primaryColorLight,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            color: AppTheme.primaryColorLight.withOpacity(0.2),
                            child: const Icon(
                              Icons.book,
                              color: AppTheme.primaryColorLight,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Info Materi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          materi.judul,
                          style: AppTheme.subtitleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          materi.deskripsi,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Diperbarui: ${_formatDate(materi.updatedAt)}',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.grey,
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
              // Tombol Aksi
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppConstants.routeAdminMateriForm,
                          arguments: materi,
                        ).then((_) => setState(() {
                              _materiStream = _firebaseService.getMateri();
                            }));
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showDeleteConfirmation(context, materi),
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

  void _showDeleteConfirmation(BuildContext context, Materi materi) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus materi "${materi.judul}"? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                _deleteMateri(materi);
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

  Future<void> _deleteMateri(Materi materi) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.deleteMateri(materi.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materi berhasil dihapus'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        setState(() {
          _materiStream = _firebaseService.getMateri();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus materi: ${e.toString()}'),
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