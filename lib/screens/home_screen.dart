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
  // Current selected tab index
  void _showAdminPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AdminPasswordDialog(
          onAuthenticated: (isAuthenticated) {
            // Tutup dialog terlebih dahulu
            Navigator.pop(dialogContext);
            
            // Kemudian lakukan navigasi jika berhasil
            if (isAuthenticated) {
              Navigator.pushNamed(context, AppConstants.routeAdmin);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColorDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Media Pembelajaran',
                              style: AppTheme.headingMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Universitas Nusantara PGRI Kediri',
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Logo dengan animasi
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          height: 65,
                          width: 65,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.school,
                            color: AppTheme.primaryColor,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Slogan dan Tombol Admin
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lightbulb,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Belajar Digital, Mudah dan Menyenangkan',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showAdminPasswordDialog(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Menu Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      'Pilih Fitur Pembelajaran',
                      style: AppTheme.headingSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                        childAspectRatio: 0.85, // Mengatur aspek rasio untuk menghindari overflow
                        children: [
                          _buildFeatureCard(
                            context,
                            'Materi Pembelajaran',
                            'Akses materi pembelajaran dengan mudah',
                            Icons.menu_book_rounded,
                            AppTheme.primaryColor,
                            () => Navigator.pushNamed(
                              context,
                              AppConstants.routeMateri,
                            ),
                          ),
                          _buildFeatureCard(
                            context,
                            'Video Pembelajaran',
                            'Tonton video tutorial interaktif',
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
                            'Uji pemahaman dengan latihan dan kuis',
                            Icons.quiz_rounded,
                            AppTheme.successColor,
                            () => Navigator.pushNamed(
                              context,
                              AppConstants.routeEvaluasi,
                            ),
                          ),
                          _buildFeatureCard(
                            context,
                            'Identitas Pengembang',
                            'Informasi tentang pembuat aplikasi',
                            Icons.people_alt_rounded,
                            Colors.purple,
                            () => Navigator.pushNamed(
                              context,
                              AppConstants.routeIdentitas,
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
            padding: const EdgeInsets.all(12.0), // Mengurangi padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Menentukan ukuran minimal kolom
              children: [
                Container(
                  padding: const EdgeInsets.all(12), // Mengurangi padding
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 32, // Mengurangi ukuran ikon
                    color: color,
                  ),
                ),
                const SizedBox(height: 8), // Mengurangi jarak
                Text(
                  title,
                  style: AppTheme.subtitleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13, // Mengurangi ukuran font
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1, // Membatasi jumlah baris
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4), // Mengurangi jarak
                Text(
                  description,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.secondaryTextColor,
                    fontSize: 10, // Mengurangi ukuran font
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2, // Membatasi jumlah baris
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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