import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class AdminVideoScreen extends StatefulWidget {
  const AdminVideoScreen({Key? key}) : super(key: key);

  @override
  State<AdminVideoScreen> createState() => _AdminVideoScreenState();
}

class _AdminVideoScreenState extends State<AdminVideoScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  late Stream<List<Video>> _videoStream;

  @override
  void initState() {
    super.initState();
    _videoStream = _firebaseService.getVideos();
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
              backgroundColor: AppTheme.accentColor,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppConstants.routeAdminVideoForm,
                    ).then((_) => setState(() {
                          _videoStream = _firebaseService.getVideos();
                        }));
                  },
                  icon: const Icon(Icons.add),
                  tooltip: 'Tambah Video',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Kelola Video',
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
                        AppTheme.accentColor,
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
                                Icons.video_library,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kelola Konten Video Pembelajaran',
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
            ? const LoadingWidget(message: 'Memuat data video...')
            : StreamBuilder<List<Video>>(
                stream: _videoStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingWidget(message: 'Memuat data video...');
                  }

                  if (snapshot.hasError) {
                    return AppErrorWidget(
                      message: 'Terjadi kesalahan: ${snapshot.error}',
                      onRetry: () {
                        setState(() {
                          _videoStream = _firebaseService.getVideos();
                        });
                      },
                    );
                  }

                  final List<Video> videoList = snapshot.data ?? [];

                  if (videoList.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'Belum Ada Video',
                      subtitle:
                          'Tambahkan video pembelajaran untuk ditampilkan pada aplikasi.',
                      icon: Icons.video_library,
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar Video Pembelajaran',
                          style: AppTheme.headingSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kelola dan tambahkan video pembelajaran baru',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: videoList.length,
                            itemBuilder: (context, index) {
                              final video = videoList[index];
                              return _buildVideoItem(context, video);
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
            AppConstants.routeAdminVideoForm,
          ).then((_) => setState(() {
                _videoStream = _firebaseService.getVideos();
              }));
        },
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Video'),
      ),
    );
  }

  Widget _buildVideoItem(BuildContext context, Video video) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentColor.withOpacity(0.1),
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
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: video.thumbnailUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: video.thumbnailUrl,
                            width: 120,
                            height: 70,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 120,
                              height: 70,
                              color: AppTheme.accentColor.withOpacity(0.2),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              print("Error loading video thumbnail: $error");
                              return Container(
                                width: 120,
                                height: 70,
                                color: AppTheme.accentColor.withOpacity(0.2),
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: AppTheme.accentColor,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 120,
                            height: 70,
                            color: AppTheme.accentColor.withOpacity(0.2),
                            child: const Icon(
                              Icons.video_library,
                              color: AppTheme.accentColor,
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Info Video
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video.judul,
                          style: AppTheme.subtitleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          video.deskripsi,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.link,
                              size: 14,
                              color: AppTheme.accentColor,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                video.youtubeUrl,
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.accentColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                          AppConstants.routeAdminVideoForm,
                          arguments: video,
                        ).then((_) => setState(() {
                              _videoStream = _firebaseService.getVideos();
                            }));
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showDeleteConfirmation(context, video),
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

  void _showDeleteConfirmation(BuildContext context, Video video) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus video "${video.judul}"? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                _deleteVideo(video);
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

  Future<void> _deleteVideo(Video video) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.deleteVideo(video.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video berhasil dihapus'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        setState(() {
          _videoStream = _firebaseService.getVideos();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus video: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}