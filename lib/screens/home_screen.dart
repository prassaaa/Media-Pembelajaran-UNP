import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/widgets/admin_password_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Show admin password dialog
  void _showAdminPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AdminPasswordDialog(
          onAuthenticated: (isAuthenticated) {
            Navigator.pop(dialogContext);
            if (isAuthenticated) {
              Navigator.pushNamed(context, AppConstants.routeAdmin);
            }
          },
        );
      },
    );
  }

  // Show tutorial modal
  void _showTutorialModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modal Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.primaryColorDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.school_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Panduan Penggunaan',
                                  style: AppTheme.subtitleLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Media Pembelajaran Digital',
                                  style: AppTheme.bodySmall.copyWith(
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
                    ],
                  ),
                ),
                // Modal Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.waving_hand,
                                color: Colors.orange,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Halo Adik-adik! 👋',
                                      style: AppTheme.subtitleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    Text(
                                      'Selamat datang di aplikasi belajar yang seru dan menyenangkan!',
                                      style: AppTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Menu-menu dalam Aplikasi',
                          style: AppTheme.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Tutorial Steps - MATERI PEMBELAJARAN
                        _buildTutorialStep(
                          number: '1',
                          icon: Icons.menu_book_rounded,
                          color: AppTheme.primaryColor,
                          title: 'Materi Pembelajaran 📚',
                          description:
                              'Di sini kalian bisa membaca materi pembelajaran tentang Hak dan Kewajiban. Seperti membaca buku cerita yang menarik!',
                          detailedExplanation: 'Apa yang bisa kalian lakukan?',
                          tips: [
                            '🔍 Buka menu "Materi Pembelajaran" dengan menekan tombolnya',
                            '📖 Pilih materi yang ingin kalian baca',
                            '👀 Baca dengan pelan-pelan dan pahami setiap bagiannya',
                            '💭 Kalian akan belajar tentang hak-hak kalian sebagai anak',
                            '✅ Kalian juga akan belajar kewajiban yang harus dilakukan',
                            '❤️ Ada gambar-gambar menarik yang membantu kalian memahami',
                            '📑 Kalian bisa membaca berulang-ulang sampai paham'
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Tutorial Steps - LKPD
                        _buildTutorialStep(
                          number: '2',
                          icon: Icons.assignment_outlined,
                          color: Colors.orange,
                          title: 'LKPD (Lembar Kerja) 📝',
                          description:
                              'LKPD itu seperti buku latihan yang seru! Kalian akan mengerjakan kegiatan-kegiatan menyenangkan untuk lebih memahami pelajaran.',
                          detailedExplanation: 'Kegiatan apa saja yang ada?',
                          tips: [
                            '📋 Buka menu "LKPD" dengan menekan tombolnya',
                            '🎯 Pilih LKPD yang ingin kalian kerjakan',
                            '👁️ Ada kegiatan mengamati gambar-gambar menarik',
                            '🤔 Ada kegiatan berpikir dan menganalisis',
                            '💬 Ada kegiatan diskusi dengan teman-teman',
                            '🧪 Ada kegiatan praktik langsung yang seru',
                            '📝 Jawab semua pertanyaan dengan baik dan benar',
                            '✏️ Tulis jawaban kalian dengan rapi',
                            '⏰ Setiap kegiatan ada waktu yang sudah ditentukan',
                            '🏆 Selesaikan semua kegiatan sampai tuntas!'
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Tutorial Steps - VIDEO PEMBELAJARAN
                        _buildTutorialStep(
                          number: '3',
                          icon: Icons.play_circle_fill_rounded,
                          color: AppTheme.accentColor,
                          title: 'Video Pembelajaran 🎬',
                          description:
                              'Belajar jadi lebih seru dengan menonton video! Seperti menonton film edukasi yang menarik dan mudah dipahami.',
                          detailedExplanation: 'Apa yang bisa kalian tonton?',
                          tips: [
                            '🎥 Buka menu "Video Pembelajaran"',
                            '▶️ Pilih video yang ingin kalian tonton',
                            '👀 Tonton video dengan fokus dan perhatian',
                            '🔊 Dengarkan penjelasan dengan baik',
                            '⏸️ Kalian bisa pause (jeda) video kapan saja',
                            '🔄 Kalian bisa memutar ulang bagian yang belum paham',
                            '📝 Catat hal-hal penting yang kalian pelajari',
                            '🤝 Video akan menjelaskan tentang hak dan kewajiban dengan mudah',
                            '🎭 Ada animasi dan gambar yang membantu kalian memahami',
                            '✨ Belajar jadi tidak membosankan!'
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Tutorial Steps - EVALUASI BELAJAR
                        _buildTutorialStep(
                          number: '4',
                          icon: Icons.quiz_rounded,
                          color: AppTheme.successColor,
                          title: 'Evaluasi Belajar 🏆',
                          description:
                              'Saatnya mengetes seberapa pintar kalian! Seperti bermain kuis yang seru untuk mengukur pemahaman kalian.',
                          detailedExplanation: 'Bagaimana cara mengerjakannya?',
                          tips: [
                            '🎯 Buka menu "Evaluasi Belajar"',
                            '📋 Pilih evaluasi yang tersedia',
                            '📖 Baca instruksi dengan teliti sebelum mulai',
                            '❓ Ada soal pilihan ganda yang mudah dijawab',
                            '🤔 Baca setiap soal dengan pelan-pelan',
                            '💭 Pikirkan jawaban dengan baik sebelum memilih',
                            '✅ Pilih jawaban yang paling benar',
                            '⏰ Kerjakan dengan tenang, tidak perlu terburu-buru',
                            '🎉 Setelah selesai, kalian akan melihat hasilnya',
                            '📊 Kalian bisa tahu jawaban mana yang benar atau salah',
                            '🌟 Kalau ada yang salah, belajar lagi supaya lebih pintar!'
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Tips Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.warningColor.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lightbulb_outline,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Tips Belajar yang Baik 💡',
                                    style: AppTheme.subtitleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildTipItem('📅 Belajar setiap hari sedikit-sedikit, jangan sekaligus banyak'),
                              _buildTipItem('✏️ Catat hal-hal penting di buku catatan kalian'),
                              _buildTipItem('📝 Kerjakan LKPD dengan teliti dan jangan terburu-buru'),
                              _buildTipItem('🎥 Tonton video pembelajaran untuk memahami lebih baik'),
                              _buildTipItem('🔄 Ulangi materi yang belum kalian pahami'),
                              _buildTipItem('❓ Jangan malu bertanya jika ada yang tidak mengerti'),
                              _buildTipItem('🎯 Kerjakan evaluasi untuk mengetes pemahaman kalian'),
                              _buildTipItem('😊 Belajar dengan senang hati, jangan stres!'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Urutan Belajar yang Baik
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
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
                                    'Urutan Belajar yang Baik 🚀',
                                    style: AppTheme.subtitleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.successColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildStepItem('1️⃣', 'Baca Materi Pembelajaran dulu', 'Pahami konsep dasar tentang hak dan kewajiban'),
                              _buildStepItem('2️⃣', 'Tonton Video Pembelajaran', 'Lihat penjelasan dengan gambar yang menarik'),
                              _buildStepItem('3️⃣', 'Kerjakan LKPD', 'Praktikkan apa yang sudah kalian pelajari'),
                              _buildStepItem('4️⃣', 'Ikuti Evaluasi Belajar', 'Tes seberapa paham kalian dengan materi'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Contact Section
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.infoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.help_outline,
                                    color: AppTheme.infoColor,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Butuh Bantuan? 🆘',
                                    style: AppTheme.subtitleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.infoColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Jika kalian bingung atau ada yang tidak mengerti, kalian bisa:',
                                style: AppTheme.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildTipItem('🙋‍♀️ Bertanya kepada guru atau orang tua'),
                              _buildTipItem('👥 Diskusi dengan teman-teman'),
                              _buildTipItem('🔍 Lihat informasi pengembang di menu "Materi Pembelajaran"'),
                              _buildTipItem('📞 Minta bantuan orang dewasa untuk menghubungi pengembang'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Modal Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Ayo Mulai Belajar! 🚀',
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
        );
      },
    );
  }

  // Build individual tutorial step
  Widget _buildTutorialStep({
    required String number,
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required String detailedExplanation,
    required List<String> tips,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTheme.subtitleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            detailedExplanation,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // Build individual tip item
  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: AppTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // Build step item for learning sequence
  Widget _buildStepItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
                Text(
                  description,
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width >= 360 && screenSize.width < 400;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header Section - DIPERBAIKI UNTUK RESPONSIVE TEXT
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/indonesia_background.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // DIPERBAIKI: Responsive font size dan tidak terpotong
                              Text(
                                'Multimedia Interaktif',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSmallScreen ? 16 : (isMediumScreen ? 18 : 20),
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(1, 1),
                                      blurRadius: 3,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: isSmallScreen ? 6 : 8),
                              // DIPERBAIKI: Responsive font dan tidak terpotong
                              Text(
                                'Hak dan Kewajiban Mata Pelajaran Pendidikan Pancasila Kelas 4',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 11 : (isMediumScreen ? 12 : 14),
                                  height: 1.3,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(1, 1),
                                      blurRadius: 3,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Hero(
                          tag: 'profile_image',
                          child: Container(
                            height: isSmallScreen ? 50 : (isMediumScreen ? 60 : 65),
                            width: isSmallScreen ? 50 : (isMediumScreen ? 60 : 65),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                AppConstants.profileImagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: AppTheme.primaryColor,
                                      size: isSmallScreen ? 24 : 32,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 12 : 16,
                              vertical: isSmallScreen ? 8 : 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.lightbulb,
                                  color: Colors.white,
                                  size: isSmallScreen ? 16 : 20,
                                ),
                                SizedBox(width: isSmallScreen ? 6 : 8),
                                Expanded(
                                  child: Text(
                                    'Belajar Digital, Mudah dan Menyenangkan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isSmallScreen ? 10 : (isMediumScreen ? 11 : 12),
                                      fontWeight: FontWeight.w500,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(1, 1),
                                          blurRadius: 2,
                                          color: Colors.black.withOpacity(0.3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showAdminPasswordDialog(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.admin_panel_settings,
                                color: Colors.white,
                                size: isSmallScreen ? 20 : 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Feature Grid - SEKARANG 4 MENU (TAMBAH LKPD)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Pilih Fitur Pembelajaran',
                          style: AppTheme.headingSmall.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _showTutorialModal(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.help_outline,
                                  size: 16,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tutorial',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Akses berbagai konten pembelajaran digital',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: screenSize.width > 600 ? 3 : 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                        children: [
                          _buildFeatureCard(
                            context,
                            'Materi Pembelajaran',
                            'Baca materi tentang hak dan kewajiban dengan mudah',
                            Icons.menu_book_rounded,
                            AppTheme.primaryColor,
                            () => Navigator.pushNamed(
                              context,
                              AppConstants.routeMateri,
                            ),
                          ),
                          // LKPD CARD
                          _buildFeatureCard(
                            context,
                            'LKPD',
                            'Kerjakan lembar kerja yang seru dan menyenangkan',
                            Icons.assignment_outlined,
                            Colors.orange,
                            () => Navigator.pushNamed(
                              context,
                              AppConstants.routeLkpd,
                            ),
                          ),
                          _buildFeatureCard(
                            context,
                            'Video Pembelajaran',
                            'Tonton video pembelajaran yang menarik',
                            Icons.play_circle_fill_rounded,
                            AppTheme.accentColor,
                            () => Navigator.pushNamed(
                              context,
                              AppConstants.routeVideo,
                            ),
                          ),
                          _buildFeatureCard(
                            context,
                            'Evaluasi Belajar',
                            'Tes kepintaran kalian dengan kuis seru',
                            Icons.quiz_rounded,
                            AppTheme.successColor,
                            () => Navigator.pushNamed(
                              context,
                              AppConstants.routeEvaluasi,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '© ${DateTime.now().year} Media Pembelajaran',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Versi ${AppConstants.appVersion}',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.secondaryTextColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildSocialIcon(Icons.facebook_rounded, Colors.blue[700]!),
                      _buildSocialIcon(Icons.link_rounded, Colors.green),
                      _buildSocialIcon(Icons.email_rounded, Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build feature card
  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: AppTheme.subtitleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build social icon
  Widget _buildSocialIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 18,
        color: color,
      ),
    );
  }
}