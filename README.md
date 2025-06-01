# 📚 Media Pembelajaran - Hak dan Kewajiban

<div align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
</div>

<p align="center">
  <strong>Aplikasi Pembelajaran Digital Interaktif untuk Mata Pelajaran Hak dan Kewajiban</strong>
</p>

<p align="center">
  Dikembangkan oleh <strong>Semen Sugiarti</strong> (NPM: 2114060146)<br>
  Universitas Nusantara PGRI Kediri
</p>

---

## 🎯 **Tentang Aplikasi**

Media Pembelajaran adalah aplikasi mobile berbasis Flutter yang dirancang khusus untuk mendukung proses pembelajaran mata pelajaran **Hak dan Kewajiban**. Aplikasi ini menggabungkan teknologi modern dengan pendekatan pedagogis yang interaktif untuk menciptakan pengalaman belajar yang engaging dan efektif.

### ✨ **Fitur Utama**

#### 📖 **Materi Pembelajaran**
- Konten digital interaktif dengan format rich text
- Support untuk multiple images dalam materi
- Struktur pembelajaran yang terorganisir dengan:
  - Capaian Pembelajaran
  - Tujuan Pembelajaran
  - Konten Materi yang Komprehensif

#### 📋 **LKPD (Lembar Kerja Peserta Didik)**
- **7 Jenis Kegiatan Pembelajaran:**
  - 🔍 Observasi
  - 📊 Analisis
  - 💬 Diskusi
  - 🧪 Eksperimen
  - 🤔 Refleksi
  - 👤 Tugas Individu
  - 👥 Tugas Kelompok
- Progress tracking untuk setiap kegiatan
- Pertanyaan pemandu yang terstruktur
- Estimasi waktu pengerjaan

#### 🎥 **Video Pembelajaran**
- Integrasi YouTube Player untuk streaming video
- Kontrol playback yang lengkap
- Thumbnail dan metadata video
- Fitur fullscreen dan sharing

#### 📝 **Sistem Evaluasi**
- Kuis interaktif dengan multiple choice
- Support gambar dalam soal
- Analisis hasil real-time dengan visualisasi
- Feedback dan pembahasan jawaban
- Tracking progress pembelajaran

#### 👥 **Profil Pengembang**
- Informasi lengkap tentang tim pengembang
- Data mahasiswa dan dosen pembimbing
- Kontak dan kredensial akademik

### 🛠 **Teknologi & Arsitektur**

#### **Frontend**
- **Flutter 3.7.2** - Cross-platform mobile development
- **Dart** - Programming language
- **Material Design 3** - Modern UI components
- **Google Fonts** - Typography
- **Cached Network Image** - Optimized image loading
- **YouTube Player Flutter** - Video streaming

#### **Backend & Database**
- **Firebase Firestore** - NoSQL database
- **Firebase Storage** - File storage
- **cPanel Integration** - Custom image hosting
- **RESTful API** - Data communication

#### **State Management & Architecture**
- **Provider Pattern** - State management
- **Repository Pattern** - Data layer abstraction
- **Clean Architecture** - Separation of concerns

### 📱 **Screenshots**

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="https://via.placeholder.com/300x600/4361EE/FFFFFF?text=Home+Screen" alt="Home Screen" width="200"/>
        <br><strong>Home Screen</strong>
      </td>
      <td align="center">
        <img src="https://via.placeholder.com/300x600/06D6A0/FFFFFF?text=Materi+Detail" alt="Materi Detail" width="200"/>
        <br><strong>Materi Detail</strong>
      </td>
      <td align="center">
        <img src="https://via.placeholder.com/300x600/FF6B35/FFFFFF?text=LKPD+Kegiatan" alt="LKPD" width="200"/>
        <br><strong>LKPD Kegiatan</strong>
      </td>
      <td align="center">
        <img src="https://via.placeholder.com/300x600/7209B7/FFFFFF?text=Evaluasi" alt="Evaluasi" width="200"/>
        <br><strong>Evaluasi</strong>
      </td>
    </tr>
  </table>
</div>

## 🚀 **Instalasi & Setup**

### **Prasyarat**
- Flutter SDK ≥ 3.7.2
- Dart SDK ≥ 3.0.0
- Android Studio / VS Code
- Git

### **Clone Repository**
```bash
git clone https://github.com/[username]/media-pembelajaran-app.git
cd media-pembelajaran-app
```

### **Install Dependencies**
```bash
flutter pub get
```

### **Firebase Setup**
1. Buat project baru di [Firebase Console](https://console.firebase.google.com)
2. Download `google-services.json` dan letakkan di `android/app/`
3. Enable Firestore Database dan Firebase Storage
4. Update konfigurasi di `lib/firebase_options.dart`

### **Run Application**
```bash
flutter run
```

## 📊 **Struktur Project**

```
lib/
├── config/
│   ├── constants.dart          # App constants
│   └── theme.dart             # Theme configuration
├── models/
│   └── models.dart            # Data models
├── screens/
│   ├── admin/                 # Admin panels
│   ├── evaluasi/              # Quiz & evaluation
│   ├── lkpd/                  # LKPD features
│   ├── materi/                # Learning materials
│   ├── video/                 # Video learning
│   └── home_screen.dart       # Main dashboard
├── services/
│   ├── firebase_service.dart  # Firebase operations
│   └── cpanel_service.dart    # Image upload service
├── widgets/                   # Reusable components
└── main.dart                  # App entry point
```

## 🎨 **Design System**

### **Color Palette**
- **Primary:** `#4361EE` - Modern Blue
- **Secondary:** `#7209B7` - Purple Accent
- **Success:** `#06D6A0` - Mint Green
- **Warning:** `#FFD166` - Warm Yellow
- **Error:** `#E63946` - Coral Red

### **Typography**
- **Font Family:** Poppins (Google Fonts)
- **Responsive scaling** untuk berbagai ukuran layar
- **Accessibility compliant** contrast ratios

## 🔐 **Admin Panel**

Aplikasi dilengkapi dengan admin panel komprehensif untuk:

- ✏️ **Manajemen Konten:** CRUD operations untuk semua materi
- 🎥 **Video Management:** Upload dan organize video pembelajaran  
- 📝 **Evaluasi Builder:** Buat soal dan kuis interaktif
- 📋 **LKPD Creator:** Designer untuk lembar kerja
- 👤 **Profile Management:** Update informasi pengembang
- 🔒 **Security:** Password protection dengan enkripsi

**Default Admin Credentials:**
- Password: `admin123`

## 🤝 **Contributing**

Kontribusi sangat diterima! Silakan ikuti langkah berikut:

1. Fork repository ini
2. Buat feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

### **Code Style Guidelines**
- Gunakan `dart format` untuk formatting
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Tambahkan dokumentasi untuk public APIs
- Write unit tests untuk business logic

## 📄 **License**

Distributed under the MIT License. See `LICENSE` for more information.

## 👨‍🎓 **Developer**

<div align="center">
  <img src="https://via.placeholder.com/150x150/4361EE/FFFFFF?text=SS" alt="Developer Avatar" width="100" style="border-radius: 50%"/>
  

## 🙏 **Acknowledgments**

- **Universitas Nusantara PGRI Kediri** - Academic support
- **Flutter Team** - Amazing framework
- **Firebase** - Backend infrastructure
- **Material Design** - Design system
- **Open Source Community** - Inspiration and libraries

---

<div align="center">
  <p><strong>Dibuat dengan ❤️ untuk kemajuan pendidikan Indonesia</strong></p>
  <p><em>© 2024 Semen Sugiarti - Universitas Nusantara PGRI Kediri</em></p>
</div>