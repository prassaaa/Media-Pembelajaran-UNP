import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class AdminLkpdScreen extends StatefulWidget {
  const AdminLkpdScreen({Key? key}) : super(key: key);

  @override
  State<AdminLkpdScreen> createState() => _AdminLkpdScreenState();
}

class _AdminLkpdScreenState extends State<AdminLkpdScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  late Stream<List<LKPD>> _lkpdStream;

  @override
  void initState() {
    super.initState();
    _lkpdStream = _firebaseService.getLKPD();
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
              backgroundColor: Colors.orange,
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppConstants.routeAdminLkpdForm,
                    ).then((_) => setState(() {
                          _lkpdStream = _firebaseService.getLKPD();
                        }));
                  },
                  icon: const Icon(Icons.add),
                  tooltip: 'Tambah LKPD',
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Kelola LKPD',
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
                        Colors.orange,
                        Colors.orange.shade800,
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
                                Icons.assignment_outlined,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kelola Lembar Kerja Peserta Didik',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 50),
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
            ? const LoadingWidget(message: 'Memuat data LKPD...')
            : StreamBuilder<List<LKPD>>(
                stream: _lkpdStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingWidget(message: 'Memuat data LKPD...');
                  }

                  if (snapshot.hasError) {
                    return _AppErrorWidget(
                      message: 'Terjadi kesalahan: ${snapshot.error}',
                      onRetry: () {
                        setState(() {
                          _lkpdStream = _firebaseService.getLKPD();
                        });
                      },
                    );
                  }

                  final List<LKPD> lkpdList = snapshot.data ?? [];

                  if (lkpdList.isEmpty) {
                    return const _EmptyStateWidget(
                      title: 'Belum Ada LKPD',
                      subtitle: 'Tambahkan LKPD untuk ditampilkan pada aplikasi.',
                      icon: Icons.assignment_outlined,
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daftar LKPD',
                          style: AppTheme.headingSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                         'Kelola dan tambahkan LKPD baru',
                         style: AppTheme.bodyMedium.copyWith(
                           color: AppTheme.secondaryTextColor,
                         ),
                       ),
                       const SizedBox(height: 24),
                       Expanded(
                         child: ListView.builder(
                           padding: const EdgeInsets.only(bottom: 80),
                           itemCount: lkpdList.length,
                           itemBuilder: (context, index) {
                             final lkpd = lkpdList[index];
                             return _buildLkpdItem(context, lkpd);
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
           AppConstants.routeAdminLkpdForm,
         ).then((_) => setState(() {
               _lkpdStream = _firebaseService.getLKPD();
             }));
       },
       backgroundColor: Colors.orange,
       icon: const Icon(Icons.add),
       label: const Text('Tambah LKPD'),
     ),
   );
 }

 Widget _buildLkpdItem(BuildContext context, LKPD lkpd) {
   return Container(
     margin: const EdgeInsets.only(bottom: 16),
     decoration: BoxDecoration(
       borderRadius: BorderRadius.circular(16),
       boxShadow: [
         BoxShadow(
           color: Colors.orange.withOpacity(0.1),
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
                 // Gambar LKPD
                 ClipRRect(
                   borderRadius: BorderRadius.circular(12),
                   child: lkpd.gambarUrl.isNotEmpty
                       ? CachedNetworkImage(
                           imageUrl: lkpd.gambarUrl,
                           width: 100,
                           height: 100,
                           fit: BoxFit.cover,
                           placeholder: (context, url) => Container(
                             width: 100,
                             height: 100,
                             color: Colors.orange.withOpacity(0.2),
                             child: const Center(
                               child: CircularProgressIndicator(),
                             ),
                           ),
                           errorWidget: (context, url, error) {
                             return Container(
                               width: 100,
                               height: 100,
                               color: Colors.orange.withOpacity(0.2),
                               child: const Icon(
                                 Icons.image_not_supported,
                                 color: Colors.orange,
                               ),
                             );
                           },
                         )
                       : Container(
                           width: 100,
                           height: 100,
                           color: Colors.orange.withOpacity(0.2),
                           child: const Icon(
                             Icons.assignment_outlined,
                             color: Colors.orange,
                           ),
                         ),
                 ),
                 const SizedBox(width: 16),
                 // Info LKPD
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         lkpd.judul,
                         style: AppTheme.subtitleLarge.copyWith(
                           fontWeight: FontWeight.bold,
                         ),
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                       ),
                       const SizedBox(height: 8),
                       Text(
                         lkpd.deskripsi,
                         style: AppTheme.bodyMedium.copyWith(
                           color: AppTheme.secondaryTextColor,
                         ),
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                       ),
                       const SizedBox(height: 8),
                       // Stats Row
                       Wrap(
                         spacing: 16,
                         runSpacing: 8,
                         children: [
                           _buildStatChip(
                             '${lkpd.kegiatanList.length} Kegiatan',
                             Icons.assignment_turned_in,
                           ),
                           _buildStatChip(
                             LKPDHelper.getTotalEstimasiWaktu(lkpd.kegiatanList),
                             Icons.timer,
                           ),
                           _buildStatChip(
                             LKPDHelper.getDifficultyLevel(lkpd.kegiatanList.length),
                             Icons.fitness_center,
                           ),
                         ],
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
                             'Diperbarui: ${_formatDate(lkpd.updatedAt)}',
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
             
             // Kegiatan Preview
             if (lkpd.kegiatanList.isNotEmpty) ...[
               Text(
                 'Kegiatan dalam LKPD:',
                 style: AppTheme.bodyMedium.copyWith(
                   fontWeight: FontWeight.bold,
                 ),
               ),
               const SizedBox(height: 8),
               SingleChildScrollView(
                 scrollDirection: Axis.horizontal,
                 child: Row(
                   children: lkpd.kegiatanList.map((kegiatan) => 
                     Container(
                       margin: const EdgeInsets.only(right: 8),
                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                       decoration: BoxDecoration(
                         color: Colors.orange.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(20),
                         border: Border.all(
                           color: Colors.orange.withOpacity(0.3),
                         ),
                       ),
                       child: Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Icon(
                             _getKegiatanIcon(kegiatan.type),
                             size: 14,
                             color: Colors.orange.shade800,
                           ),
                           const SizedBox(width: 4),
                           Text(
                             kegiatan.judul,
                             style: AppTheme.bodySmall.copyWith(
                               color: Colors.orange.shade800,
                               fontWeight: FontWeight.w500,
                             ),
                           ),
                         ],
                       ),
                     ),
                   ).toList(),
                 ),
               ),
               const SizedBox(height: 16),
             ],
             
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
                         AppConstants.routeAdminLkpdForm,
                         arguments: lkpd,
                       ).then((_) => setState(() {
                             _lkpdStream = _firebaseService.getLKPD();
                           }));
                     },
                     icon: const Icon(Icons.edit),
                     label: const Text('Edit'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.orange,
                       foregroundColor: Colors.white,
                       padding: const EdgeInsets.symmetric(vertical: 12),
                     ),
                   ),
                 ),
                 const SizedBox(width: 8),
                 Expanded(
                   child: ElevatedButton.icon(
                     onPressed: () => _showDeleteConfirmation(context, lkpd),
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

 Widget _buildStatChip(String text, IconData icon) {
   return Row(
     mainAxisSize: MainAxisSize.min,
     children: [
       Icon(
         icon,
         size: 14,
         color: Colors.orange,
       ),
       const SizedBox(width: 4),
       Text(
         text,
         style: AppTheme.bodySmall.copyWith(
           color: Colors.orange.shade800,
           fontWeight: FontWeight.w500,
         ),
       ),
     ],
   );
 }

 IconData _getKegiatanIcon(KegiatanType type) {
   switch (type) {
     case KegiatanType.observasi:
       return Icons.visibility;
     case KegiatanType.analisis:
       return Icons.analytics;
     case KegiatanType.diskusi:
       return Icons.forum;
     case KegiatanType.eksperimen:
       return Icons.science;
     case KegiatanType.refleksi:
       return Icons.psychology;
     case KegiatanType.tugasIndividu:
       return Icons.person;
     case KegiatanType.tugasKelompok:
       return Icons.group;
   }
 }

 void _showDeleteConfirmation(BuildContext context, LKPD lkpd) {
   showDialog(
     context: context,
     builder: (BuildContext context) {
       return AlertDialog(
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(16),
         ),
         title: const Text('Konfirmasi Hapus'),
         content: Text(
           'Apakah Anda yakin ingin menghapus LKPD "${lkpd.judul}"? Tindakan ini tidak dapat dibatalkan.',
         ),
         actions: [
           TextButton(
             onPressed: () => Navigator.pop(context),
             child: const Text('Batal'),
           ),
           ElevatedButton(
             onPressed: () async {
               Navigator.pop(context);
               _deleteLkpd(lkpd);
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

 Future<void> _deleteLkpd(LKPD lkpd) async {
   setState(() {
     _isLoading = true;
   });

   try {
     await _firebaseService.deleteLKPD(lkpd.id);
     
     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(
           content: Text('LKPD berhasil dihapus'),
           backgroundColor: AppTheme.successColor,
         ),
       );
       setState(() {
         _lkpdStream = _firebaseService.getLKPD();
         _isLoading = false;
       });
     }
   } catch (e) {
     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text('Gagal menghapus LKPD: ${e.toString()}'),
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

// Helper Widgets
class _AppErrorWidget extends StatelessWidget {
 final String message;
 final VoidCallback onRetry;

 const _AppErrorWidget({
   required this.message,
   required this.onRetry,
 });

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
             ),
           ),
         ],
       ),
     ),
   );
 }
}

class _EmptyStateWidget extends StatelessWidget {
 final String title;
 final String subtitle;
 final IconData icon;

 const _EmptyStateWidget({
   required this.title,
   required this.subtitle,
   required this.icon,
 });

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
               color: Colors.orange.withOpacity(0.1),
               shape: BoxShape.circle,
             ),
             child: Icon(
               icon,
               size: 60,
               color: Colors.orange,
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