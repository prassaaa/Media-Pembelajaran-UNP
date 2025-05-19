// lib/screens/evaluasi/hasil_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/widgets/app_button.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class HasilScreen extends StatefulWidget {
  const HasilScreen({Key? key}) : super(key: key);

  @override
  State<HasilScreen> createState() => _HasilScreenState();
}

class _HasilScreenState extends State<HasilScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _scoreAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final Evaluasi evaluasi = args['evaluasi'] as Evaluasi;
    final List<Soal> soalList = args['soalList'] as List<Soal>;
    final List<int> userAnswers = args['userAnswers'] as List<int>;
    final int correctCount = args['correctCount'] as int;

    final double score = correctCount / soalList.length * 100;
    final String formattedDate = DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now());

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: _getScoreColor(score),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Detail Hasil Evaluasi',
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
                      _getScoreColor(score),
                      _getScoreColor(score).withOpacity(0.7),
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
                        _getScoreIcon(score),
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
                children: [
                  // Header Hasil
                  Card(
                    elevation: 4,
                    shadowColor: _getScoreColor(score).withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Info Evaluasi
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getScoreColor(score).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.assignment,
                                  color: _getScoreColor(score),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      evaluasi.judul,
                                      style: AppTheme.subtitleLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Dikerjakan pada: $formattedDate',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),

                          // Score Display
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated Score
                              AnimatedBuilder(
                                animation: _scoreAnimation,
                                builder: (context, child) {
                                  return SizedBox(
                                    width: 140,
                                    height: 140,
                                    child: Stack(
                                      children: [
                                        // Progress Circle
                                        ShaderMask(
                                          shaderCallback: (rect) {
                                            return SweepGradient(
                                              startAngle: -math.pi / 2,
                                              endAngle: 3 * math.pi / 2,
                                              colors: [
                                                _getScoreColor(score),
                                                _getScoreColor(score).withOpacity(0.6),
                                              ],
                                              stops: const [0.0, 1.0],
                                            ).createShader(rect);
                                          },
                                          child: Container(
                                            width: 140,
                                            height: 140,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            child: CustomPaint(
                                              painter: CircleProgressPainter(
                                                progress: _scoreAnimation.value * score / 100,
                                                color: _getScoreColor(score),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Score Text
                                        Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                (score * _scoreAnimation.value).toInt().toString(),
                                                style: AppTheme.headingLarge.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: _getScoreColor(score),
                                                ),
                                              ),
                                              Text(
                                                'Nilai',
                                                style: AppTheme.bodySmall.copyWith(
                                                  color: AppTheme.secondaryTextColor,
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
                              
                              const SizedBox(width: 24),
                              
                              // Hasil Analysis
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildResultItem(
                                      'Benar',
                                      '$correctCount/${soalList.length}',
                                      Icons.check_circle,
                                      AppTheme.successColor,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildResultItem(
                                      'Salah',
                                      '${soalList.length - correctCount}/${soalList.length}',
                                      Icons.cancel,
                                      AppTheme.errorColor,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildResultItem(
                                      'Status',
                                      _getScoreStatus(score),
                                      _getScoreIcon(score),
                                      _getScoreColor(score),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Performance Analysis
                  Container(
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
                          'Analisis Kinerja',
                          style: AppTheme.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Performance Chart
                        Container(
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey.withOpacity(0.1),
                          ),
                          child: Row(
                            children: [
                              // Correct answers
                              if (correctCount > 0)
                                Flexible(
                                  flex: correctCount,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.horizontal(
                                        left: const Radius.circular(20),
                                        right: soalList.length - correctCount > 0
                                            ? Radius.zero
                                            : const Radius.circular(20),
                                      ),
                                      color: AppTheme.successColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${(correctCount / soalList.length * 100).toInt()}%',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              
                              // Wrong answers
                              if (soalList.length - correctCount > 0)
                                Flexible(
                                  flex: soalList.length - correctCount,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.horizontal(
                                        left: correctCount > 0
                                            ? Radius.zero
                                            : const Radius.circular(20),
                                        right: const Radius.circular(20),
                                      ),
                                      color: AppTheme.errorColor,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${((soalList.length - correctCount) / soalList.length * 100).toInt()}%',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Performance Labels
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem('Benar', AppTheme.successColor),
                            const SizedBox(width: 32),
                            _buildLegendItem('Salah', AppTheme.errorColor),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Performance Summary
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getScoreColor(score).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getScoreColor(score).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _getScoreIcon(score),
                                    color: _getScoreColor(score),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Hasil Evaluasi',
                                    style: AppTheme.subtitleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _getScoreColor(score),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getScoreSummary(score),
                                style: AppTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Detail Jawaban Header
                  Text(
                    'Detail Jawaban',
                    style: AppTheme.headingSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Detail Jawaban List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: soalList.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final soal = soalList[index];
                      final isCorrect = userAnswers[index] == soal.jawabanBenar;

                      return Card(
                        elevation: 2,
                        shadowColor: Colors.grey.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: Container(
                            width: 36,
                            height: 36,
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
                          title: Text(
                            soal.pertanyaan,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            isCorrect ? 'Jawaban Benar' : 'Jawaban Salah',
                            style: AppTheme.bodySmall.copyWith(
                              color: isCorrect
                                  ? AppTheme.successColor
                                  : AppTheme.errorColor,
                            ),
                          ),
                          trailing: Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            color: isCorrect
                                ? AppTheme.successColor
                                : AppTheme.errorColor,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Gambar jika ada
                                  if (soal.gambarUrl != null &&
                                      soal.gambarUrl!.isNotEmpty) ...[
                                    Container(
                                      height: 150,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Colors.grey.withOpacity(0.1),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
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
                                    const SizedBox(height: 16),
                                  ],

                                  // Semua opsi
                                  ...List.generate(
                                    soal.opsi.length,
                                    (i) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: _getOptionColor(
                                            i,
                                            userAnswers[index],
                                            soal.jawabanBenar,
                                          ).withOpacity(0.1),
                                          border: Border.all(
                                            color: _getOptionColor(
                                              i,
                                              userAnswers[index],
                                              soal.jawabanBenar,
                                            ).withOpacity(0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _getOptionColor(
                                                  i,
                                                  userAnswers[index],
                                                  soal.jawabanBenar,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  String.fromCharCode(
                                                      'A'.codeUnitAt(0) + i),
                                                  style: AppTheme.bodyMedium.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                soal.opsi[i],
                                                style: AppTheme.bodyMedium.copyWith(
                                                  color: _getOptionColor(
                                                    i,
                                                    userAnswers[index],
                                                    soal.jawabanBenar,
                                                  ),
                                                  fontWeight: i == userAnswers[index] ||
                                                          i == soal.jawabanBenar
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            if (i == userAnswers[index] && !isCorrect)
                                              const Icon(
                                                Icons.close,
                                                color: AppTheme.errorColor,
                                              )
                                            else if (i == soal.jawabanBenar)
                                              const Icon(
                                                Icons.check,
                                                color: AppTheme.successColor,
                                              ),
                                          ],
                                        ),
                                      ),
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
                  const SizedBox(height: 32),

                  // Tombol Action
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: 'Kembali',
                          icon: Icons.arrow_back,
                          type: ButtonType.outlined,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppButton(
                          text: 'Bagikan Hasil',
                          icon: Icons.share,
                          onPressed: () {
                            _shareResult(
                              context,
                              evaluasi,
                              correctCount,
                              soalList.length,
                              score,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40), // Padding bawah
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.secondaryTextColor,
              ),
            ),
            Text(
              value,
              style: AppTheme.subtitleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Color _getOptionColor(int optionIndex, int userAnswerIndex, int correctIndex) {
    if (optionIndex == correctIndex) {
      return AppTheme.successColor;
    } else if (optionIndex == userAnswerIndex && userAnswerIndex != correctIndex) {
      return AppTheme.errorColor;
    } else {
      return Colors.grey;
    }
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
  
  IconData _getScoreIcon(double score) {
    if (score >= 80) {
      return Icons.emoji_events;
    } else if (score >= 60) {
      return Icons.thumb_up;
    } else {
      return Icons.sentiment_dissatisfied;
    }
  }
  
  String _getScoreStatus(double score) {
    if (score >= 80) {
      return 'Sangat Baik';
    } else if (score >= 60) {
      return 'Cukup Baik';
    } else {
      return 'Perlu Belajar';
    }
  }
  
  String _getScoreSummary(double score) {
    if (score >= 80) {
      return 'Kamu telah menguasai materi dengan sangat baik. Pertahankan pencapaian ini!';
    } else if (score >= 60) {
      return 'Pemahaman kamu cukup baik, namun masih ada beberapa konsep yang perlu diperdalam.';
    } else {
      return 'Kamu masih perlu banyak belajar untuk memahami materi dengan baik. Jangan menyerah!';
    }
  }

  void _shareResult(
    BuildContext context,
    Evaluasi evaluasi,
    int correctCount,
    int totalCount,
    double score,
  ) async {
    final String resultText = 'Hasil Evaluasi: ${evaluasi.judul}\n'
        'Skor: ${score.toStringAsFixed(0)}\n'
        'Jawaban Benar: $correctCount dari $totalCount\n'
        'Tanggal: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())}';

    try {
      await Clipboard.setData(ClipboardData(text: resultText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hasil evaluasi telah disalin ke clipboard'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyalin hasil: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }
}

// Circle Progress Painter
class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  CircleProgressPainter({required this.progress, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = radius * 0.15;
    
    // Background Circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    
    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);
    
    // Progress Arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    final progressAngle = 2 * math.pi * progress;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2, // Start at the top
      progressAngle,
      false,
      progressPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is CircleProgressPainter) {
      return oldDelegate.progress != progress || oldDelegate.color != color;
    }
    return true;
  }
}