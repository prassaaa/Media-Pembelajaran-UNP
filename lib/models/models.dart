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