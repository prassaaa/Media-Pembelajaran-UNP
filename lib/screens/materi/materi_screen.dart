import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class MateriScreen extends StatefulWidget {
  const MateriScreen({Key? key}) : super(key: key);

  @override
  State<MateriScreen> createState() => _MateriScreenState();
}

class _MateriScreenState extends State<MateriScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Stream<List<Materi>> _materiStream;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _materiStream = _firebaseService.getMateri();
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
              backgroundColor: AppTheme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  _isSearching ? '' : 'Materi Pembelajaran',
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
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        left: -20,
                        bottom: -20,
                        child: Container(
                          width: 120,
                          height: 120,
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
                                'Koleksi Materi Digital',
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
                            hintText: 'Cari materi...',
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
        body: StreamBuilder<List<Materi>>(
          stream: _materiStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingWidget(
                message: 'Memuat daftar materi...',
              );
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

            List<Materi> materiList = snapshot.data ?? [];
            
            // Filter materi berdasarkan pencarian
            if (_searchQuery.isNotEmpty) {
              materiList = materiList.where((materi) {
                return materi.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    materi.deskripsi.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();
            }

            if (materiList.isEmpty) {
              return EmptyStateWidget(
                title: _searchQuery.isNotEmpty 
                    ? 'Materi Tidak Ditemukan' 
                    : 'Belum Ada Materi',
                subtitle: _searchQuery.isNotEmpty
                    ? 'Tidak ada materi yang sesuai dengan pencarian "${_searchQuery}"'
                    : 'Materi pembelajaran belum tersedia saat ini.',
                icon: Icons.book,
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isSearching) ...[
                    Text(
                      'Pilih Materi Pembelajaran',
                      style: AppTheme.headingSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Eksplorasi materi pembelajaran interaktif',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Expanded(
                    child: Column(
                      children: [
                        // Grid untuk materi
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.70,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: materiList.length,
                            itemBuilder: (context, index) {
                              final materi = materiList[index];
                              return _buildMateriCard(context, materi);
                            },
                          ),
                        ),
                        
                        // Section untuk Identitas Pengembang di bagian bawah
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.purple.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.purple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.people_alt_rounded,
                                  color: Colors.purple,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Identitas Pengembang',
                                      style: AppTheme.subtitleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Informasi tentang pembuat aplikasi',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: AppTheme.secondaryTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppConstants.routeIdentitas,
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.purple,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildMateriCard(BuildContext context, Materi materi) {
    return Container(
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
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppConstants.routeMateriDetail,
              arguments: materi,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Materi
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 3/2,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColorLight.withOpacity(0.2),
                      ),
                      child: materi.gambarUrl.isNotEmpty
                          ? Hero(
                              tag: 'materi_image_${materi.id}',
                              child: CachedNetworkImage(
                                imageUrl: materi.gambarUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primaryColor.withOpacity(0.7),
                                    strokeWidth: 2,
                                  ),
                                ),
                                errorWidget: (context, url, error) {
                                  return Container(
                                    color: AppTheme.primaryColorLight.withOpacity(0.2),
                                    child: const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 30,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              color: AppTheme.primaryColorLight.withOpacity(0.2),
                              child: const Center(
                                child: Icon(
                                  Icons.book,
                                  size: 30,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.menu_book,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Materi',
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
              
              // Info Materi
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        materi.judul,
                        style: AppTheme.subtitleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        materi.deskripsi,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 10,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    '${materi.updatedAt.day}/${materi.updatedAt.month}/${materi.updatedAt.year}',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: Colors.grey,
                                      fontSize: 9,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              size: 10,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
      child: SingleChildScrollView(
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: AppTheme.primaryColor,
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