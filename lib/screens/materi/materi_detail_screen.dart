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
      body: Stack(
        children: [
          CustomScrollView(
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
              
              // Empty space for overlay content
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).size.height - 200),
              ),
            ],
          ),
          
          // Content section with rounded top corners
          Positioned(
            top: 220, // Position it to overlap with the SliverAppBar
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  left: 24, 
                  right: 24, 
                  top: 24,
                  bottom: 100, // Extra padding for FAB
                ),
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
                    
                    // Capaian Pembelajaran - Section Baru
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.successColor.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.flag_outlined,
                                color: AppTheme.successColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Capaian Pembelajaran',
                                style: AppTheme.subtitleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.successColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildFormattedContent(materi.capaianPembelajaran, textAlign: TextAlign.left),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tujuan Pembelajaran - Section Baru
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.accentColor.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.track_changes_outlined,
                                color: AppTheme.accentColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tujuan Pembelajaran',
                                style: AppTheme.subtitleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildFormattedContent(materi.tujuanPembelajaran, textAlign: TextAlign.left),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
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
                          Row(
                            children: [
                              Icon(
                                Icons.description,
                                color: AppTheme.primaryColorLight,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Deskripsi Materi',
                                style: AppTheme.subtitleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColorLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildFormattedContent(materi.deskripsi),
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
                        color: AppTheme.warningColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bagikan dan Diskusikan',
                            style: AppTheme.subtitleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
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
                          // Fixed overflow by using SingleChildScrollView with Row
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildActionButton(
                                  'Bagikan',
                                  Icons.share,
                                  Colors.orange,
                                  () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Fitur berbagi belum tersedia'),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 24),
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
                                const SizedBox(width: 24),
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
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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

  // Method untuk membangun konten materi dengan dukungan multiple images
  Widget _buildMateriContent(String content) {
    // Bersihkan dan format konten
    String cleanContent = content.trim();
    if (cleanContent.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.article_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Konten materi belum tersedia',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Split konten berdasarkan paragraf dan image markers
    List<Widget> contentWidgets = [];
    List<String> parts = cleanContent.split('\n');
    
    for (String part in parts) {
      part = part.trim();
      if (part.isEmpty) continue;
      
      // Check for image URL marker
      if (part.startsWith('[IMG_URL:') && part.endsWith(']')) {
        String imageUrl = part.substring(9, part.length - 1); // Remove [IMG_URL: and ]
        contentWidgets.add(_buildContentImage(imageUrl));
        continue;
      }
      
      // Process text content
      Widget? textWidget = _buildTextContent(part);
      if (textWidget != null) {
        contentWidgets.add(textWidget);
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentWidgets,
    );
  }

  // Method untuk membangun widget gambar dalam konten
  Widget _buildContentImage(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) {
                print("Error loading content image: $error");
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gambar tidak dapat dimuat',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'URL: ${imageUrl.length > 50 ? imageUrl.substring(0, 50) + '...' : imageUrl}',
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Tambahan: Caption atau keterangan gambar jika diperlukan
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Gambar Materi Pembelajaran',
              style: AppTheme.bodySmall.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Method untuk membangun widget teks konten
  Widget? _buildTextContent(String paragraph) {
    if (paragraph.isEmpty) return null;
    
    // Heading Level 1 (# )
    if (paragraph.startsWith('# ')) {
      return Container(
        margin: const EdgeInsets.only(top: 20, bottom: 12),
        child: Text(
          paragraph.substring(2).trim(),
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColorDark,
            height: 1.3,
          ),
        ),
      );
    }
    
    // Heading Level 2 (## )
    else if (paragraph.startsWith('## ')) {
      return Container(
        margin: const EdgeInsets.only(top: 16, bottom: 10),
        child: Text(
          paragraph.substring(3).trim(),
          style: AppTheme.subtitleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
            height: 1.3,
          ),
        ),
      );
    }
    
    // Heading Level 3 (### )
    else if (paragraph.startsWith('### ')) {
      return Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        child: Text(
          paragraph.substring(4).trim(),
          style: AppTheme.subtitleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textColor,
            height: 1.3,
          ),
        ),
      );
    }
    
    // Bullet Points (- atau * )
    else if (paragraph.startsWith('- ') || paragraph.startsWith('* ')) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, right: 12, left: 8),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                paragraph.substring(2).trim(),
                style: AppTheme.bodyMedium.copyWith(
                  height: 1.5,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ],
        ),
      );
    }
    
    // Numbered Lists (1. 2. etc.)
    else if (RegExp(r'^\d+\.\s').hasMatch(paragraph)) {
      var match = RegExp(r'^(\d+)\.\s(.*)').firstMatch(paragraph);
      if (match != null) {
        String number = match.group(1)!;
        String text = match.group(2)!;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 12, left: 8),
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: AppTheme.bodyMedium.copyWith(
                    height: 1.5,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
        );
      }
    }
    
    // Quote/Important text (> )
    else if (paragraph.startsWith('> ')) {
      return Container(
        margin: const EdgeInsets.only(top: 12, bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            left: BorderSide(
              color: AppTheme.primaryColor,
              width: 4,
            ),
          ),
        ),
        child: Text(
          paragraph.substring(2).trim(),
          style: AppTheme.bodyMedium.copyWith(
            fontStyle: FontStyle.italic,
            color: AppTheme.primaryColorDark,
            height: 1.5,
          ),
          textAlign: TextAlign.justify,
        ),
      );
    }
    
    // Bold text (**text**)
    else if (paragraph.contains('**')) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: _buildRichTextJustified(paragraph),
      );
    }
    
    // Regular paragraph
    else {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Text(
          paragraph,
          style: AppTheme.bodyMedium.copyWith(
            height: 1.5,
            color: AppTheme.textColor,
          ),
          textAlign: TextAlign.justify,
        ),
      );
    }
    
    return null;
  }

  // Method untuk memformat konten yang lebih ringkas (untuk capaian, tujuan, deskripsi)
  Widget _buildFormattedContent(String content, {TextAlign textAlign = TextAlign.justify}) {
    // Bersihkan dan format konten
    String cleanContent = content.trim();
    if (cleanContent.isEmpty) {
      return Text(
        'Konten belum tersedia',
        style: AppTheme.bodyMedium.copyWith(
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
        textAlign: textAlign,
      );
    }

    // Split konten berdasarkan baris
    List<String> lines = cleanContent.split('\n').where((line) => line.trim().isNotEmpty).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map<Widget>((line) {
        line = line.trim();
        
        if (line.isEmpty) return const SizedBox.shrink();
        
        // Numbered Lists (1. 2. etc.)
        if (RegExp(r'^\d+\.\s').hasMatch(line)) {
          var match = RegExp(r'^(\d+)\.\s(.*)').firstMatch(line);
          if (match != null) {
            String number = match.group(1)!;
            String text = match.group(2)!;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        number,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      text,
                      style: AppTheme.bodyMedium.copyWith(
                        height: 1.5,
                      ),
                      textAlign: textAlign,
                    ),
                  ),
                ],
              ),
            );
          }
        }
        
        // Bullet Points (- atau * )
        else if (line.startsWith('- ') || line.startsWith('* ')) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, right: 12),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(2).trim(),
                    style: AppTheme.bodyMedium.copyWith(
                      height: 1.5,
                    ),
                    textAlign: textAlign,
                  ),
                ),
              ],
            ),
          );
        }
        
        // Bold text (**text**)
        else if (line.contains('**')) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: _buildRichTextJustified(line, textAlign: textAlign),
          );
        }
        
        // Regular text
        else {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Text(
              line,
              style: AppTheme.bodyMedium.copyWith(
                height: 1.5,
              ),
              textAlign: textAlign,
            ),
          );
        }
        
        return const SizedBox.shrink();
      }).toList(),
    );
  }

  Widget _buildRichTextJustified(String text, {TextAlign textAlign = TextAlign.justify}) {
    List<TextSpan> spans = [];
    List<String> parts = text.split('**');
    
    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // Regular text
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(
            text: parts[i],
            style: AppTheme.bodyMedium.copyWith(
              height: 1.5,
            ),
          ));
        }
      } else {
        // Bold text
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(
            text: parts[i],
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          ));
        }
      }
    }
    
    return RichText(
      textAlign: textAlign,
      text: TextSpan(children: spans),
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
          mainAxisSize: MainAxisSize.min,
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
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}