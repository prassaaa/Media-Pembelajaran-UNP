import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Membuat controller animasi
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Membuat animasi
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    
    // Memulai animasi
    _animationController.forward();
    
    // Timer untuk berpindah ke halaman utama
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, AppConstants.routeHome);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo atau ikon aplikasi
            ScaleTransition(
              scale: _animation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school,
                  size: 64,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Judul aplikasi dengan animasi fade in
            FadeTransition(
              opacity: _animation,
              child: Text(
                AppConstants.appName,
                style: AppTheme.headingLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Subtitle atau slogan
            FadeTransition(
              opacity: _animation,
              child: Text(
                'Belajar dengan mudah, kapan saja dan di mana saja',
                style: AppTheme.bodyLarge.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Indikator loading
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.8)),
            ),
            
            const SizedBox(height: 20),
            
            // Versi aplikasi
            Text(
              'Versi ${AppConstants.appVersion}',
              style: AppTheme.bodySmall.copyWith(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}