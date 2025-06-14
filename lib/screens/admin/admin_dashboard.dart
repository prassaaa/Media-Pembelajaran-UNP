// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/app_button.dart';
import 'package:pembelajaran_app/screens/admin/admin_hasil_siswa_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({Key? key}) : super(key: key);

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
                title: Text(
                  'Admin Dashboard',
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
                                Icons.admin_panel_settings,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kelola Konten Aplikasi',
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Text
                Text(
                  'Manajemen Konten',
                  style: AppTheme.headingSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih menu untuk mengelola konten aplikasi',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 24),
                // Menu Grid
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9, // Ubah dari 0.85 menjadi 0.9 untuk mengurangi tinggi
                    children: [
                      _buildMenuCard(
                        context,
                        'Materi Pembelajaran',
                        'Kelola konten materi pembelajaran',
                        Icons.book,
                        AppTheme.primaryColor,
                        () => Navigator.pushNamed(
                          context,
                          AppConstants.routeAdminMateri,
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        'LKPD',
                        'Kelola Lembar Kerja Peserta Didik',
                        Icons.assignment_outlined,
                        Colors.orange,
                        () => Navigator.pushNamed(
                          context,
                          AppConstants.routeAdminLkpd,
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        'Video Pembelajaran',
                        'Kelola konten video tutorial',
                        Icons.video_library,
                        AppTheme.accentColor,
                        () => Navigator.pushNamed(
                          context,
                          AppConstants.routeAdminVideo,
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        'Evaluasi Pembelajaran',
                        'Kelola soal dan kuis evaluasi',
                        Icons.assignment,
                        AppTheme.successColor,
                        () => Navigator.pushNamed(
                          context,
                          AppConstants.routeAdminEvaluasi,
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        'Hasil Siswa',
                        'Lihat hasil LKPD dan evaluasi siswa',
                        Icons.analytics,
                        Colors.indigo,
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminHasilSiswaScreen()),
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        'Identitas Pengembang',
                        'Kelola informasi pengembang aplikasi',
                        Icons.person,
                        Colors.purple,
                        () => Navigator.pushNamed(
                          context,
                          AppConstants.routeAdminIdentitas,
                        ),
                      ),
                      _buildMenuCard(
                        context,
                        'Ubah Password',
                        'Ganti password admin',
                        Icons.lock,
                        Colors.deepPurple,
                        () => _showChangePasswordDialog(context),
                      ),
                    ],
                  ),
                ),
                // Back Button
                const SizedBox(height: 16),
                AppButton(
                  text: 'Kembali ke Aplikasi',
                  icon: Icons.arrow_back,
                  type: ButtonType.outlined,
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppConstants.routeHome,
                  ),
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build individual menu card
  Widget _buildMenuCard(
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
            color: color.withOpacity(0.1),
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
            padding: const EdgeInsets.all(12.0), // Kurangi padding dari 16 ke 12
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12), // Kurangi dari 16 ke 12
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12), // Kurangi dari 16 ke 12
                  ),
                  child: Icon(
                    icon,
                    size: 36, // Kurangi dari 42 ke 36
                    color: color,
                  ),
                ),
                const SizedBox(height: 12), // Kurangi dari 16 ke 12
                Text(
                  title,
                  style: AppTheme.subtitleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13, // Kurangi ukuran font
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6), // Kurangi dari 8 ke 6
                Flexible( // Wrap dengan Flexible untuk mencegah overflow
                  child: Text(
                    description,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 11, // Kurangi ukuran font
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Show change password dialog
  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController _passwordController = TextEditingController();
    final FirebaseService _firebaseService = FirebaseService();
    bool _isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Ubah Password Admin'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password Baru',
                      hintText: 'Masukkan password baru',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password tidak boleh kosong'),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                            return;
                          }

                          setState(() {
                            _isLoading = true;
                          });

                          try {
                            await _firebaseService.updateAdminPassword(
                              _passwordController.text,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Password berhasil diubah'),
                                backgroundColor: AppTheme.successColor,
                              ),
                            );
                          } catch (e) {
                            setState(() {
                              _isLoading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Gagal mengubah password: ${e.toString()}'),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                          }
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}