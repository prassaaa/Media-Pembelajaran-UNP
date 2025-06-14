class AppConstants {
  // App info
  static const String appName = 'Media Pembelajaran';
  static const String appVersion = '1.0.0';
  
  // Navigation routes
  static const String routeSplash = '/splash';
  static const String routeHome = '/';
  static const String routeIdentitas = '/identitas';
  static const String routeMateri = '/materi';
  static const String routeMateriDetail = '/materi/detail';
  static const String routeVideo = '/video';
  static const String routeVideoDetail = '/video/detail';
  static const String routeEvaluasi = '/evaluasi';
  static const String routeEvaluasiDetail = '/evaluasi/detail';
  static const String routeHasil = '/hasil';
  
  // LKPD Routes
  static const String routeLkpd = '/lkpd';
  static const String routeLkpdDetail = '/lkpd/detail';
  
  // FORM IDENTITAS ROUTE
  static const String routeFormIdentitas = '/form-identitas';
  
  static const String routeAdmin = '/admin';
  static const String routeAdminIdentitas = '/admin/identitas';
  static const String routeAdminMateri = '/admin/materi';
  static const String routeAdminMateriForm = '/admin/materi/form';
  static const String routeAdminVideo = '/admin/video';
  static const String routeAdminVideoForm = '/admin/video/form';
  static const String routeAdminEvaluasi = '/admin/evaluasi';
  static const String routeAdminEvaluasiForm = '/admin/evaluasi/form';
  static const String routeAdminSoalForm = '/admin/soal/form';
  
  // Admin LKPD Routes
  static const String routeAdminLkpd = '/admin/lkpd';
  static const String routeAdminLkpdForm = '/admin/lkpd/form';
  
  // ADMIN HASIL SISWA ROUTE
  static const String routeAdminHasilSiswa = '/admin/hasil-siswa';
  
  // Shared preferences keys
  static const String prefAdminPassword = 'admin_password';
  static const String prefLastEvaluasiResults = 'last_evaluasi_results';
  
  // Animation durations
  static const Duration animDurationShort = Duration(milliseconds: 250);
  static const Duration animDurationMedium = Duration(milliseconds: 500);
  static const Duration animDurationLong = Duration(milliseconds: 800);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 16.0;
  static const double cardElevation = 2.0;
  
  // Asset paths
  static const String logoPath = 'assets/images/logo.png';
  static const String profileImagePath = 'assets/images/profile.png';
  static const String loginBgPath = 'assets/images/login_bg.png';
  static const String emptyStateIllustration = 'assets/images/empty_state.png';
  static const String errorIllustration = 'assets/images/error.png';
  static const String successIllustration = 'assets/images/success.png';
}