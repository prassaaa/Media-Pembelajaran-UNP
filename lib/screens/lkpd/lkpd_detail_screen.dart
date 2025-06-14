// lib/screens/lkpd/lkpd_detail_screen.dart (Update)
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class LkpdDetailScreen extends StatefulWidget {
  const LkpdDetailScreen({Key? key}) : super(key: key);

  @override
  State<LkpdDetailScreen> createState() => _LkpdDetailScreenState();
}

class _LkpdDetailScreenState extends State<LkpdDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  LKPD? _lkpd;
  Map<String, String>? _identitasSiswa;
  int _currentKegiatanIndex = 0;
  final PageController _pageController = PageController();
  final Map<String, TextEditingController> _answerControllers = {};
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      _lkpd = args['kegiatan'] as LKPD;
      _identitasSiswa = Map<String, String>.from(args['identitasSiswa']);
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    if (_lkpd != null) {
      for (final kegiatan in _lkpd!.kegiatanList) {
        for (int i = 0; i < kegiatan.pertanyaanPemandu.length; i++) {
          final key = '${kegiatan.id}_$i';
          _answerControllers[key] = TextEditingController();
        }
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _answerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _nextKegiatan() {
    if (_currentKegiatanIndex < (_lkpd?.kegiatanList.length ?? 0) - 1) {
      setState(() {
        _currentKegiatanIndex++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousKegiatan() {
    if (_currentKegiatanIndex > 0) {
      setState(() {
        _currentKegiatanIndex--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _showCompletionDialog() async {
    // Siapkan data jawaban
    final Map<String, dynamic> jawabanData = {};
    for (final entry in _answerControllers.entries) {
      if (entry.value.text.isNotEmpty) {
        jawabanData[entry.key] = entry.value.text;
      }
    }

    // Simpan hasil ke Firebase
    try {
      setState(() {
        _isLoading = true;
      });

      final hasilSiswa = HasilSiswa(
        id: '${_identitasSiswa!['namaLengkap']}_${_lkpd!.id}_${DateTime.now().millisecondsSinceEpoch}',
        namaLengkap: _identitasSiswa!['namaLengkap']!,
        nomorAbsen: _identitasSiswa!['nomorAbsen']!,
        kelas: _identitasSiswa!['kelas']!,
        jenisKegiatan: 'lkpd',
        kegiatanId: _lkpd!.id,
        judulKegiatan: _lkpd!.judul,
        jawaban: jawabanData,
        tanggalPengerjaan: DateTime.now(),
      );

      await _firebaseService.simpanHasilSiswa(hasilSiswa);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppTheme.successColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('LKPD Selesai!'),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat ${_identitasSiswa!['namaLengkap']}! Anda telah menyelesaikan LKPD "${_lkpd?.judul ?? ''}".',
                    style: AppTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jawaban Anda telah tersimpan:',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Nama: ${_identitasSiswa!['namaLengkap']}\n'
                          '• Absen: ${_identitasSiswa!['nomorAbsen']}\n'
                          '• Kelas: ${_identitasSiswa!['kelas']}\n'
                          '• Hasil akan dievaluasi oleh guru',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Back to LKPD list
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Selesai'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan hasil: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_lkpd == null) {
      return const Scaffold(
        body: LoadingWidget(message: 'Memuat LKPD...'),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        body: LoadingWidget(message: 'Menyimpan hasil LKPD...'),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.orange,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _lkpd!.judul,
                  style: AppTheme.subtitleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_lkpd!.gambarUrl.isNotEmpty)
                      Hero(
                        tag: 'lkpd_image_${_lkpd!.id}',
                        child: CachedNetworkImage(
                          imageUrl: _lkpd!.gambarUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
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
                          ),
                        ),
                      )
                    else
                      Container(
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
                      ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            // Info Siswa
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.orange.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(
                    Icons.person,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_identitasSiswa!['namaLengkap']} - Absen: ${_identitasSiswa!['nomorAbsen']} - Kelas: ${_identitasSiswa!['kelas']}',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Progress Indicator
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kegiatan ${_currentKegiatanIndex + 1} dari ${_lkpd!.kegiatanList.length}',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${((_currentKegiatanIndex + 1) / _lkpd!.kegiatanList.length * 100).round()}%',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (_currentKegiatanIndex + 1) / _lkpd!.kegiatanList.length,
                    backgroundColor: Colors.orange.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentKegiatanIndex = index;
                  });
                },
                itemCount: _lkpd!.kegiatanList.length,
                itemBuilder: (context, index) {
                  final kegiatan = _lkpd!.kegiatanList[index];
                  return _buildKegiatanContent(kegiatan);
                },
              ),
            ),
            
            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentKegiatanIndex > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _previousKegiatan,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Sebelumnya'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (_currentKegiatanIndex > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _currentKegiatanIndex < _lkpd!.kegiatanList.length - 1
                          ? _nextKegiatan
                          : _showCompletionDialog,
                      icon: Icon(
                        _currentKegiatanIndex < _lkpd!.kegiatanList.length - 1
                            ? Icons.arrow_forward
                            : Icons.check_circle,
                      ),
                      label: Text(
                        _currentKegiatanIndex < _lkpd!.kegiatanList.length - 1
                            ? 'Selanjutnya'
                            : 'Selesai',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sisanya sama seperti kode asli, hanya _buildKegiatanContent yang sama
  Widget _buildKegiatanContent(Kegiatan kegiatan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Kegiatan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getKegiatanIcon(kegiatan.type),
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            kegiatan.judul,
                            style: AppTheme.subtitleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  LKPDHelper.getKegiatanTypeText(kegiatan.type),
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '⏱️ ${kegiatan.estimasiWaktu} menit',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.orange.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Instruksi Kegiatan
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Instruksi',
                      style: AppTheme.subtitleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  kegiatan.instruksi,
                  style: AppTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Gambar Kegiatan (jika ada)
          if (kegiatan.gambarUrl != null && kegiatan.gambarUrl!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: kegiatan.gambarUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Pertanyaan Pemandu
          Text(
            'Pertanyaan Pemandu',
            style: AppTheme.subtitleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...kegiatan.pertanyaanPemandu.asMap().entries.map((entry) {
            final index = entry.key;
            final pertanyaan = entry.value;
            final controllerKey = '${kegiatan.id}_$index';
            
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          pertanyaan,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _answerControllers[controllerKey],
                    decoration: InputDecoration(
                      hintText: 'Tulis jawaban Anda di sini...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.orange,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    maxLines: 3,
                    textInputAction: index < kegiatan.pertanyaanPemandu.length - 1
                        ? TextInputAction.next
                        : TextInputAction.done,
                  ),
                ],
              ),
            );
          }).toList(),
          
          const SizedBox(height: 24),
          
          // Tips Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tips Pengerjaan',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getTipsForKegiatanType(kegiatan.type),
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40), // Extra space at bottom
        ],
      ),
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

  String _getTipsForKegiatanType(KegiatanType type) {
    switch (type) {
      case KegiatanType.observasi:
        return '• Amati dengan teliti dan detail\n• Catat hal-hal penting yang Anda lihat\n• Gunakan semua indera Anda dalam mengamati';
      case KegiatanType.analisis:
        return '• Baca dengan cermat materi yang diberikan\n• Identifikasi poin-poin utama\n• Hubungkan dengan pengetahuan yang sudah Anda miliki';
      case KegiatanType.diskusi:
        return '• Sampaikan pendapat dengan jelas\n• Dengarkan pendapat orang lain\n• Berikan alasan untuk setiap pendapat Anda';
      case KegiatanType.eksperimen:
        return '• Ikuti langkah-langkah dengan benar\n• Catat semua hasil pengamatan\n• Jaga keselamatan selama eksperimen';
      case KegiatanType.refleksi:
        return '• Renungkan apa yang telah Anda pelajari\n• Hubungkan dengan pengalaman pribadi\n• Pikirkan bagaimana menerapkannya';
      case KegiatanType.tugasIndividu:
        return '• Kerjakan secara mandiri\n• Manfaatkan sumber belajar yang tersedia\n• Jangan ragu untuk bertanya jika ada kesulitan';
      case KegiatanType.tugasKelompok:
        return '• Bekerja sama dengan baik\n• Bagi tugas secara adil\n• Saling membantu dalam menyelesaikan tugas';
    }
  }
}