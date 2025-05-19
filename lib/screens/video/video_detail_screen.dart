import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';

class VideoDetailScreen extends StatefulWidget {
  const VideoDetailScreen({Key? key}) : super(key: key);

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isFullScreen = false;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_isInitialized) {
      final Video video = ModalRoute.of(context)!.settings.arguments as Video;
      final videoId = YoutubePlayer.convertUrlToId(video.youtubeUrl);

      if (videoId != null) {
        _controller = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            captionLanguage: 'id',
            enableCaption: true,
          ),
        )..addListener(_controllerListener);
      }
      
      _isInitialized = true;
    }
  }

  void _controllerListener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _isFullScreen = false;
      });
    }

    if (_controller.value.isFullScreen) {
      setState(() {
        _isFullScreen = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Video video = ModalRoute.of(context)!.settings.arguments as Video;
    final videoId = YoutubePlayer.convertUrlToId(video.youtubeUrl);

    if (videoId == null) {
      // Invalid YouTube URL
      return Scaffold(
        appBar: AppBar(
          title: const Text('Video Pembelajaran'),
        ),
        body: const AppErrorWidget(
          message: 'URL YouTube tidak valid atau tidak dapat diputar.',
        ),
      );
    }

    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppTheme.accentColor,
        progressColors: const ProgressBarColors(
          playedColor: AppTheme.accentColor,
          handleColor: AppTheme.primaryColorDark,
        ),
        onReady: () {
          setState(() {
            _isPlayerReady = true;
          });
        },
        bottomActions: [
          CurrentPosition(),
          const SizedBox(width: 10),
          ProgressBar(
            isExpanded: true,
            colors: const ProgressBarColors(
              playedColor: AppTheme.accentColor,
              handleColor: AppTheme.primaryColorDark,
            ),
          ),
          const SizedBox(width: 10),
          RemainingDuration(),
          FullScreenButton(),
        ],
      ),
      builder: (context, player) {
        return Scaffold(
          body: _isFullScreen
              ? player
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 0,
                      pinned: true,
                      backgroundColor: Colors.black,
                      title: Text(
                        'Video Pembelajaran',
                        style: AppTheme.subtitleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Player
                          player,

                          // Video Info
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Judul dan Info
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.accentColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Thumbnail kecil
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Hero(
                                              tag: 'video_thumbnail_${video.id}',
                                              child: SizedBox(
                                                width: 80,
                                                height: 45,
                                                child: video.thumbnailUrl.isNotEmpty
                                                    ? CachedNetworkImage(
                                                        imageUrl: video.thumbnailUrl,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) => Container(
                                                          color: AppTheme.accentColor.withOpacity(0.2),
                                                        ),
                                                        errorWidget: (context, url, error) => Container(
                                                          color: AppTheme.accentColor.withOpacity(0.2),
                                                          child: const Center(
                                                            child: Icon(
                                                              Icons.broken_image,
                                                              color: Colors.white,
                                                              size: 24,
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
                                                            size: 24,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  video.judul,
                                                  style: AppTheme.subtitleLarge.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Dipublikasikan: ${_formatDate(video.createdAt)}',
                                                  style: AppTheme.bodySmall.copyWith(
                                                    color: AppTheme.secondaryTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Video controls section
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildControlButton(
                                            'Putar',
                                            Icons.play_arrow,
                                            () {
                                              if (_isPlayerReady) {
                                                _controller.play();
                                              }
                                            },
                                          ),
                                          _buildControlButton(
                                            'Jeda',
                                            Icons.pause,
                                            () {
                                              if (_isPlayerReady) {
                                                _controller.pause();
                                              }
                                            },
                                          ),
                                          _buildControlButton(
                                            'Ulang',
                                            Icons.replay,
                                            () {
                                              if (_isPlayerReady) {
                                                _controller.seekTo(Duration.zero);
                                                _controller.play();
                                              }
                                            },
                                          ),
                                          _buildControlButton(
                                            'Layar Penuh',
                                            Icons.fullscreen,
                                            () {
                                              if (_isPlayerReady) {
                                                _controller.toggleFullScreenMode();
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Deskripsi
                                Text(
                                  'Tentang Video Ini',
                                  style: AppTheme.headingSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Description content
                                      Text(
                                        video.deskripsi,
                                        style: AppTheme.bodyMedium,
                                        textAlign: TextAlign.justify,
                                      ),
                                      const SizedBox(height: 16),
                                      // Tags
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _buildTag('Pendidikan'),
                                          _buildTag('Video Tutorial'),
                                          _buildTag('Pembelajaran Digital'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // Actions
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.accentColor.withOpacity(0.1),
                                        AppTheme.primaryColor.withOpacity(0.1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Bagikan Video Ini',
                                        style: AppTheme.subtitleMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Video ini dapat dibagikan dengan teman-teman Anda untuk pembelajaran bersama',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: AppTheme.secondaryTextColor,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildShareButton(
                                            'WhatsApp',
                                            Icons.message, // Menggunakan Icons.message sebagai pengganti Icons.whatsapp
                                            Colors.green,
                                            () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Fitur berbagi belum tersedia'),
                                                ),
                                              );
                                            },
                                          ),
                                          _buildShareButton(
                                            'Facebook',
                                            Icons.facebook,
                                            Colors.blue,
                                            () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Fitur berbagi belum tersedia'),
                                                ),
                                              );
                                            },
                                          ),
                                          _buildShareButton(
                                            'Email',
                                            Icons.email,
                                            Colors.red,
                                            () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Fitur berbagi belum tersedia'),
                                                ),
                                              );
                                            },
                                          ),
                                          _buildShareButton(
                                            'Copy Link',
                                            Icons.link,
                                            Colors.grey,
                                            () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Link berhasil disalin'),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Spacing
                                const SizedBox(height: 24),
                                
                                // Related Videos (placeholder)
                                Text(
                                  'Video Terkait',
                                  style: AppTheme.headingSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        const Icon(
                                          Icons.video_library,
                                          color: Colors.grey,
                                          size: 48,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Video terkait belum tersedia',
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 60), // Extra space at bottom
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
          floatingActionButton: _isFullScreen ? null : FloatingActionButton.extended(
            onPressed: () {
              // Implementasi navigasi ke evaluasi terkait
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur evaluasi video belum tersedia'),
                ),
              );
            },
            backgroundColor: AppTheme.accentColor,
            icon: const Icon(Icons.quiz),
            label: const Text('Evaluasi'),
          ),
        );
      },
    );
  }

  Widget _buildControlButton(String label, IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: AppTheme.bodySmall.copyWith(
          color: AppTheme.accentColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class AppErrorWidget extends StatelessWidget {
  final String message;

  const AppErrorWidget({
    Key? key,
    required this.message,
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
                color: AppTheme.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
            ),
            const SizedBox(height: 24),
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
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
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