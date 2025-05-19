import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/app_button.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

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
  final TextEditingController _kontenController = TextEditingController();

  bool _isEditMode = false;
  bool _isLoading = false;
  bool _isImageLoading = false;
  String _materiId = '';
  File? _gambarFile;
  String _gambarUrl = '';

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
      _kontenController.text = args.konten;
      _gambarUrl = args.gambarUrl;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
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
      final judul = _judulController.text;
      final deskripsi = _deskripsiController.text;
      final konten = _kontenController.text;

      if (_isEditMode) {
        // Update materi
        final Materi materi = Materi(
          id: _materiId,
          judul: judul,
          deskripsi: deskripsi,
          gambarUrl: _gambarUrl,
          konten: konten,
          createdAt: DateTime.now(), // Will be ignored on update
          updatedAt: DateTime.now(),
        );

        await _firebaseService.updateMateri(materi, _gambarFile);
        
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
          konten: konten,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firebaseService.addMateri(materi, _gambarFile);

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
                              const SizedBox(height: 50), // Space for title
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

                      // Gambar Materi
                      Text(
                        'Gambar Materi',
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
                                              print("Error loading image: $error");
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
                                                'Tap untuk memilih gambar',
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
                            ? 'Ganti Gambar'
                            : 'Pilih Gambar',
                        icon: Icons.image,
                        type: ButtonType.outlined,
                        onPressed: _showImagePickerOptions,
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 24),

                      // Konten Materi
                      Text(
                        'Konten Materi',
                        style: AppTheme.subtitleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                            hintText: 'Masukkan konten materi pembelajaran',
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
}