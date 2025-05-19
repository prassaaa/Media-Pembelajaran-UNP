import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class EvaluasiDetailScreen extends StatefulWidget {
  const EvaluasiDetailScreen({Key? key}) : super(key: key);

  @override
  State<EvaluasiDetailScreen> createState() => _EvaluasiDetailScreenState();
}

class _EvaluasiDetailScreenState extends State<EvaluasiDetailScreen> with SingleTickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  
  bool _isLoading = false;
  List<Soal> _soalList = [];
  bool _isStarted = false;
  int _currentSoalIndex = 0;
  List<int> _userAnswers = [];
  bool _showResult = false;
  int _correctCount = 0;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Evaluasi evaluasi = ModalRoute.of(context)!.settings.arguments as Evaluasi;

    if (!_isStarted) {
      // Tampilkan informasi evaluasi dan tombol mulai
      return Scaffold(
        body: _isLoading
            ? const LoadingWidget(message: 'Memuat data evaluasi...')
            : CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    backgroundColor: AppTheme.successColor,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Detail Evaluasi',
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
                              AppTheme.successColor,
                              const Color(0xFF004D40),
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
                            Center(
                              child: Icon(
                                Icons.quiz_rounded,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.successColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.successColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.assignment,
                                    color: AppTheme.successColor,
                                    size: 36,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        evaluasi.judul,
                                        style: AppTheme.subtitleLarge.copyWith(
                                          color: AppTheme.successColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${evaluasi.soalIds.length} Soal',
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: AppTheme.secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Deskripsi
                          Text(
                            'Deskripsi',
                            style: AppTheme.subtitleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              evaluasi.deskripsi,
                              style: AppTheme.bodyMedium,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Info terkait
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.infoColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.infoColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.info,
                                      color: AppTheme.infoColor,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Informasi Evaluasi',
                                      style: AppTheme.subtitleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.infoColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildEvaluasiInfoRow(
                                  'Jumlah Soal', 
                                  '${evaluasi.soalIds.length} Soal', 
                                  Icons.quiz_rounded
                                ),
                                const SizedBox(height: 8),
                                _buildEvaluasiInfoRow(
                                  'Tingkat Kesulitan', 
                                  _getDifficultyLevel(evaluasi.soalIds.length), 
                                  Icons.fitness_center
                                ),
                                const SizedBox(height: 8),
                                _buildEvaluasiInfoRow(
                                  'Estimasi Waktu', 
                                  _getEstimatedTime(evaluasi.soalIds.length), 
                                  Icons.timer
                                ),
                                const Divider(height: 24),
                                // Instruksi
                                Text(
                                  'Petunjuk Pengerjaan:',
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildInstructionRow(
                                  'Kerjakan soal sesuai dengan kemampuan Anda',
                                ),
                                _buildInstructionRow(
                                  'Pilih salah satu jawaban yang Anda anggap benar',
                                ),
                                _buildInstructionRow(
                                  'Hasil evaluasi akan muncul setelah Anda menyelesaikan semua soal',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Tombol Mulai
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.successColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton.icon(
                              onPressed: () => _startEvaluasi(evaluasi),
                              icon: const Icon(Icons.play_arrow, size: 24),
                              label: const Text('Mulai Evaluasi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.successColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: AppTheme.subtitleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
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
                ],
              ),
      );
    } else if (_showResult) {
      // Tampilkan hasil evaluasi
      return Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 0,
              pinned: true,
              backgroundColor: _getResultColor(),
              title: Text(
                'Hasil Evaluasi',
                style: AppTheme.subtitleLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              automaticallyImplyLeading: false,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header Hasil
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getResultColor(),
                            _getResultColor().withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _getResultColor().withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getResultIcon(),
                              color: Colors.white,
                              size: 56,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getResultTitle(),
                            style: AppTheme.headingMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Kamu menjawab $_correctCount dari ${_soalList.length} soal dengan benar',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Nilai:',
                                  style: AppTheme.subtitleLarge.copyWith(
                                    color: _getResultColor(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  (_correctCount / _soalList.length * 100).toStringAsFixed(0),
                                  style: AppTheme.headingLarge.copyWith(
                                    color: _getResultColor(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Detail Jawaban
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
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
                          Text(
                            'Detail Jawaban',
                            style: AppTheme.headingSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _soalList.length,
                            separatorBuilder: (context, index) => const Divider(height: 32),
                            itemBuilder: (context, index) {
                              final soal = _soalList[index];
                              final isCorrect = _userAnswers[index] == soal.jawabanBenar;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isCorrect
                                              ? AppTheme.successColor
                                              : AppTheme.errorColor,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: AppTheme.bodyMedium.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        isCorrect ? 'Jawaban Benar' : 'Jawaban Salah',
                                        style: AppTheme.subtitleMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: isCorrect
                                              ? AppTheme.successColor
                                              : AppTheme.errorColor,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        isCorrect ? Icons.check_circle : Icons.cancel,
                                        color: isCorrect
                                            ? AppTheme.successColor
                                            : AppTheme.errorColor,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    soal.pertanyaan,
                                    style: AppTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Gambar jika ada
                                  if (soal.gambarUrl != null &&
                                      soal.gambarUrl!.isNotEmpty) ...[
                                    Container(
                                      height: 150,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey.withOpacity(0.1),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          soal.gambarUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 48,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                  ],

                                  // Jawaban
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildAnswerCard(
                                          'Jawaban Kamu:',
                                          soal.opsi[_userAnswers[index]],
                                          isCorrect
                                              ? AppTheme.successColor
                                              : AppTheme.errorColor,
                                        ),
                                      ),
                                      if (!isCorrect) ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: _buildAnswerCard(
                                            'Jawaban Benar:',
                                            soal.opsi[soal.jawabanBenar],
                                            AppTheme.successColor,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Selesai
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Kembali ke Daftar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                AppConstants.routeHasil,
                                arguments: {
                                  'evaluasi': evaluasi,
                                  'soalList': _soalList,
                                  'userAnswers': _userAnswers,
                                  'correctCount': _correctCount,
                                },
                              );
                            },
                            icon: const Icon(Icons.analytics),
                            label: const Text('Lihat Detail Hasil'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getResultColor(),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
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
      );
    } else {
      // Tampilkan soal evaluasi
      final currentSoal = _soalList[_currentSoalIndex];
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (_currentSoalIndex > 0) {
                          setState(() {
                            _currentSoalIndex--;
                          });
                        }
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _currentSoalIndex > 0
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Soal ${_currentSoalIndex + 1} dari ${_soalList.length}',
                        style: AppTheme.subtitleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        _formatTime(_getTimeForQuestion()),
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Progress Bar
                Container(
                  height: 10,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (_currentSoalIndex + 1) / _soalList.length,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.successColor,
                                AppTheme.successColor.withOpacity(0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Question Card
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question number and difficulty
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.successColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  'Soal ${_currentSoalIndex + 1}',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.successColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: AppTheme.warningColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _getQuestionDifficulty(_currentSoalIndex),
                                    style: AppTheme.bodySmall.copyWith(
                                      color: AppTheme.secondaryTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Question
                          Text(
                            currentSoal.pertanyaan,
                            style: AppTheme.subtitleLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Gambar (jika ada)
                          if (currentSoal.gambarUrl != null &&
                              currentSoal.gambarUrl!.isNotEmpty) ...[
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.grey.withOpacity(0.1),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  currentSoal.gambarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Pilihan Jawaban
                          Text(
                            'Pilih Jawaban:',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: currentSoal.opsi.length,
                            itemBuilder: (context, index) {
                              final isSelected = _userAnswers.length > _currentSoalIndex &&
                                  _userAnswers[_currentSoalIndex] == index;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (_userAnswers.length <= _currentSoalIndex) {
                                        _userAnswers.add(index);
                                      } else {
                                        _userAnswers[_currentSoalIndex] = index;
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.successColor
                                            : Colors.grey.withOpacity(0.3),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      color: isSelected
                                          ? AppTheme.successColor.withOpacity(0.1)
                                          : Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: isSelected
                                                ? AppTheme.successColor
                                                : Colors.grey.withOpacity(0.1),
                                            border: isSelected
                                                ? null
                                                : Border.all(
                                                    color: Colors.grey.withOpacity(0.5),
                                                  ),
                                          ),
                                          child: Center(
                                            child: isSelected
                                                ? const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 18,
                                                  )
                                                : Text(
                                                    String.fromCharCode(
                                                        'A'.codeUnitAt(0) + index),
                                                    style: AppTheme.subtitleMedium.copyWith(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            currentSoal.opsi[index],
                                            style: AppTheme.bodyMedium.copyWith(
                                              fontWeight: isSelected
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Tombol Navigasi
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Tombol Kembali
                    if (_currentSoalIndex > 0)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _currentSoalIndex--;
                          });
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Sebelumnya'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(140, 48),
                        ),
                      )
                    else
                      const SizedBox(width: 140),

                    // Tombol Selanjutnya/Selesai
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.successColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _userAnswers.length > _currentSoalIndex
                            ? () {
                                if (_currentSoalIndex == _soalList.length - 1) {
                                  // Hitung jawaban benar
                                  _calculateResult();
                                } else {
                                  setState(() {
                                    _currentSoalIndex++;
                                    _animationController.forward(from: 0);
                                  });
                                }
                              }
                            : null,
                        icon: Icon(_currentSoalIndex == _soalList.length - 1
                            ? Icons.check_circle
                            : Icons.arrow_forward),
                        label: Text(_currentSoalIndex == _soalList.length - 1
                            ? 'Selesai'
                            : 'Selanjutnya'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(140, 48),
                          disabledBackgroundColor: Colors.grey,
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
  }

  Widget _buildEvaluasiInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.infoColor,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.infoColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.infoColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.infoColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(String label, String answer, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTheme.bodySmall.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startEvaluasi(Evaluasi evaluasi) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final soalList = await _firebaseService.getSoalFromEvaluasi(evaluasi.id);
      setState(() {
        _soalList = soalList;
        _isLoading = false;
        _isStarted = true;
        _currentSoalIndex = 0;
        _userAnswers = [];
        _showResult = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat soal: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _calculateResult() {
    int correctCount = 0;
    for (int i = 0; i < _soalList.length; i++) {
      if (_userAnswers[i] == _soalList[i].jawabanBenar) {
        correctCount++;
      }
    }

    setState(() {
      _correctCount = correctCount;
      _showResult = true;
    });
  }

  Color _getResultColor() {
    final score = _correctCount / _soalList.length;
    if (score >= 0.8) {
      return AppTheme.successColor;
    } else if (score >= 0.6) {
      return AppTheme.warningColor;
    } else {
      return AppTheme.errorColor;
    }
  }

  IconData _getResultIcon() {
    final score = _correctCount / _soalList.length;
    if (score >= 0.8) {
      return Icons.emoji_events;
    } else if (score >= 0.6) {
      return Icons.thumb_up;
    } else {
      return Icons.sentiment_dissatisfied;
    }
  }

  String _getResultTitle() {
    final score = _correctCount / _soalList.length;
    if (score >= 0.8) {
      return 'Sangat Baik!';
    } else if (score >= 0.6) {
      return 'Cukup Baik';
    } else {
      return 'Perlu Belajar Lagi';
    }
    }

  String _getDifficultyLevel(int soalCount) {
    if (soalCount <= 5) {
      return 'Mudah';
    } else if (soalCount <= 10) {
      return 'Sedang';
    } else {
      return 'Sulit';
    }
  }

  String _getEstimatedTime(int soalCount) {
    // Estimasi waktu pengerjaan
    int minutes = soalCount * 2; // 2 menit per soal
    return '$minutes Menit';
  }
  
  String _getQuestionDifficulty(int questionIndex) {
    // Membuat tingkat kesulitan bervariasi
    if (questionIndex < _soalList.length / 3) {
      return 'Mudah';
    } else if (questionIndex < _soalList.length * 2 / 3) {
      return 'Sedang';
    } else {
      return 'Sulit';
    }
  }
  
  int _getTimeForQuestion() {
    // Mengembalikan waktu dalam detik berdasarkan tingkat kesulitan
    String difficulty = _getQuestionDifficulty(_currentSoalIndex);
    switch (difficulty) {
      case 'Mudah':
        return 60; // 1 menit
      case 'Sedang':
        return 120; // 2 menit
      case 'Sulit':
        return 180; // 3 menit
      default:
        return 120; // Default 2 menit
    }
  }
  
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}