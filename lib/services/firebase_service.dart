import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'dart:io';
import 'package:pembelajaran_app/services/cpanel_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CPanelService _cPanelService = CPanelService();

  // Collection references
  final CollectionReference _materiCollection = FirebaseFirestore.instance.collection('materi');
  final CollectionReference _videoCollection = FirebaseFirestore.instance.collection('video');
  final CollectionReference _evaluasiCollection = FirebaseFirestore.instance.collection('evaluasi');
  final CollectionReference _soalCollection = FirebaseFirestore.instance.collection('soal');
  final CollectionReference _identitasCollection = FirebaseFirestore.instance.collection('identitas');
  final CollectionReference _lkpdCollection = FirebaseFirestore.instance.collection('lkpd');

  // Getter untuk mengakses cPanelService dari luar
  CPanelService get cPanelService => _cPanelService;

  // MATERI OPERATIONS
  // Get semua materi
  Stream<List<Materi>> getMateri() {
    return _materiCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Materi.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get materi by ID
  Future<Materi> getMateriById(String id) async {
    DocumentSnapshot doc = await _materiCollection.doc(id).get();
    return Materi.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Method untuk upload multiple content images
  Future<String> processContentImages(String content, List<ContentImage> contentImages) async {
    String processedContent = content;
    
    print('Processing ${contentImages.length} content images');
    
    for (ContentImage contentImage in contentImages) {
      if (contentImage.file != null) {
        print('Uploading content image: ${contentImage.id}');
        
        // Upload image to cPanel
        String? uploadedUrl = await _cPanelService.uploadImage(contentImage.file!);
        if (uploadedUrl != null) {
          print('Content image uploaded successfully: $uploadedUrl');
          
          // Replace image marker with actual URL marker
          processedContent = processedContent.replaceAll(
            '[IMG:${contentImage.id}]',
            '[IMG_URL:$uploadedUrl]'
          );
        } else {
          print('Failed to upload content image: ${contentImage.id}');
          // Keep the original marker if upload fails
        }
      } else if (contentImage.imageUrl.isNotEmpty) {
        // Keep existing image URL for edit mode
        processedContent = processedContent.replaceAll(
          '[IMG:${contentImage.id}]',
          '[IMG_URL:${contentImage.imageUrl}]'
        );
      }
    }
    
    print('Content processing completed');
    return processedContent;
  }

  // Method untuk extract content images dari konten yang sudah ada (untuk edit mode)
  List<ContentImage> extractContentImages(String content) {
    List<ContentImage> images = [];
    
    // Extract existing image URLs
    RegExp urlRegex = RegExp(r'\[IMG_URL:(.*?)\]');
    Iterable<RegExpMatch> urlMatches = urlRegex.allMatches(content);
    
    int counter = 1;
    for (RegExpMatch match in urlMatches) {
      String imageUrl = match.group(1)!;
      String imageId = 'existing_img_${counter++}_${DateTime.now().millisecondsSinceEpoch}';
      
      images.add(ContentImage(
        id: imageId,
        imageUrl: imageUrl,
        file: null,
      ));
    }
    
    return images;
  }

  // Method untuk convert image URLs kembali ke markers untuk editing
  String convertUrlsToMarkers(String content, List<ContentImage> contentImages) {
    String convertedContent = content;
    
    for (ContentImage image in contentImages) {
      if (image.imageUrl.isNotEmpty) {
        convertedContent = convertedContent.replaceAll(
          '[IMG_URL:${image.imageUrl}]',
          '[IMG:${image.id}]'
        );
      }
    }
    
    return convertedContent;
  }

  // Add materi with multiple images
  Future<void> addMateriWithImages(Materi materi, File? gambar, List<ContentImage> contentImages) async {
    String gambarUrl = materi.gambarUrl;

    // Upload gambar utama jika ada
    if (gambar != null) {
      print('Uploading main materi image to cPanel...');
      String? uploadedUrl = await _cPanelService.uploadImage(gambar);
      if (uploadedUrl != null) {
        print('Main materi image uploaded successfully, URL: $uploadedUrl');
        gambarUrl = uploadedUrl;
      } else {
        print('Failed to upload main materi image to cPanel');
      }
    }

    // Process content images
    String processedContent = await processContentImages(materi.konten, contentImages);

    // Create materi with processed content
    print('Saving materi with processed content and image URL: $gambarUrl');
    await _materiCollection.add({
      'judul': materi.judul,
      'deskripsi': materi.deskripsi,
      'gambarUrl': gambarUrl,
      'konten': processedContent,
      'capaianPembelajaran': materi.capaianPembelajaran,
      'tujuanPembelajaran': materi.tujuanPembelajaran,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update materi with multiple images
  Future<void> updateMateriWithImages(Materi materi, File? gambar, List<ContentImage> contentImages) async {
    String gambarUrl = materi.gambarUrl;

    // Upload gambar utama baru jika ada
    if (gambar != null) {
      print('Updating main materi image on cPanel...');
      String? uploadedUrl = await _cPanelService.uploadImage(gambar);
      if (uploadedUrl != null) {
        print('Main materi image updated successfully, URL: $uploadedUrl');
        gambarUrl = uploadedUrl;
      } else {
        print('Failed to update main materi image on cPanel');
      }
    }

    // Process content images
    String processedContent = await processContentImages(materi.konten, contentImages);

    print('Updating materi with processed content and image URL: $gambarUrl');
    await _materiCollection.doc(materi.id).update({
      'judul': materi.judul,
      'deskripsi': materi.deskripsi,
      'gambarUrl': gambarUrl,
      'konten': processedContent,
      'capaianPembelajaran': materi.capaianPembelajaran,
      'tujuanPembelajaran': materi.tujuanPembelajaran,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Tambah materi baru (backward compatibility)
  Future<void> addMateri(Materi materi, File? gambar) async {
    // Use the new method with empty content images list
    await addMateriWithImages(materi, gambar, []);
  }

  // Update materi (backward compatibility)
  Future<void> updateMateri(Materi materi, File? gambar) async {
    // Use the new method with empty content images list
    await updateMateriWithImages(materi, gambar, []);
  }

  // Hapus materi
  Future<void> deleteMateri(String id) async {
    await _materiCollection.doc(id).delete();
  }

  // VIDEO OPERATIONS
  // Get semua video
  Stream<List<Video>> getVideos() {
    return _videoCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Video.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get video by ID
  Future<Video> getVideoById(String id) async {
    DocumentSnapshot doc = await _videoCollection.doc(id).get();
    return Video.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  // Tambah video baru
  Future<void> addVideo(Video video, File? thumbnail) async {
    String thumbnailUrl = video.thumbnailUrl;

    // Upload thumbnail jika ada
    if (thumbnail != null) {
      String? uploadedUrl = await _cPanelService.uploadImage(thumbnail);
      if (uploadedUrl != null) {
        thumbnailUrl = uploadedUrl;
      }
    }

    await _videoCollection.add({
      'judul': video.judul,
      'deskripsi': video.deskripsi,
      'youtubeUrl': video.youtubeUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update video
  Future<void> updateVideo(Video video, File? thumbnail) async {
    String thumbnailUrl = video.thumbnailUrl;

    // Upload thumbnail baru jika ada
    if (thumbnail != null) {
      String? uploadedUrl = await _cPanelService.uploadImage(thumbnail);
      if (uploadedUrl != null) {
        thumbnailUrl = uploadedUrl;
      }
    }

    await _videoCollection.doc(video.id).update({
      'judul': video.judul,
      'deskripsi': video.deskripsi,
      'youtubeUrl': video.youtubeUrl,
      'thumbnailUrl': thumbnailUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Hapus video
  Future<void> deleteVideo(String id) async {
    await _videoCollection.doc(id).delete();
  }

  // EVALUASI OPERATIONS
  // Get semua evaluasi
  Stream<List<Evaluasi>> getEvaluasi() {
    return _evaluasiCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Evaluasi.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get evaluasi by ID
  Future<Evaluasi> getEvaluasiById(String id) async {
    print("Getting evaluasi by ID: $id");
    DocumentSnapshot doc = await _evaluasiCollection.doc(id).get();
    if (!doc.exists) {
      print("Evaluasi with ID $id does not exist");
      throw Exception("Evaluasi tidak ditemukan");
    }
    
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    print("Raw evaluasi data: $data");
    
    Evaluasi evaluasi = Evaluasi.fromMap(data, doc.id);
    print("Evaluasi loaded: ${evaluasi.judul}, soalIds: ${evaluasi.soalIds}");
    return evaluasi;
  }

  // Tambah evaluasi baru
  Future<String> addEvaluasi(Evaluasi evaluasi) async {
    print("Adding new evaluasi: ${evaluasi.judul}");
    print("with soalIds: ${evaluasi.soalIds}");
    
    DocumentReference docRef = await _evaluasiCollection.add({
      'judul': evaluasi.judul,
      'deskripsi': evaluasi.deskripsi,
      'soalIds': evaluasi.soalIds,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    print("New evaluasi created with ID: ${docRef.id}");
    
    // Verify the data was saved correctly
    DocumentSnapshot verifyDoc = await docRef.get();
    Map<String, dynamic> data = verifyDoc.data() as Map<String, dynamic>;
    List<String> savedSoalIds = List<String>.from(data['soalIds'] ?? []);
    print("Verified saved soalIds: $savedSoalIds");
    
    return docRef.id;
  }

  // Update evaluasi
  Future<void> updateEvaluasi(Evaluasi evaluasi) async {
    print("Updating evaluasi with ID: ${evaluasi.id}");
    print("soalIds to update: ${evaluasi.soalIds}");
    
    try {
      await _evaluasiCollection.doc(evaluasi.id).update({
        'judul': evaluasi.judul,
        'deskripsi': evaluasi.deskripsi,
        'soalIds': evaluasi.soalIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print("Evaluasi updated successfully");
      
      // Verify that the update was successful
      DocumentSnapshot updatedDoc = await _evaluasiCollection.doc(evaluasi.id).get();
      Map<String, dynamic> data = updatedDoc.data() as Map<String, dynamic>;
      List<String> updatedSoalIds = List<String>.from(data['soalIds'] ?? []);
      print("Verified soalIds after update: $updatedSoalIds");
    } catch (e) {
      print("Error updating evaluasi: $e");
      throw e;
    }
  }

  // Hapus evaluasi
  Future<void> deleteEvaluasi(String id) async {
    print("Deleting evaluasi with ID: $id");
    
    // Get evaluasi untuk mendapatkan soalIds
    Evaluasi evaluasi = await getEvaluasiById(id);
    print("Found evaluasi with ${evaluasi.soalIds.length} soal to delete");
    
    // Hapus semua soal yang terkait
    for (String soalId in evaluasi.soalIds) {
      print("Deleting related soal: $soalId");
      try {
        await _soalCollection.doc(soalId).delete();
        print("Soal $soalId deleted successfully");
      } catch (e) {
        print("Error deleting soal $soalId: $e");
        // Continue with other deletions even if one fails
      }
    }
    
    // Hapus evaluasi
    await _evaluasiCollection.doc(id).delete();
    print("Evaluasi $id deleted successfully");
  }

  // SOAL OPERATIONS
  // Get soal by ID
  Future<Soal> getSoalById(String id) async {
    print("Getting soal by ID: $id");
    DocumentSnapshot doc = await _soalCollection.doc(id).get();
    
    if (!doc.exists) {
      print("Soal with ID $id does not exist");
      throw Exception("Soal tidak ditemukan");
    }
    
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    print("Raw soal data: $data");
    
    Soal soal = Soal.fromMap(data, doc.id);
    print("Soal loaded: ${soal.pertanyaan}");
    return soal;
  }

  // Get soal dari evaluasi
  Future<List<Soal>> getSoalFromEvaluasi(String evaluasiId) async {
    print("Getting soal from evaluasi with ID: $evaluasiId");
    
    Evaluasi evaluasi = await getEvaluasiById(evaluasiId);
    print("Jumlah soalIds dalam evaluasi: ${evaluasi.soalIds.length}");
    print("soalIds: ${evaluasi.soalIds}");
    
    List<Soal> soalList = [];
    
    for (String soalId in evaluasi.soalIds) {
      try {
        print("Loading soal with ID: $soalId");
        Soal soal = await getSoalById(soalId);
        soalList.add(soal);
        print("Added soal to list: ${soal.pertanyaan}");
      } catch (e) {
        print("Error loading soal $soalId: $e");
        // Continue with other soal even if one fails
      }
    }
    
    print("Total soal loaded: ${soalList.length}");
    return soalList;
  }

  // Tambah soal baru
  Future<String> addSoal(Soal soal, File? gambar) async {
    print("Adding new soal: ${soal.pertanyaan}");
    
    String gambarUrl = soal.gambarUrl ?? '';

    // Upload gambar jika ada
    if (gambar != null) {
      print("Uploading soal image");
      String? uploadedUrl = await _cPanelService.uploadImage(gambar);
      if (uploadedUrl != null) {
        gambarUrl = uploadedUrl;
        print("Image uploaded successfully: $gambarUrl");
      } else {
        print("Failed to upload image");
      }
    }

    // Create soal document
    DocumentReference docRef = await _soalCollection.add({
      'pertanyaan': soal.pertanyaan,
      'opsi': soal.opsi,
      'jawabanBenar': soal.jawabanBenar,
      'gambarUrl': gambarUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    print("New soal created with ID: ${docRef.id}");
    
    // Verify the soal was created correctly
    DocumentSnapshot verifyDoc = await docRef.get();
    Map<String, dynamic> data = verifyDoc.data() as Map<String, dynamic>;
    print("Verified soal data: $data");
    
    return docRef.id;
  }

  // Update soal
  Future<void> updateSoal(Soal soal, File? gambar) async {
    print("Updating soal with ID: ${soal.id}");
    
    String gambarUrl = soal.gambarUrl ?? '';

    // Upload gambar baru jika ada
    if (gambar != null) {
      print("Uploading new soal image");
      String? uploadedUrl = await _cPanelService.uploadImage(gambar);
      if (uploadedUrl != null) {
        gambarUrl = uploadedUrl;
        print("New image uploaded successfully: $gambarUrl");
      } else {
        print("Failed to upload new image");
      }
    }

    // Update soal document
    await _soalCollection.doc(soal.id).update({
      'pertanyaan': soal.pertanyaan,
      'opsi': soal.opsi,
      'jawabanBenar': soal.jawabanBenar,
      'gambarUrl': gambarUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    print("Soal updated successfully");
    
    // Verify the update was successful
    DocumentSnapshot updatedDoc = await _soalCollection.doc(soal.id).get();
    Map<String, dynamic> data = updatedDoc.data() as Map<String, dynamic>;
    print("Verified updated soal data: $data");
  }

  // Hapus soal
  Future<void> deleteSoal(String id) async {
    print("Deleting soal with ID: $id");
    await _soalCollection.doc(id).delete();
    print("Soal deleted successfully");
  }

  // Method baru: menambahkan soal ke evaluasi
  Future<void> addSoalToEvaluasi(String evaluasiId, String soalId) async {
    print("Adding soal $soalId to evaluasi $evaluasiId");
    
    try {
      // Get evaluasi saat ini
      Evaluasi evaluasi = await getEvaluasiById(evaluasiId);
      
      // Tambahkan soalId ke array soalIds jika belum ada
      List<String> updatedSoalIds = List<String>.from(evaluasi.soalIds);
      if (!updatedSoalIds.contains(soalId)) {
        updatedSoalIds.add(soalId);
        print("Added soalId to array: $soalId");
        
        // Update dokumen evaluasi
        await _evaluasiCollection.doc(evaluasiId).update({
          'soalIds': updatedSoalIds,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        print("Evaluasi updated with new soalId");
        
        // Verify the update
        DocumentSnapshot updatedDoc = await _evaluasiCollection.doc(evaluasiId).get();
        Map<String, dynamic> data = updatedDoc.data() as Map<String, dynamic>;
        List<String> verifiedSoalIds = List<String>.from(data['soalIds'] ?? []);
        print("Verified updated soalIds: $verifiedSoalIds");
      } else {
        print("SoalId already exists in evaluasi, no update needed");
      }
    } catch (e) {
      print("Error adding soal to evaluasi: $e");
      throw e;
    }
  }
  
  // Method baru: menghapus soal dari evaluasi
  Future<void> removeSoalFromEvaluasi(String evaluasiId, String soalId) async {
    print("Removing soal $soalId from evaluasi $evaluasiId");
    
    try {
      // Get evaluasi saat ini
      Evaluasi evaluasi = await getEvaluasiById(evaluasiId);
      
      // Hapus soalId dari array soalIds
      List<String> updatedSoalIds = List<String>.from(evaluasi.soalIds);
      updatedSoalIds.remove(soalId);
      print("Removed soalId from array: $soalId");
      
      // Update dokumen evaluasi
      await _evaluasiCollection.doc(evaluasiId).update({
        'soalIds': updatedSoalIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print("Evaluasi updated after removing soalId");
      
      // Verify the update
      DocumentSnapshot updatedDoc = await _evaluasiCollection.doc(evaluasiId).get();
      Map<String, dynamic> data = updatedDoc.data() as Map<String, dynamic>;
      List<String> verifiedSoalIds = List<String>.from(data['soalIds'] ?? []);
      print("Verified updated soalIds after removal: $verifiedSoalIds");
    } catch (e) {
      print("Error removing soal from evaluasi: $e");
      throw e;
    }
  }

  // ==================== LKPD OPERATIONS ====================

  // Get semua LKPD
  Stream<List<LKPD>> getLKPD() {
    return _lkpdCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LKPD.fromFirestore(doc))
            .toList());
  }

  // Get LKPD by ID
  Future<LKPD?> getLKPDById(String id) async {
    try {
      final doc = await _lkpdCollection.doc(id).get();
      if (doc.exists) {
        return LKPD.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting LKPD: $e');
      return null;
    }
  }

  // Add LKPD dengan upload gambar
  Future<String> addLKPD(LKPD lkpd, File? gambar) async {
    try {
      String gambarUrl = lkpd.gambarUrl;

      // Upload gambar utama jika ada
      if (gambar != null) {
        print('Uploading LKPD image to cPanel...');
        String? uploadedUrl = await _cPanelService.uploadImage(gambar);
        if (uploadedUrl != null) {
          print('LKPD image uploaded successfully: $uploadedUrl');
          gambarUrl = uploadedUrl;
        } else {
          print('Failed to upload LKPD image');
        }
      }

      // Upload gambar untuk setiap kegiatan jika ada
      List<Kegiatan> updatedKegiatanList = [];
      for (Kegiatan kegiatan in lkpd.kegiatanList) {
        String kegiatanGambarUrl = kegiatan.gambarUrl ?? '';
        
        // Untuk sekarang kita simpan URL yang sudah ada
        // Implementasi upload gambar kegiatan akan ditambahkan di form
        
        updatedKegiatanList.add(Kegiatan(
          id: kegiatan.id,
          judul: kegiatan.judul,
          instruksi: kegiatan.instruksi,
          type: kegiatan.type,
          pertanyaanPemandu: kegiatan.pertanyaanPemandu,
          gambarUrl: kegiatanGambarUrl,
          estimasiWaktu: kegiatan.estimasiWaktu,
        ));
      }

      // Create LKPD document
      DocumentReference docRef = await _lkpdCollection.add({
        'judul': lkpd.judul,
        'deskripsi': lkpd.deskripsi,
        'gambarUrl': gambarUrl,
        'kegiatanList': updatedKegiatanList.map((kegiatan) => kegiatan.toMap()).toList(),
        'rubrikPenilaian': lkpd.rubrikPenilaian,
        'estimasiWaktu': lkpd.estimasiWaktu,
        'kompetensiDasar': lkpd.kompetensiDasar,
        'indikatorPencapaian': lkpd.indikatorPencapaian,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('LKPD created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding LKPD: $e');
      throw Exception('Gagal menambahkan LKPD: $e');
    }
  }

  // Add LKPD tanpa file (untuk sample data)
  Future<String> addLKPDData(LKPD lkpd) async {
    try {
      DocumentReference docRef = await _lkpdCollection.add(lkpd.toMap());
      print('LKPD data created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error adding LKPD data: $e');
      throw Exception('Gagal menambahkan LKPD: $e');
    }
  }

  // Update LKPD dengan upload gambar
  Future<void> updateLKPD(LKPD lkpd, File? gambar) async {
    try {
      String gambarUrl = lkpd.gambarUrl;

      // Upload gambar utama baru jika ada
      if (gambar != null) {
        print('Uploading new LKPD image to cPanel...');
        String? uploadedUrl = await _cPanelService.uploadImage(gambar);
        if (uploadedUrl != null) {
          print('LKPD image updated successfully: $uploadedUrl');
          gambarUrl = uploadedUrl;
        } else {
          print('Failed to upload new LKPD image');
        }
      }

      // Process kegiatan list
      List<Kegiatan> updatedKegiatanList = [];
      for (Kegiatan kegiatan in lkpd.kegiatanList) {
        String kegiatanGambarUrl = kegiatan.gambarUrl ?? '';
        
        // Implementasi upload gambar kegiatan akan ditambahkan di form
        
        updatedKegiatanList.add(Kegiatan(
          id: kegiatan.id,
          judul: kegiatan.judul,
          instruksi: kegiatan.instruksi,
          type: kegiatan.type,
          pertanyaanPemandu: kegiatan.pertanyaanPemandu,
          gambarUrl: kegiatanGambarUrl,
          estimasiWaktu: kegiatan.estimasiWaktu,
        ));
      }

      // Update LKPD document
      await _lkpdCollection.doc(lkpd.id).update({
        'judul': lkpd.judul,
        'deskripsi': lkpd.deskripsi,
        'gambarUrl': gambarUrl,
        'kegiatanList': updatedKegiatanList.map((kegiatan) => kegiatan.toMap()).toList(),
        'rubrikPenilaian': lkpd.rubrikPenilaian,
        'estimasiWaktu': lkpd.estimasiWaktu,
        'kompetensiDasar': lkpd.kompetensiDasar,
        'indikatorPencapaian': lkpd.indikatorPencapaian,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('LKPD updated successfully');
    } catch (e) {
      print('Error updating LKPD: $e');
      throw Exception('Gagal mengupdate LKPD: $e');
    }
  }

  // Delete LKPD
  Future<void> deleteLKPD(String id) async {
    try {
      // Get LKPD untuk hapus gambar yang terkait
      final lkpd = await getLKPDById(id);
      
      if (lkpd != null) {
        // Hapus gambar utama jika ada
        if (lkpd.gambarUrl.isNotEmpty) {
          // Implementasi hapus gambar dari cPanel bisa ditambahkan nanti
          print('Should delete main image: ${lkpd.gambarUrl}');
        }
        
        // Hapus gambar kegiatan jika ada
        for (final kegiatan in lkpd.kegiatanList) {
          if (kegiatan.gambarUrl != null && kegiatan.gambarUrl!.isNotEmpty) {
            print('Should delete kegiatan image: ${kegiatan.gambarUrl}');
          }
        }
      }
      
      // Hapus document LKPD
      await _lkpdCollection.doc(id).delete();
      print('LKPD deleted successfully');
    } catch (e) {
      print('Error deleting LKPD: $e');
      throw Exception('Gagal menghapus LKPD: $e');
    }
  }

  // Method untuk upload gambar kegiatan
  Future<String> uploadKegiatanImage(File imageFile, String lkpdId, String kegiatanId) async {
    try {
      String? uploadedUrl = await _cPanelService.uploadImage(imageFile);
      if (uploadedUrl != null) {
        print('Kegiatan image uploaded successfully: $uploadedUrl');
        return uploadedUrl;
      } else {
        throw Exception('Failed to upload kegiatan image');
      }
    } catch (e) {
      print('Error uploading kegiatan image: $e');
      throw Exception('Gagal mengupload gambar kegiatan: $e');
    }
  }

  // Preload LKPD - method untuk membuat sample data
  Future<void> preloadLKPD() async {
    try {
      // Cek apakah sudah ada LKPD
      final QuerySnapshot snapshot = await _lkpdCollection.limit(1).get();
      
      if (snapshot.docs.isEmpty) {
        // Buat sample LKPD
        final sampleLKPD = LKPD(
          id: '',
          judul: 'LKPD 1: Mengenal Hak dan Kewajiban',
          deskripsi: 'Lembar kerja untuk memahami konsep dasar hak dan kewajiban dalam kehidupan sehari-hari',
          gambarUrl: '',
          kompetensiDasar: '3.2 Menganalisis pelaksanaan kewajiban, hak, dan tanggung jawab sebagai warga negara beserta dampaknya dalam kehidupan sehari-hari',
          indikatorPencapaian: 'Siswa dapat mengidentifikasi dan menganalisis hak dan kewajiban di lingkungan rumah, sekolah, dan masyarakat',
          rubrikPenilaian: '''
Kriteria Penilaian:
• Sangat Baik (90-100): Mampu mengidentifikasi dan menganalisis dengan tepat dan lengkap
• Baik (80-89): Mampu mengidentifikasi dan menganalisis dengan tepat
• Cukup (70-79): Mampu mengidentifikasi dengan tepat namun analisis kurang lengkap
• Perlu Bimbingan (<70): Masih memerlukan bimbingan dalam mengidentifikasi dan menganalisis
          ''',
          estimasiWaktu: 90,
          kegiatanList: [
            Kegiatan(
              id: 'kegiatan1',
              judul: 'Observasi Hak dan Kewajiban di Rumah',
              instruksi: 'Amati kegiatan di rumahmu selama satu hari. Identifikasi hak dan kewajiban yang kamu miliki sebagai anggota keluarga.',
              type: KegiatanType.observasi,
              estimasiWaktu: 30,
              pertanyaanPemandu: [
                'Apa saja hak yang kamu miliki di rumah?',
                'Apa saja kewajiban yang harus kamu lakukan di rumah?',
                'Mengapa penting untuk melaksanakan kewajiban di rumah?',
                'Apa yang terjadi jika hak dan kewajiban tidak seimbang?'
              ],
            ),
            Kegiatan(
              id: 'kegiatan2',
              judul: 'Analisis Kasus Pelanggaran Hak',
              instruksi: 'Baca kasus yang diberikan dan analisis pelanggaran hak yang terjadi serta dampaknya.',
              type: KegiatanType.analisis,
              estimasiWaktu: 30,
              pertanyaanPemandu: [
                'Hak apa yang dilanggar dalam kasus tersebut?',
                'Siapa yang bertanggung jawab melindungi hak tersebut?',
                'Apa dampak dari pelanggaran hak tersebut?',
                'Bagaimana cara mencegah pelanggaran serupa?'
              ],
            ),
            Kegiatan(
              id: 'kegiatan3',
              judul: 'Refleksi dan Komitmen',
              instruksi: 'Buatlah refleksi tentang pembelajaran hari ini dan komitmenmu dalam melaksanakan hak dan kewajiban.',
              type: KegiatanType.refleksi,
              estimasiWaktu: 30,
              pertanyaanPemandu: [
                'Apa hal baru yang kamu pelajari hari ini?',
                'Bagaimana kamu akan menerapkan pengetahuan ini dalam kehidupan sehari-hari?',
                'Komitmen apa yang akan kamu buat untuk menjadi warga yang bertanggung jawab?'
              ],
            ),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await addLKPDData(sampleLKPD);
        print('Sample LKPD created successfully');
      } else {
        print('LKPD data already exists');
      }
    } catch (e) {
      print('Error preloading LKPD: $e');
    }
  }

  // ADMIN PASSWORD OPERATIONS
  // PERBAIKAN: Verifikasi password admin yang lebih robust
  Future<bool> verifyAdminPassword(String password) async {
    try {
      print('Verifikasi password dimulai');
      print('Mencoba verifikasi dengan Firebase');
      
      // Periksa apakah koleksi settings dan dokumen admin sudah ada
      DocumentSnapshot doc = await _firestore.collection('settings').doc('admin').get();
      
      // Cek jika dokumen tidak ada atau null
      if (!doc.exists) {
        print('Dokumen admin tidak ditemukan, menjalankan setup password...');
        await setupAdminPassword();
        // Ambil dokumen yang baru dibuat
        doc = await _firestore.collection('settings').doc('admin').get();
      }
      
      // Cek jika data masih null (seharusnya tidak terjadi setelah setup)
      if (doc.data() == null) {
        print('Data admin masih null setelah setup, melakukan setup ulang...');
        await _firestore.collection('settings').doc('admin').set({
          'password': 'admin123', // Default password
        });
        doc = await _firestore.collection('settings').doc('admin').get();
      }
      
      // Sekarang kita yakin data tidak null
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String storedPassword = data['password'] ?? '';
      
      print('Data admin ditemukan, password tersimpan ada');
      bool result = password == storedPassword;
      print('Hasil verifikasi: $result');
      
      return result;
    } catch (e) {
      print('Error verifying admin password: $e');
      
      // Jika error disebabkan oleh masalah cast, buat dokumen admin
      if (e.toString().contains("type 'Null' is not a subtype of type 'Map<String, dynamic>'")) {
        print('Error cast data, mencoba membuat dokumen admin baru...');
        try {
          await _firestore.collection('settings').doc('admin').set({
            'password': 'admin123', // Default password
          });
          print('Dokumen admin berhasil dibuat');
          
          // Coba verifikasi lagi
          if (password == 'admin123') {
            return true;
          }
        } catch (setupError) {
          print('Gagal membuat dokumen admin: $setupError');
        }
      }
      return false;
    }
  }

  // Set password admin (default jika belum ada)
  Future<void> setupAdminPassword() async {
    try {
      print('Setting up admin password...');
      DocumentSnapshot doc = await _firestore.collection('settings').doc('admin').get();
      
      if (!doc.exists) {
        print('Dokumen admin tidak ada, membuat baru...');
        await _firestore.collection('settings').doc('admin').set({
          'password': 'admin123', // Default password
        });
        print('Dokumen admin berhasil dibuat dengan password default');
      } else {
        print('Dokumen admin sudah ada');
      }
    } catch (e) {
      print('Error setting up admin password: $e');
      
      // Jika terjadi error, coba buat ulang dokumen
      try {
        print('Mencoba ulang membuat dokumen admin...');
        await _firestore.collection('settings').doc('admin').set({
          'password': 'admin123', // Default password
        });
        print('Dokumen admin berhasil dibuat pada percobaan ulang');
      } catch (retryError) {
        print('Gagal membuat dokumen admin pada percobaan ulang: $retryError');
      }
    }
  }

  // Update password admin
  Future<void> updateAdminPassword(String newPassword) async {
    try {
      print('Updating admin password...');
      await _firestore.collection('settings').doc('admin').update({
        'password': newPassword,
      });
      print('Admin password updated successfully');
    } catch (e) {
      print('Error updating admin password: $e');
      
      // Jika dokumen tidak ada, buat baru
      if (e.toString().contains('not found')) {
        print('Dokumen admin tidak ditemukan, membuat baru dengan password yang diupdate');
        await _firestore.collection('settings').doc('admin').set({
          'password': newPassword,
        });
        print('Dokumen admin baru dibuat dengan password yang diupdate');
      }
    }
  }

  // PRELOAD METHODS
  // Tambahkan method ini ke FirebaseService
  Future<void> preloadVideos() async {
    try {
      await _videoCollection.get();
      print('Video data preloaded');
    } catch (e) {
      print('Error preloading videos: $e');
    }
  }

  Future<void> preloadMateri() async {
    try {
      await _materiCollection.get();
      print('Materi data preloaded');
    } catch (e) {
      print('Error preloading materi: $e');
    }
  }
  
  // Metode untuk melakukan inisialisasi awal database
  Future<void> initializeDatabase() async {
    print('Initializing Firebase Database...');
    try {
      // Setup admin password
      await setupAdminPassword();
      
      // Pastikan koleksi-koleksi dasar sudah ada
      await _firestore.collection('materi').limit(1).get();
      await _firestore.collection('video').limit(1).get();
      await _firestore.collection('evaluasi').limit(1).get();
      await _firestore.collection('soal').limit(1).get();
      await _firestore.collection('lkpd').limit(1).get(); // Tambah LKPD
      
      print('Database initialized successfully');
    } catch (e) {
      print('Error initializing database: $e');
    }
  }

  // IDENTITAS OPERATIONS
  // Get Identitas
  Future<Identitas?> getIdentitas() async {
    try {
      QuerySnapshot querySnapshot = await _identitasCollection.limit(1).get();
      
      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = querySnapshot.docs.first;
        return Identitas.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      
      return null;
    } catch (e) {
      print('Error getting identitas: $e');
      return null;
    }
  }

  // Tambah atau Update Identitas
  Future<void> saveIdentitas(Identitas identitas, {File? fotoMahasiswa, File? fotoDospem1, File? fotoDospem2}) async {
    try {
      // Upload foto mahasiswa jika ada
      String fotoMahasiswaUrl = identitas.fotoMahasiswaUrl;
      if (fotoMahasiswa != null) {
        String? uploadedUrl = await _cPanelService.uploadImage(fotoMahasiswa);
        if (uploadedUrl != null) {
          fotoMahasiswaUrl = uploadedUrl;
        }
      }
      
      // Upload foto dosen pembimbing 1 jika ada
      String fotoDospem1Url = identitas.fotoDospem1Url;
      if (fotoDospem1 != null) {
        String? uploadedUrl = await _cPanelService.uploadImage(fotoDospem1);
        if (uploadedUrl != null) {
          fotoDospem1Url = uploadedUrl;
        }
      }
      
      // Upload foto dosen pembimbing 2 jika ada
      String? fotoDospem2Url = identitas.fotoDospem2Url;
      if (fotoDospem2 != null) {
        String? uploadedUrl = await _cPanelService.uploadImage(fotoDospem2);
        if (uploadedUrl != null) {
          fotoDospem2Url = uploadedUrl;
        }
      }
      
      // Data untuk disimpan
      Map<String, dynamic> data = {
        'namaMahasiswa': identitas.namaMahasiswa,
        'nimMahasiswa': identitas.nimMahasiswa,
        'prodiMahasiswa': identitas.prodiMahasiswa,
        'fotoMahasiswaUrl': fotoMahasiswaUrl,
        'namaDospem1': identitas.namaDospem1,
        'nipDospem1': identitas.nipDospem1,
        'fotoDospem1Url': fotoDospem1Url,
        'namaDospem2': identitas.namaDospem2,
        'nipDospem2': identitas.nipDospem2,
        'fotoDospem2Url': fotoDospem2Url,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Cek apakah ada dokumen identitas atau tidak
      if (identitas.id.isEmpty) {
        // Tambah data baru jika belum ada
        data['createdAt'] = FieldValue.serverTimestamp();
        await _identitasCollection.add(data);
      } else {
        // Update data yang sudah ada
        await _identitasCollection.doc(identitas.id).update(data);
      }
      
      print('Identitas saved successfully');
    } catch (e) {
      print('Error saving identitas: $e');
      throw e;
    }
  }
}