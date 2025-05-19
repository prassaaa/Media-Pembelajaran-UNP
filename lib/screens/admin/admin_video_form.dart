import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/app_button.dart';
import 'package:image_picker/image_picker.dart';

class AdminVideoForm extends StatefulWidget {
  const AdminVideoForm({Key? key}) : super(key: key);

  @override
  State<AdminVideoForm> createState() => _AdminVideoFormState();
}

class _AdminVideoFormState extends State<AdminVideoForm> {
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _youtubeUrlController = TextEditingController();

  bool _isEditMode = false;
  bool _isLoading = false;
  bool _isImageLoading = false;
  String _videoId = '';
  File? _thumbnailFile;
  String _thumbnailUrl = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Video) {
      // Edit mode
      _isEditMode = true;
      _videoId = args.id;
      _judulController.text = args.judul;
      _deskripsiController.text = args.deskripsi;
      _youtubeUrlController.text = args.youtubeUrl;
      _thumbnailUrl = args.thumbnailUrl;
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _youtubeUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    try {
      setState(() {
        _isImageLoading = true;
      });
      
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        setState(() {
          _thumbnailFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error memilih thumbnail: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isImageLoading = false;
        });
      }
    }
  }

  Future<void> _saveVideo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final judul = _judulController.text;
      final deskripsi = _deskripsiController.text;
      final youtubeUrl = _youtubeUrlController.text;

      if (_isEditMode) {
        // Update video
        final Video video = Video(
          id: _videoId,
          judul: judul,
          deskripsi: deskripsi,
          youtubeUrl: youtubeUrl,
          thumbnailUrl: _thumbnailUrl,
          createdAt: DateTime.now(), // Will be ignored on update
          updatedAt: DateTime.now(),
        );

        await _firebaseService.updateVideo(video, _thumbnailFile);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video berhasil diperbarui'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Add new video
        final Video video = Video(
          id: '',
          judul: judul,
          deskripsi: deskripsi,
          youtubeUrl: youtubeUrl,
          thumbnailUrl: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firebaseService.addVideo(video, _thumbnailFile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video berhasil ditambahkan'),
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
                'Gagal ${_isEditMode ? 'memperbarui' : 'menambahkan'} video: ${e.toString()}'),
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

  bool _isValidYoutubeUrl(String url) {
    // Regex pattern to match YouTube URLs
    final RegExp youtubeRegExp = RegExp(
      r'^(https?\:\/\/)?(www\.)?(youtube\.com|youtu\.?be)\/.+$',
      caseSensitive: false,
    );
    return youtubeRegExp.hasMatch(url);
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
              backgroundColor: AppTheme.accentColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _isEditMode ? 'Edit Video' : 'Tambah Video',
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
                        AppTheme.accentColor,
                        const Color(0xFF5C2D91), // Darker purple shade
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
                                Icons.video_library,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isEditMode 
                                    ? 'Edit Video Pembelajaran' 
                                    : 'Tambah Video Pembelajaran Baru',
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
            ? const Center(
                child: CircularProgressIndicator(),
              )
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
                          color: AppTheme.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.accentColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isEditMode ? Icons.edit_note : Icons.video_call,
                              color: AppTheme.accentColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isEditMode
                                    ? 'Edit video pembelajaran yang sudah ada'
                                    : 'Tambahkan video pembelajaran baru',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Judul Video
                      Text(
                        'Judul Video',
                        style: AppTheme.subtitleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _judulController,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan judul video',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul video tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Deskripsi Video
                      Text(
                        'Deskripsi Video',
                        style: AppTheme.subtitleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _deskripsiController,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan deskripsi singkat video',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Deskripsi video tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // YouTube URL
                      Text(
                        'URL YouTube',
                        style: AppTheme.subtitleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _youtubeUrlController,
                        decoration: const InputDecoration(
                          hintText: 'Masukkan URL video YouTube',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'URL YouTube tidak boleh kosong';
                          }
                          if (!_isValidYoutubeUrl(value)) {
                            return 'URL YouTube tidak valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Thumbnail Video
                      Text(
                        'Thumbnail Video',
                        style: AppTheme.subtitleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickThumbnail,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppTheme.accentColor.withOpacity(0.05),
                            border: Border.all(
                              color: AppTheme.accentColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: _isImageLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _thumbnailFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(
                                        _thumbnailFile!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : _thumbnailUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(14),
                                          child: CachedNetworkImage(
                                            imageUrl: _thumbnailUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Center(
                                              child: CircularProgressIndicator(
                                                color: AppTheme.accentColor,
                                              ),
                                            ),
                                            errorWidget: (context, url, error) {
                                              return Center(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.broken_image,
                                                      size: 48,
                                                      color: AppTheme.accentColor.withOpacity(0.7),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Gambar tidak dapat dimuat',
                                                      style: AppTheme.bodyMedium.copyWith(
                                                        color: AppTheme.accentColor.withOpacity(0.7),
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
                                                color: AppTheme.accentColor.withOpacity(0.7),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Tap untuk memilih thumbnail',
                                                style: AppTheme.bodyMedium.copyWith(
                                                  color: AppTheme.accentColor.withOpacity(0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Pilih Thumbnail',
                              icon: Icons.image,
                              type: ButtonType.outlined,
                              onPressed: _pickThumbnail,
                            ),
                          ),
                          if (_thumbnailFile != null || _thumbnailUrl.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: AppButton(
                                text: 'Hapus Thumbnail',
                                icon: Icons.delete,
                                type: ButtonType.outlined,
                                onPressed: () {
                                  setState(() {
                                    _thumbnailFile = null;
                                    _thumbnailUrl = '';
                                  });
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      // YouTube Preview
                      if (_youtubeUrlController.text.isNotEmpty && _isValidYoutubeUrl(_youtubeUrlController.text)) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: AppTheme.successColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'URL YouTube Valid',
                                      style: AppTheme.subtitleMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.successColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Video akan tersedia untuk ditonton setelah disimpan',
                                      style: AppTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Tombol Simpan
                      AppButton(
                        text: _isEditMode ? 'Perbarui Video' : 'Simpan Video',
                        icon: _isEditMode ? Icons.save : Icons.check,
                        onPressed: _saveVideo,
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