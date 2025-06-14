import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';
import 'package:intl/intl.dart';

class AdminHasilSiswaScreen extends StatefulWidget {
  const AdminHasilSiswaScreen({Key? key}) : super(key: key);

  @override
  State<AdminHasilSiswaScreen> createState() => _AdminHasilSiswaScreenState();
}

class _AdminHasilSiswaScreenState extends State<AdminHasilSiswaScreen> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late TabController _tabController;
  
  List<HasilSiswa> _hasilLKPD = [];
  List<HasilSiswa> _hasilEvaluasi = [];
  List<String> _kelasList = [];
  String? _selectedKelas;
  bool _isLoading = true;

  // Cache untuk menyimpan detail LKPD
  Map<String, LKPD> _lkpdCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hasilLKPD = await _firebaseService.getHasilSiswa(jenisKegiatan: 'lkpd');
      final hasilEvaluasi = await _firebaseService.getHasilSiswa(jenisKegiatan: 'evaluasi');
      final kelasList = await _firebaseService.getKelasList();

      setState(() {
        _hasilLKPD = hasilLKPD;
        _hasilEvaluasi = hasilEvaluasi;
        _kelasList = kelasList;
        _isLoading = false;
      });

      // Load LKPD details untuk cache
      await _loadLKPDDetails();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _loadLKPDDetails() async {
    try {
      // Ambil semua LKPD untuk cache
      final lkpdList = await _firebaseService.getLKPDList();
      for (final lkpd in lkpdList) {
        _lkpdCache[lkpd.id] = lkpd;
      }
    } catch (e) {
      print('Error loading LKPD details: $e');
    }
  }

  Future<void> _filterByKelas(String? kelas) async {
    setState(() {
      _selectedKelas = kelas;
      _isLoading = true;
    });

    try {
      final hasilLKPD = await _firebaseService.getHasilSiswa(jenisKegiatan: 'lkpd', kelas: kelas);
      final hasilEvaluasi = await _firebaseService.getHasilSiswa(jenisKegiatan: 'evaluasi', kelas: kelas);

      setState(() {
        _hasilLKPD = hasilLKPD;
        _hasilEvaluasi = hasilEvaluasi;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primaryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Hasil Siswa',
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
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Center(
                        child: Icon(
                          Icons.analytics,
                          size: 64,
                          color: Colors.white.withOpacity(0.3),
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
            ? const LoadingWidget(message: 'Memuat data hasil siswa...')
            : Column(
                children: [
                  // Filter Kelas
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.filter_list,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filter Kelas:',
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedKelas,
                                hint: Text(
                                  'Semua Kelas',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                isExpanded: true,
                                dropdownColor: Colors.white,
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.black,
                                ),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: AppTheme.primaryColor,
                                ),
                                items: [
                                  DropdownMenuItem<String>(
                                    value: null,
                                    child: Text(
                                      'Semua Kelas',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  ..._kelasList.map((kelas) => DropdownMenuItem<String>(
                                    value: kelas,
                                    child: Text(
                                      kelas,
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                  )),
                                ],
                                onChanged: _filterByKelas,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _loadData,
                          icon: const Icon(
                            Icons.refresh,
                            color: AppTheme.primaryColor,
                          ),
                          tooltip: 'Refresh Data',
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: AppTheme.primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: AppTheme.primaryColor,
                      tabs: [
                        Tab(
                          icon: const Icon(Icons.assignment_outlined),
                          text: 'LKPD (${_hasilLKPD.length})',
                        ),
                        Tab(
                          icon: const Icon(Icons.quiz),
                          text: 'Evaluasi (${_hasilEvaluasi.length})',
                        ),
                      ],
                    ),
                  ),

                  // Tab View
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildHasilList(_hasilLKPD, 'lkpd'),
                        _buildHasilList(_hasilEvaluasi, 'evaluasi'),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHasilList(List<HasilSiswa> hasilList, String jenisKegiatan) {
    if (hasilList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              jenisKegiatan == 'lkpd' ? Icons.assignment_outlined : Icons.quiz,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada hasil ${jenisKegiatan.toUpperCase()}',
              style: AppTheme.subtitleLarge.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedKelas != null 
                  ? 'untuk kelas $_selectedKelas'
                  : 'dari siswa',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    // Group by kegiatan
    final Map<String, List<HasilSiswa>> groupedResults = {};
    for (final hasil in hasilList) {
      final key = hasil.judulKegiatan;
      if (!groupedResults.containsKey(key)) {
        groupedResults[key] = [];
      }
      groupedResults[key]!.add(hasil);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedResults.keys.length,
      itemBuilder: (context, index) {
        final judulKegiatan = groupedResults.keys.elementAt(index);
        final hasilKegiatan = groupedResults[judulKegiatan]!;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                jenisKegiatan == 'lkpd' ? Icons.assignment_outlined : Icons.quiz,
                color: jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor,
              ),
            ),
            title: Text(
              judulKegiatan,
              style: AppTheme.subtitleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${hasilKegiatan.length} siswa telah mengerjakan',
                  style: AppTheme.bodySmall,
                ),
                if (jenisKegiatan == 'evaluasi') ...[
                  const SizedBox(height: 4),
                  Text(
                    'Rata-rata nilai: ${_calculateAverageScore(hasilKegiatan).toStringAsFixed(1)}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: hasilKegiatan.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final hasil = hasilKegiatan[index];
                  return _buildHasilItem(hasil, jenisKegiatan);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHasilItem(HasilSiswa hasil, String jenisKegiatan) {
    return InkWell(
      onTap: () => _showDetailDialog(hasil, jenisKegiatan),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              backgroundColor: (jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor).withOpacity(0.1),
              child: Text(
                hasil.namaLengkap.substring(0, 1).toUpperCase(),
                style: AppTheme.subtitleMedium.copyWith(
                  color: jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Info Siswa
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasil.namaLengkap,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Absen: ${hasil.nomorAbsen}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Kelas: ${hasil.kelas}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(hasil.tanggalPengerjaan),
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            // Score untuk evaluasi
            if (jenisKegiatan == 'evaluasi' && hasil.nilaiEvaluasi != null) ...[
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getScoreColor(hasil.nilaiEvaluasi!.toDouble()),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${hasil.nilaiEvaluasi}',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${hasil.jumlahBenar}/${hasil.totalSoal}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Selesai',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDialog(HasilSiswa hasil, String jenisKegiatan) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(
            maxHeight: 700,
            maxWidth: 600,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: jenisKegiatan == 'lkpd' ? Colors.orange : AppTheme.successColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      jenisKegiatan == 'lkpd' ? Icons.assignment_outlined : Icons.quiz,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail ${jenisKegiatan.toUpperCase()}',
                            style: AppTheme.subtitleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            hasil.judulKegiatan,
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Info Siswa
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Siswa',
                              style: AppTheme.subtitleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Nama: ${hasil.namaLengkap}'),
                            Text('Absen: ${hasil.nomorAbsen}'),
                            Text('Kelas: ${hasil.kelas}'),
                            Text('Tanggal: ${DateFormat('dd MMMM yyyy, HH:mm').format(hasil.tanggalPengerjaan)}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Hasil Evaluasi
                      if (jenisKegiatan == 'evaluasi' && hasil.nilaiEvaluasi != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getScoreColor(hasil.nilaiEvaluasi!.toDouble()).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _getScoreColor(hasil.nilaiEvaluasi!.toDouble()).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hasil Evaluasi',
                                style: AppTheme.subtitleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Nilai: ${hasil.nilaiEvaluasi}'),
                                  Text('Benar: ${hasil.jumlahBenar}/${hasil.totalSoal}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Detail Jawaban
                      Text(
                        'Detail Jawaban',
                        style: AppTheme.subtitleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      if (jenisKegiatan == 'lkpd') 
                        _buildLKPDAnswers(hasil.jawaban, hasil.kegiatanId)
                      else 
                        _buildEvaluasiAnswers(hasil.jawaban),
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

  Widget _buildLKPDAnswers(Map<String, dynamic> jawaban, String? kegiatanId) {
    if (jawaban.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Tidak ada jawaban yang tersimpan',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    // Ambil data LKPD dari cache
    LKPD? lkpdData = kegiatanId != null ? _lkpdCache[kegiatanId] : null;

    // Group jawaban berdasarkan kegiatan
    Map<String, Map<String, dynamic>> groupedAnswers = {};
    
    for (var entry in jawaban.entries) {
      String key = entry.key;
      dynamic value = entry.value;
      
      // Parse key format: "kegiatanId_pertanyaanIndex"
      List<String> keyParts = key.split('_');
      
      if (keyParts.length >= 2) {
        String kegiatanKey = keyParts.sublist(0, keyParts.length - 1).join('_');
        String pertanyaanIndex = keyParts.last;
        
        if (!groupedAnswers.containsKey(kegiatanKey)) {
          groupedAnswers[kegiatanKey] = {};
        }
        
        groupedAnswers[kegiatanKey]![pertanyaanIndex] = value;
      }
    }

    return Column(
      children: groupedAnswers.entries.map((kegiatanEntry) {
        String kegiatanKey = kegiatanEntry.key;
        Map<String, dynamic> pertanyaanAnswers = kegiatanEntry.value;

        // Cari kegiatan dari data LKPD
        Kegiatan? kegiatanData;
        if (lkpdData != null) {
          try {
            kegiatanData = lkpdData.kegiatanList.firstWhere(
              (k) => k.id == kegiatanKey || k.judul.toLowerCase().replaceAll(' ', '_') == kegiatanKey.toLowerCase(),
              orElse: () => throw StateError('Not found')
            );
          } catch (e) {
            // Jika tidak ditemukan berdasarkan ID, coba cari berdasarkan kesamaan nama
            for (var kegiatan in lkpdData.kegiatanList) {
              if (kegiatanKey.toLowerCase().contains(kegiatan.judul.toLowerCase().replaceAll(' ', '_'))) {
                kegiatanData = kegiatan;
                break;
              }
            }
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
            color: Colors.orange.withOpacity(0.02),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Kegiatan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.orange.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getKegiatanIcon(kegiatanData?.type),
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
                            kegiatanData?.judul ?? kegiatanKey,
                            style: AppTheme.subtitleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade800,
                            ),
                          ),
                          if (kegiatanData != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${LKPDHelper.getKegiatanTypeText(kegiatanData.type)} • ${kegiatanData.estimasiWaktu} menit',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.orange.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Instruksi Kegiatan
              if (kegiatanData != null && kegiatanData.instruksi.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 16,
                            color: Colors.orange.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Instruksi Kegiatan:',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withOpacity(0.1)),
                        ),
                        child: Text(
                          kegiatanData.instruksi,
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Gambar Kegiatan
              if (kegiatanData != null && 
                  ((kegiatanData.gambarUrl != null && kegiatanData.gambarUrl!.isNotEmpty) ||
                    kegiatanData.gambarFile != null)) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 16,
                            color: Colors.orange.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Gambar Kegiatan:',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: kegiatanData.gambarFile != null
                            ? Image.file(
                                kegiatanData.gambarFile!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                kegiatanData.gambarUrl!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                          size: 48,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Gambar tidak dapat dimuat',
                                          style: AppTheme.bodySmall.copyWith(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],

              // Pertanyaan dan Jawaban
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pertanyaan dan Jawaban:',
                      style: AppTheme.subtitleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Sort pertanyaan berdasarkan index
                    ...pertanyaanAnswers.entries.toList()
                      .asMap().entries.map((indexedEntry) {
                      // int entryIndex = indexedEntry.key;  // Removed unused variable
                      MapEntry<String, dynamic> pertanyaanEntry = indexedEntry.value;
                      String pertanyaanIndex = pertanyaanEntry.key;
                      String answer = pertanyaanEntry.value.toString();
                      int questionNumber = (int.tryParse(pertanyaanIndex) ?? 0) + 1;
                      
                      // Ambil pertanyaan dari data kegiatan
                      String pertanyaanText = '';
                      if (kegiatanData != null && 
                          kegiatanData.pertanyaanPemandu.isNotEmpty) {
                        int index = int.tryParse(pertanyaanIndex) ?? 0;
                        if (index < kegiatanData.pertanyaanPemandu.length) {
                          pertanyaanText = kegiatanData.pertanyaanPemandu[index];
                        }
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.2)),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Pertanyaan
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.blue.withOpacity(0.2),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$questionNumber',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Pertanyaan $questionNumber',
                                      style: AppTheme.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                  // Indikator ada gambar dalam jawaban
                                  if (answer.toLowerCase().contains('gambar') || 
                                      answer.toLowerCase().contains('image') ||
                                      answer.toLowerCase().contains('foto')) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.image,
                                            size: 12,
                                            color: Colors.purple.shade700,
                                          ),
                                          const SizedBox(width: 2),
                                          Text(
                                            'Ada Gambar',
                                            style: AppTheme.bodySmall.copyWith(
                                              fontSize: 10,
                                              color: Colors.purple.shade700,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Isi Pertanyaan
                            if (pertanyaanText.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.help_outline,
                                          size: 16,
                                          color: Colors.blue.shade600,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Pertanyaan:',
                                          style: AppTheme.bodyMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.blue.withOpacity(0.1)),
                                      ),
                                      child: Text(
                                        pertanyaanText,
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            // Jawaban Siswa
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.edit_note,
                                        color: Colors.green.shade600,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Jawaban Siswa:',
                                        style: AppTheme.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: answer.isEmpty 
                                          ? Colors.red.withOpacity(0.05)
                                          : Colors.green.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: answer.isEmpty 
                                            ? Colors.red.withOpacity(0.2)
                                            : Colors.green.withOpacity(0.2)
                                      ),
                                    ),
                                    child: answer.isEmpty
                                        ? Row(
                                            children: [
                                              Icon(
                                                Icons.warning_amber_outlined,
                                                color: Colors.red,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Tidak ada jawaban',
                                                style: AppTheme.bodyMedium.copyWith(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
                                            answer,
                                            style: AppTheme.bodyMedium.copyWith(
                                              color: Colors.black87,
                                            ),
                                          ),
                                  ),
                                  
                                  // Info statistik jawaban
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.text_fields,
                                              size: 14,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Panjang: ${answer.length} karakter',
                                              style: AppTheme.bodySmall.copyWith(
                                                color: Colors.grey[600],
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (answer.split(' ').length > 1) ...[
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.format_list_numbered,
                                                size: 14,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${answer.split(' ').length} kata',
                                                style: AppTheme.bodySmall.copyWith(
                                                  color: Colors.grey[600],
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getKegiatanIcon(KegiatanType? type) {
    switch (type) {
      case KegiatanType.observasi:
        return Icons.visibility;
      case KegiatanType.eksperimen:
        return Icons.science;
      case KegiatanType.diskusi:
        return Icons.group;
      case KegiatanType.analisis:
        return Icons.analytics;
      case KegiatanType.refleksi:  // Fixed: changed from 'presentasi' to 'refleksi'
        return Icons.self_improvement;
      default:
        return Icons.assignment;
    }
  }

  Widget _buildEvaluasiAnswers(Map<String, dynamic> jawaban) {
    if (jawaban.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Tidak ada jawaban yang tersimpan',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: jawaban.entries.map((entry) {
        final soalData = entry.value as Map<String, dynamic>;
        final isCorrect = soalData['is_correct'] as bool;
        final pertanyaan = soalData['pertanyaan'] ?? '';
        final opsiUser = soalData['opsi_user'] ?? 'Tidak dijawab';
        final opsiBenar = soalData['opsi_benar'] ?? '';
        
        // Extract nomor soal dari key
        final soalNumber = entry.key.replaceAll('soal_', '');
        final soalIndex = int.tryParse(soalNumber) ?? 0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isCorrect 
                  ? AppTheme.successColor.withOpacity(0.3)
                  : AppTheme.errorColor.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
            color: isCorrect 
                ? AppTheme.successColor.withOpacity(0.02)
                : AppTheme.errorColor.withOpacity(0.02),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan status dan nomor soal
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCorrect 
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: isCorrect 
                          ? AppTheme.successColor.withOpacity(0.2)
                          : AppTheme.errorColor.withOpacity(0.2),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isCorrect ? AppTheme.successColor : AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        isCorrect ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Soal ${soalIndex + 1} - ${isCorrect ? 'Benar' : 'Salah'}',
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isCorrect ? AppTheme.successColor : AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Konten soal dan jawaban
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pertanyaan
                    if (pertanyaan.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Pertanyaan:',
                              style: AppTheme.bodySmall.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: Text(
                          pertanyaan,
                          style: AppTheme.bodySmall.copyWith(
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Jawaban siswa
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 16,
                          color: isCorrect ? AppTheme.successColor : AppTheme.errorColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Jawaban Siswa:',
                          style: AppTheme.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isCorrect ? AppTheme.successColor : AppTheme.errorColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isCorrect ? AppTheme.successColor : AppTheme.errorColor).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (isCorrect ? AppTheme.successColor : AppTheme.errorColor).withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        opsiUser,
                        style: AppTheme.bodySmall.copyWith(
                          color: isCorrect ? AppTheme.successColor : AppTheme.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    
                    // Jawaban benar (jika salah)
                    if (!isCorrect && opsiBenar.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: AppTheme.successColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Jawaban Benar:',
                            style: AppTheme.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.successColor.withOpacity(0.2),
                          ),
                        ),
                        child: Text(
                          opsiBenar,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) {
      return AppTheme.successColor;
    } else if (score >= 60) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.errorColor;
    }
  }

  double _calculateAverageScore(List<HasilSiswa> hasilList) {
    if (hasilList.isEmpty) return 0.0;
    
    final validScores = hasilList
        .where((hasil) => hasil.nilaiEvaluasi != null)
        .map((hasil) => hasil.nilaiEvaluasi!.toDouble())
        .toList();
    
    if (validScores.isEmpty) return 0.0;
    
    return validScores.reduce((a, b) => a + b) / validScores.length;
  }
}