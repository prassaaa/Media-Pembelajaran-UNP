import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/app_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

// Model class untuk content images
class ContentImage {
  final String id;
  final String imageUrl;
  final File? file;

  ContentImage({
    required this.id,
    required this.imageUrl,
    this.file,
  });

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

class AdminMateriForm extends StatefulWidget {
  const AdminMateriForm({Key? key}) : super(key: key);

  @override
  State<AdminMateriForm> createState() => _AdminMateriFormState();
}

class _AdminMateriFormState extends State<AdminMateriForm> {
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _capaianPembelajaranController = TextEditingController();
  final TextEditingController _tujuanPembelajaranController = TextEditingController();
  final TextEditingController _kontenController = TextEditingController();

  bool _isEditMode = false;
  bool _isLoading = false;
  bool _isImageLoading = false;
  String _materiId = '';
  File? _gambarFile;
  String _gambarUrl = '';
  
  // Untuk multiple images dalam konten
  List<ContentImage> _contentImages = [];
  int _imageCounter = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Materi) {
      // Edit mode
      _isEditMode = true;
      _materiId = args.id;
      _judulController.text = args.judul;
      _deskripsiController.text = args.deskripsi;
      _capaianPembelajaranController.text = args.capaianPembelajaran;
      _tujuanPembelajaranController.text = args.tujuanPembelajaran;
      _kontenController.text = args.konten;
      _gambarUrl = args.gambarUrl;
      
      // Parse existing content images dari konten
      _parseExistingContentImages(args.konten);
    }
  }

  void _parseExistingContentImages(String konten) {
    // Parse konten untuk mencari image markers [IMG_URL:url]
    RegExp imageRegex = RegExp(r'\[IMG_URL:(.*?)\]');
    Iterable<RegExpMatch> matches = imageRegex.allMatches(konten);
    
    int counter = 1;
    for (RegExpMatch match in matches) {
      String imageUrl = match.group(1)!;
      String imageId = 'existing_img_${counter++}_${DateTime.now().millisecondsSinceEpoch}';
      
      _contentImages.add(ContentImage(
        id: imageId,
        imageUrl: imageUrl,
        file: null,
      ));
      
      // Replace URL marker dengan ID marker untuk editing
      _kontenController.text = _kontenController.text.replaceAll(
        '[IMG_URL:$imageUrl]',
        '[IMG:$imageId]'
      );
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _capaianPembelajaranController.dispose();
    _tujuanPembelajaranController.dispose();
    _kontenController.dispose();
    super.dispose();
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pilih Sumber Gambar',
                  style: AppTheme.subtitleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'Galeri',
                      onTap: () async {
                        Navigator.pop(context);
                        final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                        if (pickedFile != null) {
                          setState(() {
                            _gambarFile = File(pickedFile.path);
                          });
                        }
                      },
                    ),
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Kamera',
                      onTap: () async {
                        Navigator.pop(context);
                        final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
                        if (pickedFile != null) {
                          setState(() {
                            _gambarFile = File(pickedFile.path);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContentImagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tambah Gambar ke Konten',
                  style: AppTheme.subtitleLarge,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Gambar akan disisipkan di posisi kursor',
                    style: AppTheme.bodySmall.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'Galeri',
                      onTap: () async {
                        Navigator.pop(context);
                        await _addContentImage(ImageSource.gallery);
                      },
                    ),
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Kamera',
                      onTap: () async {
                        Navigator.pop(context);
                        await _addContentImage(ImageSource.camera);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addContentImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        String imageId = 'img_${_imageCounter++}_${DateTime.now().millisecondsSinceEpoch}';
        
        ContentImage newImage = ContentImage(
          id: imageId,
          imageUrl: '',
          file: File(pickedFile.path),
        );
        
        setState(() {
          _contentImages.add(newImage);
        });
        
        // Insert image marker at cursor position
        _insertImageMarker(imageId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gambar ditambahkan dengan ID: $imageId'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambah gambar: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _insertImageMarker(String imageId) {
    final TextEditingController controller = _kontenController;
    final int cursorPosition = controller.selection.baseOffset;
    final String currentText = controller.text;
    
    String newText;
    if (cursorPosition >= 0) {
      // Insert at cursor position
      newText = currentText.substring(0, cursorPosition) +
          '\n[IMG:$imageId]\n' +
          currentText.substring(cursorPosition);
    } else {
      // Append at end
      newText = currentText + '\n[IMG:$imageId]\n';
    }
    
    controller.text = newText;
    
    // Set cursor position after the inserted marker
    int newCursorPosition = cursorPosition >= 0 
        ? cursorPosition + imageId.length + 8 // 8 = length of '[IMG:]' + 2 newlines
        : newText.length;
    
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: newCursorPosition),
    );
  }

  void _removeContentImage(String imageId) {
    setState(() {
      _contentImages.removeWhere((img) => img.id == imageId);
    });
    
    // Remove image marker from content
    String currentText = _kontenController.text;
    String updatedText = currentText.replaceAll('[IMG:$imageId]', '');
    _kontenController.text = updatedText;
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Gambar dihapus dari konten'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
    }
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMateri() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Process content images first
      String processedContent = await _processContentImages();
      
      final judul = _judulController.text;
      final deskripsi = _deskripsiController.text;
      final capaianPembelajaran = _capaianPembelajaranController.text;
      final tujuanPembelajaran = _tujuanPembelajaranController.text;

      if (_isEditMode) {
        // Update materi
        final Materi materi = Materi(
          id: _materiId,
          judul: judul,
          deskripsi: deskripsi,
          gambarUrl: _gambarUrl,
          konten: processedContent,
          capaianPembelajaran: capaianPembelajaran,
          tujuanPembelajaran: tujuanPembelajaran,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firebaseService.updateMateriWithImages(materi, _gambarFile, _contentImages);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Materi berhasil diperbarui'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Add new materi
        final Materi materi = Materi(
          id: '',
          judul: judul,
          deskripsi: deskripsi,
          gambarUrl: '',
          konten: processedContent,
          capaianPembelajaran: capaianPembelajaran,
          tujuanPembelajaran: tujuanPembelajaran,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firebaseService.addMateriWithImages(materi, _gambarFile, _contentImages);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Materi berhasil ditambahkan'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal ${_isEditMode ? 'memperbarui' : 'menambahkan'} materi: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _processContentImages() async {
    String processedContent = _kontenController.text;
    
    for (ContentImage contentImage in _contentImages) {
      if (contentImage.file != null) {
        // Upload image to cPanel
        String? uploadedUrl = await _firebaseService.cPanelService.uploadImage(contentImage.file!);
        if (uploadedUrl != null) {
          // Replace image marker with actual URL
          processedContent = processedContent.replaceAll(
            '[IMG:${contentImage.id}]',
            '[IMG_URL:$uploadedUrl]'
          );
        }
      } else if (contentImage.imageUrl.isNotEmpty) {
        // Keep existing image URL
        processedContent = processedContent.replaceAll(
          '[IMG:${contentImage.id}]',
          '[IMG_URL:${contentImage.imageUrl}]'
        );
      }
    }
    
    return processedContent;
  }

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
                  _isEditMode ? 'Edit Materi' : 'Tambah Materi',
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
                                Icons.menu_book_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isEditMode 
                                    ? 'Edit Materi Pembelajaran' 
                                    : 'Tambah Materi Pembelajaran Baru',
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
        body: _isLoading
            ? const LoadingWidget(message: 'Memproses data...')
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Form Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isEditMode ? Icons.edit_note : Icons.add_box,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isEditMode
                                    ? 'Edit materi pembelajaran yang sudah ada'
                                    : 'Tambahkan materi pembelajaran baru',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Judul Materi
                      TextFormField(
                        controller: _judulController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Materi',
                          hintText: 'Masukkan judul materi',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul materi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Capaian Pembelajaran
                      TextFormField(
                        controller: _capaianPembelajaranController,
                        decoration: const InputDecoration(
                          labelText: 'Capaian Pembelajaran',
                          hintText: 'Contoh:\n1. Peserta didik mampu menjelaskan konsep dasar\n2. Peserta didik dapat mengidentifikasi...',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Capaian pembelajaran tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tujuan Pembelajaran
                      TextFormField(
                        controller: _tujuanPembelajaranController,
                        decoration: const InputDecoration(
                          labelText: 'Tujuan Pembelajaran',
                          hintText: 'Contoh:\n1. Setelah mengikuti pembelajaran, peserta didik mampu...\n2. Peserta didik dapat mendemonstrasikan...',
                          prefixIcon: Icon(Icons.track_changes_outlined),
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tujuan pembelajaran tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi Materi
                      TextFormField(
                        controller: _deskripsiController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi Materi',
                          hintText: 'Masukkan deskripsi singkat materi',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Deskripsi materi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Gambar Utama Materi
                      Text(
                        'Gambar Utama Materi',
                        style: AppTheme.subtitleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _showImagePickerOptions,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppTheme.primaryColor.withOpacity(0.05),
                            border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: _isImageLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _gambarFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(
                                        _gambarFile!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : _gambarUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: CachedNetworkImage(
                                            imageUrl: _gambarUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                            errorWidget: (context, url, error) {
                                              return Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.broken_image,
                                                      size: 48,
                                                      color: AppTheme.primaryColor.withOpacity(0.7),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Gambar tidak dapat dimuat',
                                                      style: AppTheme.bodyMedium.copyWith(
                                                        color: AppTheme.primaryColor.withOpacity(0.7),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.add_photo_alternate,
                                                size: 48,
                                                color: AppTheme.primaryColor.withOpacity(0.7),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Tap untuk memilih gambar utama',
                                                style: AppTheme.bodyMedium.copyWith(
                                                  color: AppTheme.primaryColor.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppButton(
                        text: _gambarFile != null || _gambarUrl.isNotEmpty
                            ? 'Ganti Gambar Utama'
                            : 'Pilih Gambar Utama',
                        icon: Icons.image,
                        type: ButtonType.outlined,
                        onPressed: _showImagePickerOptions,
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 24),

                      // Konten Materi dengan Multiple Images - PERBAIKAN OVERFLOW
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Text(
                            'Konten Materi',
                            style: AppTheme.subtitleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Tombol-tombol aksi (DIPERBAIKI DARI ROW KE WRAP)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _showContentImagePicker,
                                icon: const Icon(Icons.add_photo_alternate, size: 16),
                                label: const Text(
                                  'Tambah Gambar',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.successColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  minimumSize: const Size(0, 36),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => _showFormattingGuide(context),
                                icon: const Icon(Icons.help_outline, size: 16),
                                label: const Text(
                                  'Panduan Format',
                                  style: TextStyle(fontSize: 12),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  minimumSize: const Size(0, 36),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Preview content images jika ada - JUGA DIPERBAIKI
                      if (_contentImages.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.successColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.photo_library,
                                    color: AppTheme.successColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Gambar dalam Konten (${_contentImages.length})',
                                      style: AppTheme.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.successColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: _contentImages
                                      .map((img) => Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: _buildContentImagePreview(img),
                                          ))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _kontenController,
                          decoration: InputDecoration(
                            hintText: 'Masukkan konten materi pembelajaran\n\nTips: \n• Gunakan [IMG:id] untuk menandai posisi gambar\n• # untuk judul besar\n• ## untuk subjudul\n• - atau * untuk poin\n• **teks** untuk huruf tebal\n• > untuk kutipan penting',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryColor,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          maxLines: 15,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konten materi tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Tombol Simpan
                      AppButton(
                        text: _isEditMode ? 'Perbarui Materi' : 'Simpan Materi',
                        icon: _isEditMode ? Icons.save : Icons.add,
                        onPressed: _saveMateri,
                        isLoading: _isLoading,
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildContentImagePreview(ContentImage img) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.successColor.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // Gambar
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: img.file != null
                  ? Image.file(
                      img.file!,
                      fit: BoxFit.cover,
                    )
                  : img.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: img.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image,
                            color: Colors.grey,
                            size: 24,
                          ),
                        ),
            ),
          ),
          
          // Tombol hapus
          Positioned(
            right: 2,
            top: 2,
            child: GestureDetector(
              onTap: () => _removeContentImage(img.id),
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppTheme.errorColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ),
          
          // ID Label
          Positioned(
            left: 2,
            bottom: 2,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 60), // PERBAIKAN: Batasi lebar
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                img.id.length > 8 ? img.id.substring(0, 6) + '..' : img.id.substring(0, 6),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis, // PERBAIKAN: Handle overflow text
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFormattingGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.format_list_bulleted, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Expanded(  // PERBAIKAN: Wrap dengan Expanded
                child: Text(
                  'Panduan Format Konten',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SizedBox(  // PERBAIKAN: Batasi ukuran dialog
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFormatExample('# Judul Besar', 'Untuk membuat judul utama'),
                  _buildFormatExample('## Sub Judul', 'Untuk membuat sub judul'),
                  _buildFormatExample('### Judul Kecil', 'Untuk membuat judul bagian'),
                  _buildFormatExample('- Poin 1\n- Poin 2', 'Untuk membuat daftar poin'),
                  _buildFormatExample('1. Nomor 1\n2. Nomor 2', 'Untuk membuat daftar bernomor'),
                  _buildFormatExample('**Teks Tebal**', 'Untuk membuat teks tebal'),
                  _buildFormatExample('> Kutipan penting', 'Untuk membuat kutipan/highlight'),
                  _buildFormatExample('[IMG:img_1]', 'Untuk menyisipkan gambar (otomatis saat tambah gambar)'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tips Gambar dalam Konten:',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• Klik "Tambah Gambar" untuk menyisipkan gambar di posisi kursor\n'
                          '• Marker [IMG:id] akan otomatis ditambahkan\n'
                          '• Anda bisa memindahkan marker ke posisi yang diinginkan\n'
                          '• Gambar akan muncul di posisi marker saat ditampilkan',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tips: Pisahkan paragraf dengan enter untuk hasil yang lebih rapi',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.primaryColor,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFormatExample(String format, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              format,
              style: AppTheme.bodySmall.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTheme.bodySmall.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}