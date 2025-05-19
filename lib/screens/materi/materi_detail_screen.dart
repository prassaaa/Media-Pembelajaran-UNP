import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';

class MateriDetailScreen extends StatelessWidget {
  const MateriDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Materi materi = ModalRoute.of(context)!.settings.arguments as Materi;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar dengan gambar materi
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                materi.judul,
                style: AppTheme.subtitleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gambar background
                  materi.gambarUrl.isNotEmpty
                      ? Hero(
                          tag: 'materi_image_${materi.id}',
                          child: CachedNetworkImage(
                            imageUrl: materi.gambarUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppTheme.primaryColorLight.withOpacity(0.3),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) {
                              print("Error loading materi detail image: $error");
                              return Container(
                                color: AppTheme.primaryColor,
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white,
                                    size: 42,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          color: AppTheme.primaryColor,
                          child: const Center(
                            child: Icon(
                              Icons.book,
                              color: Colors.white,
                              size: 64,
                            ),
                          ),
                        ),
                  
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                        stops: const [0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, size: 20),
                ),
                onPressed: () {
                  // Implementasi berbagi materi
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur berbagi belum tersedia'),
                    ),
                  );
                },
              ),
            ],
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              margin: const EdgeInsets.only(top: -30),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Materi Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.menu_book,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Materi Pembelajaran',
                              style: AppTheme.subtitleMedium.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Diperbaharui: ${_formatDate(materi.updatedAt)}',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.secondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Deskripsi Materi
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColorLight.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryColorLight.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deskripsi Materi',
                          style: AppTheme.subtitleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          materi.deskripsi,
                          style: AppTheme.bodyMedium,
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Konten Materi
                  Text(
                    'Konten Materi',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                    child: _buildMateriContent(materi.konten),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Section: Share & Actions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bagikan dan Diskusikan',
                          style: AppTheme.subtitleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Materi ini dapat dibagikan dan didiskusikan dengan teman-teman untuk pembelajaran bersama',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildActionButton(
                              'Bagikan',
                              Icons.share,
                              AppTheme.accentColor,
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fitur berbagi belum tersedia'),
                                  ),
                                );
                              },
                            ),
                            _buildActionButton(
                              'Bookmark',
                              Icons.bookmark_border,
                              AppTheme.primaryColor,
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fitur bookmark belum tersedia'),
                                  ),
                                );
                              },
                            ),
                            _buildActionButton(
                              'Diskusi',
                              Icons.chat_bubble_outline,
                              AppTheme.successColor,
                              () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Fitur diskusi belum tersedia'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 60), // Extra space at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating action button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Implementasi navigasi ke evaluasi terkait
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur evaluasi materi belum tersedia'),
            ),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.quiz),
        label: const Text('Evaluasi'),
      ),
    );
  }

  Widget _buildMateriContent(String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: content.split('\n\n').map((paragraph) {
        if (paragraph.startsWith('# ')) {
          // Heading
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              paragraph.substring(2),
              style: AppTheme.subtitleLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColorDark,
              ),
            ),
          );
        } else if (paragraph.startsWith('## ')) {
          // Subheading
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              paragraph.substring(3),
              style: AppTheme.subtitleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          );
        } else if (paragraph.startsWith('* ')) {
          // Bullet point
          return Padding(
            padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    paragraph.substring(2),
                    style: AppTheme.bodyMedium,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          );
        } else {
          // Regular paragraph
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              paragraph,
              style: AppTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          );
        }
      }).toList(),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
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
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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