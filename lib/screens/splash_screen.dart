import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/services/firebase_service.dart'; // ✅ TAMBAH IMPORT

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _logoAnimationController;
  late AnimationController _textAnimationController;
  
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoSlideAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _titleSlideAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<double> _profileCardFadeAnimation;
  late Animation<double> _profileCardSlideAnimation;
  late Animation<double> _loadingFadeAnimation;

  // ✅ LOADING STATUS
  String _loadingText = 'Memuat aplikasi pembelajaran...';

  @override
  void initState() {
    super.initState();
    
    _mainAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _textAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _setupAnimations();
    _startAnimationSequence();
    
    // ✅ START BACKGROUND LOADING
    _startBackgroundLoading();
    
    // ✅ TIMER LEBIH PENDEK KARENA LOADING DI BACKGROUND
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppConstants.routeHome);
      }
    });
  }

  // ✅ BACKGROUND LOADING TANPA BLOCKING UI
  void _startBackgroundLoading() async {
    final firebaseService = FirebaseService();
    
    try {
      // Update loading text
      if (mounted) {
        setState(() {
          _loadingText = 'Menyiapkan data video...';
        });
      }
      
      // Load video di background (tidak await)
      firebaseService.preloadVideos().catchError((e) {
        print('Background video load error: $e');
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _loadingText = 'Menyiapkan materi pembelajaran...';
        });
      }
      
      // Load materi di background (tidak await)
      firebaseService.preloadMateri().catchError((e) {
        print('Background materi load error: $e');
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _loadingText = 'Menyiapkan LKPD...';
        });
      }
      
      // Load LKPD di background (tidak await)
      firebaseService.preloadLKPD().catchError((e) {
        print('Background LKPD load error: $e');
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        setState(() {
          _loadingText = 'Siap digunakan!';
        });
      }
      
    } catch (e) {
      print('Background loading error: $e');
      if (mounted) {
        setState(() {
          _loadingText = 'Siap digunakan!';
        });
      }
    }
  }

  void _setupAnimations() {
    // ... sama seperti sebelumnya
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _logoSlideAnimation = Tween<double>(begin: -100.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );
    
    _titleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _titleSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    
    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textAnimationController,
        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _profileCardFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _profileCardSlideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeOutBack),
      ),
    );
    
    _loadingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  void _startAnimationSequence() async {
    _logoAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _textAnimationController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _mainAnimationController.forward();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withOpacity(0.9),
              AppTheme.primaryColorDark,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    
                    // Logo dengan animasi profesional
                    AnimatedBuilder(
                      animation: Listenable.merge([_logoFadeAnimation, _logoSlideAnimation]),
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _logoSlideAnimation.value),
                          child: Opacity(
                            opacity: _logoFadeAnimation.value,
                            child: Hero(
                              tag: 'profile_image',
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    AppConstants.profileImagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: AppTheme.primaryColor,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Title dengan animasi fade dan slide
                    AnimatedBuilder(
                      animation: Listenable.merge([_titleFadeAnimation, _titleSlideAnimation]),
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _titleSlideAnimation.value),
                          child: Opacity(
                            opacity: _titleFadeAnimation.value,
                            child: Text(
                              'Media Pembelajaran',
                              style: AppTheme.headingLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                letterSpacing: 1.0,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Subtitle dengan animasi fade
                    AnimatedBuilder(
                      animation: _subtitleFadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _subtitleFadeAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Universitas Nusantara PGRI Kediri',
                              style: AppTheme.subtitleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Profile card dengan animasi slide dan fade
                    AnimatedBuilder(
                      animation: Listenable.merge([_profileCardFadeAnimation, _profileCardSlideAnimation]),
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _profileCardSlideAnimation.value),
                          child: Opacity(
                            opacity: _profileCardFadeAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.school_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Dikembangkan oleh',
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Semen Sugiarti',
                                    style: AppTheme.headingSmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.badge_outlined,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'NPM: 2114060146',
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 50),
                    
                    // Loading indicator dengan animasi fade dan dynamic text
                    AnimatedBuilder(
                      animation: _loadingFadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _loadingFadeAnimation.value,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 40,
                                height: 40,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white.withOpacity(0.9)
                                  ),
                                  strokeWidth: 3,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // ✅ DYNAMIC LOADING TEXT
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _loadingText,
                                  key: ValueKey(_loadingText),
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Version info
                    AnimatedBuilder(
                      animation: _loadingFadeAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _loadingFadeAnimation.value * 0.7,
                          child: Text(
                            'Versi ${AppConstants.appVersion}',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.6),
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}