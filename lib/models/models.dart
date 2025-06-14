import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class Materi {
  final String id;
  final String judul;
  final String deskripsi;
  final String gambarUrl;
  final String konten;
  final String capaianPembelajaran;
  final String tujuanPembelajaran;
  final DateTime createdAt;
  final DateTime updatedAt;

  Materi({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.gambarUrl,
    required this.konten,
    required this.capaianPembelajaran,
    required this.tujuanPembelajaran,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Materi.fromMap(Map<String, dynamic> map, String id) {
    return Materi(
      id: id,
      judul: map['judul'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      gambarUrl: map['gambarUrl'] ?? '',
      konten: map['konten'] ?? '',
      capaianPembelajaran: map['capaianPembelajaran'] ?? '',
      tujuanPembelajaran: map['tujuanPembelajaran'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      'gambarUrl': gambarUrl,
      'konten': konten,
      'capaianPembelajaran': capaianPembelajaran,
      'tujuanPembelajaran': tujuanPembelajaran,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// Model untuk Video Pembelajaran
class Video {
  final String id;
  final String judul;
  final String deskripsi;
  final String youtubeUrl;
  final String thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Video({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.youtubeUrl,
    required this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Video.fromMap(Map<String, dynamic> map, String id) {
    return Video(
      id: id,
      judul: map['judul'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      youtubeUrl: map['youtubeUrl'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      'youtubeUrl': youtubeUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// Model untuk Soal Evaluasi
class Soal {
  final String id;
  final String pertanyaan;
  final List<String> opsi;
  final int jawabanBenar;
  final String? gambarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Soal({
    required this.id,
    required this.pertanyaan,
    required this.opsi,
    required this.jawabanBenar,
    this.gambarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Soal.fromMap(Map<String, dynamic> map, String id) {
    return Soal(
      id: id,
      pertanyaan: map['pertanyaan'] ?? '',
      opsi: List<String>.from(map['opsi'] ?? []),
      jawabanBenar: map['jawabanBenar'] ?? 0,
      gambarUrl: map['gambarUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pertanyaan': pertanyaan,
      'opsi': opsi,
      'jawabanBenar': jawabanBenar,
      'gambarUrl': gambarUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// Model untuk Evaluasi (Kumpulan Soal)
class Evaluasi {
  final String id;
  final String judul;
  final String deskripsi;
  final List<String> soalIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Evaluasi({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.soalIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Evaluasi.fromMap(Map<String, dynamic> map, String id) {
    return Evaluasi(
      id: id,
      judul: map['judul'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      soalIds: List<String>.from(map['soalIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      'soalIds': soalIds,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// Model untuk Identitas Aplikasi
class Identitas {
  final String id;
  final String namaMahasiswa;
  final String nimMahasiswa;
  final String prodiMahasiswa;
  final String fotoMahasiswaUrl;
  final String namaDospem1;
  final String nipDospem1;
  final String fotoDospem1Url;
  final String? namaDospem2;
  final String? nipDospem2;
  final String? fotoDospem2Url;
  final DateTime createdAt;
  final DateTime updatedAt;

  Identitas({
    required this.id,
    required this.namaMahasiswa,
    required this.nimMahasiswa,
    required this.prodiMahasiswa,
    required this.fotoMahasiswaUrl,
    required this.namaDospem1,
    required this.nipDospem1,
    required this.fotoDospem1Url,
    this.namaDospem2,
    this.nipDospem2,
    this.fotoDospem2Url,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Identitas.fromMap(Map<String, dynamic> map, String id) {
    return Identitas(
      id: id,
      namaMahasiswa: map['namaMahasiswa'] ?? '',
      nimMahasiswa: map['nimMahasiswa'] ?? '',
      prodiMahasiswa: map['prodiMahasiswa'] ?? '',
      fotoMahasiswaUrl: map['fotoMahasiswaUrl'] ?? '',
      namaDospem1: map['namaDospem1'] ?? '',
      nipDospem1: map['nipDospem1'] ?? '',
      fotoDospem1Url: map['fotoDospem1Url'] ?? '',
      namaDospem2: map['namaDospem2'],
      nipDospem2: map['nipDospem2'],
      fotoDospem2Url: map['fotoDospem2Url'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'namaMahasiswa': namaMahasiswa,
      'nimMahasiswa': nimMahasiswa,
      'prodiMahasiswa': prodiMahasiswa,
      'fotoMahasiswaUrl': fotoMahasiswaUrl,
      'namaDospem1': namaDospem1,
      'nipDospem1': nipDospem1,
      'fotoDospem1Url': fotoDospem1Url,
      'namaDospem2': namaDospem2,
      'nipDospem2': nipDospem2,
      'fotoDospem2Url': fotoDospem2Url,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// Model untuk Content Images - SINGLE SOURCE OF TRUTH
class ContentImage {
  final String id;
  final String imageUrl;
  final File? file;

  ContentImage({
    required this.id,
    required this.imageUrl,
    this.file,
  });

  // Copy constructor untuk editing
  ContentImage copyWith({
    String? id,
    String? imageUrl,
    File? file,
  }) {
    return ContentImage(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      file: file ?? this.file,
    );
  }

  // Helper method untuk mengecek apakah ini gambar baru atau sudah ada
  bool get isNewImage => file != null;
  bool get isExistingImage => imageUrl.isNotEmpty && file == null;

  @override
  String toString() {
    return 'ContentImage(id: $id, imageUrl: $imageUrl, hasFile: ${file != null})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContentImage &&
        other.id == id &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => id.hashCode ^ imageUrl.hashCode;
}

// LKPD Models
enum KegiatanType {
  observasi,
  analisis,
  diskusi,
  eksperimen,
  refleksi,
  tugasIndividu,
  tugasKelompok
}

class Kegiatan {
  final String id;
  final String judul;
  final String instruksi;
  final KegiatanType type;
  final List<String> pertanyaanPemandu;
  final String? gambarUrl;
  final File? gambarFile; // Tambahan untuk support upload gambar
  final int estimasiWaktu; // dalam menit

  Kegiatan({
    required this.id,
    required this.judul,
    required this.instruksi,
    required this.type,
    required this.pertanyaanPemandu,
    this.gambarUrl,
    this.gambarFile, // Parameter baru
    required this.estimasiWaktu,
  });

  factory Kegiatan.fromMap(Map<String, dynamic> map) {
    return Kegiatan(
      id: map['id'] ?? '',
      judul: map['judul'] ?? '',
      instruksi: map['instruksi'] ?? '',
      type: KegiatanType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => KegiatanType.observasi,
      ),
      pertanyaanPemandu: List<String>.from(map['pertanyaanPemandu'] ?? []),
      gambarUrl: map['gambarUrl'],
      // gambarFile tidak disimpan di Firestore, hanya untuk temporary use
      estimasiWaktu: map['estimasiWaktu'] ?? 10,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'judul': judul,
      'instruksi': instruksi,
      'type': type.toString(),
      'pertanyaanPemandu': pertanyaanPemandu,
      'gambarUrl': gambarUrl,
      'estimasiWaktu': estimasiWaktu,
    };
  }

  // Method copyWith untuk membuat salinan dengan perubahan
  Kegiatan copyWith({
    String? id,
    String? judul,
    String? instruksi,
    KegiatanType? type,
    List<String>? pertanyaanPemandu,
    String? gambarUrl,
    File? gambarFile,
    int? estimasiWaktu,
  }) {
    return Kegiatan(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      instruksi: instruksi ?? this.instruksi,
      type: type ?? this.type,
      pertanyaanPemandu: pertanyaanPemandu ?? this.pertanyaanPemandu,
      gambarUrl: gambarUrl ?? this.gambarUrl,
      gambarFile: gambarFile ?? this.gambarFile,
      estimasiWaktu: estimasiWaktu ?? this.estimasiWaktu,
    );
  }

  // Helper methods untuk mengelola gambar
  bool get hasImage => (gambarUrl != null && gambarUrl!.isNotEmpty) || gambarFile != null;
  bool get hasNewImage => gambarFile != null;
  bool get hasExistingImage => gambarUrl != null && gambarUrl!.isNotEmpty && gambarFile == null;

  @override
  String toString() {
    return 'Kegiatan(id: $id, judul: $judul, type: $type, hasImage: $hasImage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Kegiatan &&
        other.id == id &&
        other.judul == judul &&
        other.instruksi == instruksi &&
        other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ judul.hashCode ^ instruksi.hashCode ^ type.hashCode;
}

class LKPD {
  final String id;
  final String judul;
  final String deskripsi;
  final String gambarUrl;
  final List<Kegiatan> kegiatanList;
  final String rubrikPenilaian;
  final int estimasiWaktu; // total waktu dalam menit
  final String kompetensiDasar;
  final String indikatorPencapaian;
  final DateTime createdAt;
  final DateTime updatedAt;

  LKPD({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.gambarUrl,
    required this.kegiatanList,
    required this.rubrikPenilaian,
    required this.estimasiWaktu,
    required this.kompetensiDasar,
    required this.indikatorPencapaian,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LKPD.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LKPD.fromMap(data, doc.id);
  }

  factory LKPD.fromMap(Map<String, dynamic> map, String id) {
    return LKPD(
      id: id,
      judul: map['judul'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      gambarUrl: map['gambarUrl'] ?? '',
      kegiatanList: (map['kegiatanList'] as List<dynamic>?)
          ?.map((item) => Kegiatan.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      rubrikPenilaian: map['rubrikPenilaian'] ?? '',
      estimasiWaktu: map['estimasiWaktu'] ?? 60,
      kompetensiDasar: map['kompetensiDasar'] ?? '',
      indikatorPencapaian: map['indikatorPencapaian'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      'gambarUrl': gambarUrl,
      'kegiatanList': kegiatanList.map((kegiatan) => kegiatan.toMap()).toList(),
      'rubrikPenilaian': rubrikPenilaian,
      'estimasiWaktu': estimasiWaktu,
      'kompetensiDasar': kompetensiDasar,
      'indikatorPencapaian': indikatorPencapaian,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  LKPD copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    String? gambarUrl,
    List<Kegiatan>? kegiatanList,
    String? rubrikPenilaian,
    int? estimasiWaktu,
    String? kompetensiDasar,
    String? indikatorPencapaian,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LKPD(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      gambarUrl: gambarUrl ?? this.gambarUrl,
      kegiatanList: kegiatanList ?? this.kegiatanList,
      rubrikPenilaian: rubrikPenilaian ?? this.rubrikPenilaian,
      estimasiWaktu: estimasiWaktu ?? this.estimasiWaktu,
      kompetensiDasar: kompetensiDasar ?? this.kompetensiDasar,
      indikatorPencapaian: indikatorPencapaian ?? this.indikatorPencapaian,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods untuk LKPD
  List<Kegiatan> get kegiatanWithImages => kegiatanList.where((k) => k.hasImage).toList();
  int get totalKegiatanWithImages => kegiatanWithImages.length;
  bool get hasAnyKegiatanImages => kegiatanList.any((k) => k.hasImage);

  @override
  String toString() {
    return 'LKPD(id: $id, judul: $judul, totalKegiatan: ${kegiatanList.length})';
  }
}

// Utility class untuk helper functions LKPD
class LKPDHelper {
  static String getKegiatanTypeText(KegiatanType type) {
    switch (type) {
      case KegiatanType.observasi:
        return 'Observasi';
      case KegiatanType.analisis:
        return 'Analisis';
      case KegiatanType.diskusi:
        return 'Diskusi';
      case KegiatanType.eksperimen:
        return 'Eksperimen';
      case KegiatanType.refleksi:
        return 'Refleksi';
      case KegiatanType.tugasIndividu:
        return 'Tugas Individu';
      case KegiatanType.tugasKelompok:
        return 'Tugas Kelompok';
    }
  }

  static String getTotalEstimasiWaktu(List<Kegiatan> kegiatanList) {
    int totalMenit = kegiatanList.fold(0, (sum, kegiatan) => sum + kegiatan.estimasiWaktu);
    if (totalMenit < 60) {
      return '$totalMenit menit';
    } else {
      int jam = totalMenit ~/ 60;
      int sisaMenit = totalMenit % 60;
      if (sisaMenit == 0) {
        return '$jam jam';
      } else {
        return '$jam jam $sisaMenit menit';
      }
    }
  }

  static String getDifficultyLevel(int totalKegiatan) {
    if (totalKegiatan <= 2) {
      return 'Mudah';
    } else if (totalKegiatan <= 4) {
      return 'Sedang';
    } else {
      return 'Sulit';
    }
  }

  // Helper method untuk mendapatkan icon kegiatan
  static String getKegiatanIcon(KegiatanType type) {
    switch (type) {
      case KegiatanType.observasi:
        return '👁️';
      case KegiatanType.analisis:
        return '📊';
      case KegiatanType.diskusi:
        return '💬';
      case KegiatanType.eksperimen:
        return '🧪';
      case KegiatanType.refleksi:
        return '🤔';
      case KegiatanType.tugasIndividu:
        return '👤';
      case KegiatanType.tugasKelompok:
        return '👥';
    }
  }

  // Helper method untuk mendapatkan warna kegiatan
  static String getKegiatanColor(KegiatanType type) {
    switch (type) {
      case KegiatanType.observasi:
        return '#4CAF50'; // Green
      case KegiatanType.analisis:
        return '#2196F3'; // Blue
      case KegiatanType.diskusi:
        return '#FF9800'; // Orange
      case KegiatanType.eksperimen:
        return '#9C27B0'; // Purple
      case KegiatanType.refleksi:
        return '#607D8B'; // Blue Grey
      case KegiatanType.tugasIndividu:
        return '#795548'; // Brown
      case KegiatanType.tugasKelompok:
        return '#E91E63'; // Pink
    }
  }

  // Helper method untuk validasi LKPD
  static List<String> validateLKPD(LKPD lkpd) {
    List<String> errors = [];
    
    if (lkpd.judul.trim().isEmpty) {
      errors.add('Judul LKPD tidak boleh kosong');
    }
    
    if (lkpd.deskripsi.trim().isEmpty) {
      errors.add('Deskripsi LKPD tidak boleh kosong');
    }
    
    if (lkpd.kompetensiDasar.trim().isEmpty) {
      errors.add('Kompetensi Dasar tidak boleh kosong');
    }
    
    if (lkpd.indikatorPencapaian.trim().isEmpty) {
      errors.add('Indikator Pencapaian tidak boleh kosong');
    }
    
    if (lkpd.rubrikPenilaian.trim().isEmpty) {
      errors.add('Rubrik Penilaian tidak boleh kosong');
    }
    
    if (lkpd.kegiatanList.isEmpty) {
      errors.add('Minimal satu kegiatan harus ditambahkan');
    }
    
    // Validasi setiap kegiatan
    for (int i = 0; i < lkpd.kegiatanList.length; i++) {
      final kegiatan = lkpd.kegiatanList[i];
      if (kegiatan.judul.trim().isEmpty) {
        errors.add('Judul kegiatan ${i + 1} tidak boleh kosong');
      }
      if (kegiatan.instruksi.trim().isEmpty) {
        errors.add('Instruksi kegiatan ${i + 1} tidak boleh kosong');
      }
      if (kegiatan.pertanyaanPemandu.isEmpty) {
        errors.add('Kegiatan ${i + 1} harus memiliki minimal satu pertanyaan pemandu');
      }
    }
    
    return errors;
  }

  // Helper method untuk menghitung statistik LKPD
  static Map<String, dynamic> getLKPDStatistics(LKPD lkpd) {
    Map<KegiatanType, int> typeCount = {};
    for (var type in KegiatanType.values) {
      typeCount[type] = 0;
    }
    
    int totalPertanyaan = 0;
    int kegiatanWithImages = 0;
    
    for (var kegiatan in lkpd.kegiatanList) {
      typeCount[kegiatan.type] = (typeCount[kegiatan.type] ?? 0) + 1;
      totalPertanyaan += kegiatan.pertanyaanPemandu.length;
      if (kegiatan.hasImage) {
        kegiatanWithImages++;
      }
    }
    
    return {
      'totalKegiatan': lkpd.kegiatanList.length,
      'totalPertanyaan': totalPertanyaan,
      'estimasiWaktu': lkpd.estimasiWaktu,
      'tingkatKesulitan': getDifficultyLevel(lkpd.kegiatanList.length),
      'kegiatanDenganGambar': kegiatanWithImages,
      'distribusiTipeKegiatan': typeCount,
    };
  }
}

class HasilSiswa {
  final String id;
  final String namaLengkap;
  final String nomorAbsen;
  final String kelas;
  final String jenisKegiatan; // 'lkpd' atau 'evaluasi'
  final String kegiatanId;
  final String judulKegiatan;
  final Map<String, dynamic> jawaban;
  final int? nilaiEvaluasi; // hanya untuk evaluasi
  final int? jumlahBenar; // hanya untuk evaluasi
  final int? totalSoal; // hanya untuk evaluasi
  final DateTime tanggalPengerjaan;

  HasilSiswa({
    required this.id,
    required this.namaLengkap,
    required this.nomorAbsen,
    required this.kelas,
    required this.jenisKegiatan,
    required this.kegiatanId,
    required this.judulKegiatan,
    required this.jawaban,
    this.nilaiEvaluasi,
    this.jumlahBenar,
    this.totalSoal,
    required this.tanggalPengerjaan,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaLengkap': namaLengkap,
      'nomorAbsen': nomorAbsen,
      'kelas': kelas,
      'jenisKegiatan': jenisKegiatan,
      'kegiatanId': kegiatanId,
      'judulKegiatan': judulKegiatan,
      'jawaban': jawaban,
      'nilaiEvaluasi': nilaiEvaluasi,
      'jumlahBenar': jumlahBenar,
      'totalSoal': totalSoal,
      'tanggalPengerjaan': Timestamp.fromDate(tanggalPengerjaan)
    };
  }

  factory HasilSiswa.fromMap(Map<String, dynamic> map, String id) {
    return HasilSiswa(
      id: id,
      namaLengkap: map['namaLengkap'] ?? '',
      nomorAbsen: map['nomorAbsen'] ?? '',
      kelas: map['kelas'] ?? '',
      jenisKegiatan: map['jenisKegiatan'] ?? '',
      kegiatanId: map['kegiatanId'] ?? '',
      judulKegiatan: map['judulKegiatan'] ?? '',
      jawaban: Map<String, dynamic>.from(map['jawaban'] ?? {}),
      nilaiEvaluasi: map['nilaiEvaluasi'],
      jumlahBenar: map['jumlahBenar'],
      totalSoal: map['totalSoal'],
      tanggalPengerjaan: (map['tanggalPengerjaan'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}