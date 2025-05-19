import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Stream<List<Video>> _videoStream;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _videoStream = _firebaseService.getVideos();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  _isSearching ? '' : 'Video Pembelajaran',
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
                        AppTheme.accentColor,
                        AppTheme.primaryColorDark,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -30,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -20,
                        bottom: -50,
                        child: Container(
                          width: 150,
                          height: 150,
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
                                Icons.play_circle_fill,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Video Edukasi Interaktif',
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
              actions: [
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                      }
                    });
                  },
                ),
              ],
              bottom: _isSearching
                  ? PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Cari video...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                            prefixIcon: const Icon(Icons.search, color: Colors.white),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          ];
        },
        body: StreamBuilder<List<Video>>(
          stream: _videoStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget(
                message: 'Memuat daftar video...',
              );
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

            List<Video> videoList = snapshot.data ?? [];
            
            // Filter video berdasarkan pencarian
            if (_searchQuery.isNotEmpty) {
              videoList = videoList.where((video) {
                return video.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    video.deskripsi.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();
            }

            if (videoList.isEmpty) {
              return EmptyStateWidget(
                title: _searchQuery.isNotEmpty 
                    ? 'Video Tidak Ditemukan' 
                    : 'Belum Ada Video',
                subtitle: _searchQuery.isNotEmpty
                    ? 'Tidak ada video yang sesuai dengan pencarian "${_searchQuery}"'
                    : 'Video pembelajaran belum tersedia saat ini.',
                icon: Icons.video_library,
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isSearching) ...[
                    Text(
                      'Koleksi Video Pembelajaran',
                      style: AppTheme.headingSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tonton video tutorial yang menarik dan edukatif',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Expanded(
                    child: ListView.builder(
                      itemCount: videoList.length,
                      itemBuilder: (context, index) {
                        final video = videoList[index];
                        return _buildVideoCard(context, video);
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

  Widget _buildVideoCard(BuildContext context, Video video) {
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
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppConstants.routeVideoDetail,
              arguments: video,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'video_thumbnail_${video.id}',
                      child: video.thumbnailUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: video.thumbnailUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppTheme.accentColor.withOpacity(0.2),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppTheme.accentColor.withOpacity(0.2),
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              color: AppTheme.accentColor.withOpacity(0.2),
                              child: const Center(
                                child: Icon(
                                  Icons.video_library,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                    ),
                    // Play Button Overlay
                    Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    // Duration tag
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.videocam,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Video',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Video info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.play_circle_filled,
                            color: AppTheme.accentColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
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
                              const SizedBox(height: 4),
                              Text(
                                video.deskripsi,
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
                    Row(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(video.updatedAt),
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              AppConstants.routeVideoDetail,
                              arguments: video,
                            );
                          },
                          icon: const Icon(Icons.play_arrow, size: 16),
                          label: const Text('Tonton Sekarang'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: AppTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
                color: AppTheme.accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: AppTheme.accentColor,
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