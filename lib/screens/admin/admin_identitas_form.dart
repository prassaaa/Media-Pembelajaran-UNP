import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/app_button.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';
import 'package:image_picker/image_picker.dart';

class AdminIdentitasForm extends StatefulWidget {
  const AdminIdentitasForm({Key? key}) : super(key: key);

  @override
  State<AdminIdentitasForm> createState() => _AdminIdentitasFormState();
}

class _AdminIdentitasFormState extends State<AdminIdentitasForm> {
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for Mahasiswa
  final TextEditingController _namaMahasiswaController = TextEditingController();
  final TextEditingController _nimMahasiswaController = TextEditingController();
  final TextEditingController _prodiMahasiswaController = TextEditingController();
  
  // Controllers for Dospem 1
  final TextEditingController _namaDospem1Controller = TextEditingController();
  final TextEditingController _nipDospem1Controller = TextEditingController();
  
  // Controllers for Dospem 2
  final TextEditingController _namaDospem2Controller = TextEditingController();
  final TextEditingController _nipDospem2Controller = TextEditingController();

  bool _isLoading = false;
  String _docId = '';
  
  // Foto URLs from database
  String _fotoMahasiswaUrl = '';
  String _fotoDospem1Url = '';
  String? _fotoDospem2Url;
  
  // Selected image files
  File? _fotoMahasiswaFile;
  File? _fotoDospem1File;
  File? _fotoDospem2File;
  
  // Toggle for dosen pembimbing 2
  bool _hasDospem2 = false;

  @override
  void initState() {
    super.initState();
    _loadIdentitas();
  }

  Future<void> _loadIdentitas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final identitas = await _firebaseService.getIdentitas();
      
      if (identitas != null) {
        // Set form data from existing identitas
        setState(() {
          _docId = identitas.id;
          
          // Mahasiswa
          _namaMahasiswaController.text = identitas.namaMahasiswa;
          _nimMahasiswaController.text = identitas.nimMahasiswa;
          _prodiMahasiswaController.text = identitas.prodiMahasiswa;
          _fotoMahasiswaUrl = identitas.fotoMahasiswaUrl;
          
          // Dospem 1
          _namaDospem1Controller.text = identitas.namaDospem1;
          _nipDospem1Controller.text = identitas.nipDospem1;
          _fotoDospem1Url = identitas.fotoDospem1Url;
          
          // Dospem 2
          if (identitas.namaDospem2 != null && identitas.namaDospem2!.isNotEmpty) {
            _hasDospem2 = true;
            _namaDospem2Controller.text = identitas.namaDospem2 ?? '';
            _nipDospem2Controller.text = identitas.nipDospem2 ?? '';
            _fotoDospem2Url = identitas.fotoDospem2Url;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: ${e.toString()}'),
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

  Future<void> _pickImage(ImageSource source, int personType) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      
      if (pickedFile != null) {
        setState(() {
          if (personType == 1) { // Mahasiswa
            _fotoMahasiswaFile = File(pickedFile.path);
          } else if (personType == 2) { // Dospem 1
            _fotoDospem1File = File(pickedFile.path);
          } else if (personType == 3) { // Dospem 2
            _fotoDospem2File = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions(int personType) {
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
                  'Pilih Sumber Foto',
                  style: AppTheme.subtitleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'Galeri',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery, personType);
                      },
                    ),
                    _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Kamera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera, personType);
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

  Future<void> _saveIdentitas() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare data
      final identitas = Identitas(
        id: _docId,
        namaMahasiswa: _namaMahasiswaController.text,
        nimMahasiswa: _nimMahasiswaController.text,
        prodiMahasiswa: _prodiMahasiswaController.text,
        fotoMahasiswaUrl: _fotoMahasiswaUrl,
        namaDospem1: _namaDospem1Controller.text,
        nipDospem1: _nipDospem1Controller.text,
        fotoDospem1Url: _fotoDospem1Url,
        namaDospem2: _hasDospem2 ? _namaDospem2Controller.text : null,
        nipDospem2: _hasDospem2 ? _nipDospem2Controller.text : null,
        fotoDospem2Url: _hasDospem2 ? _fotoDospem2Url : null,
        createdAt: DateTime.now(), // Will be set by server for new entries
        updatedAt: DateTime.now(), // Will be set by server for updates
      );

      // Save to Firestore
      await _firebaseService.saveIdentitas(
        identitas,
        fotoMahasiswa: _fotoMahasiswaFile,
        fotoDospem1: _fotoDospem1File,
        fotoDospem2: _fotoDospem2File,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data identitas berhasil disimpan'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: ${e.toString()}'),
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
  void dispose() {
    // Dispose controllers
    _namaMahasiswaController.dispose();
    _nimMahasiswaController.dispose();
    _prodiMahasiswaController.dispose();
    _namaDospem1Controller.dispose();
    _nipDospem1Controller.dispose();
    _namaDospem2Controller.dispose();
    _nipDospem2Controller.dispose();
    super.dispose();
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
              backgroundColor: Colors.purple,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Kelola Identitas',
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
                        Colors.purple,
                        Colors.deepPurple,
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
                                Icons.people_alt_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kelola Informasi Pengembang',
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
            ? const LoadingWidget(message: 'Memuat data...')
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
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.purple.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.purple,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Kelola informasi identitas pengembang aplikasi',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // === MAHASISWA ===
                      Text(
                        'Identitas Mahasiswa',
                        style: AppTheme.headingSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      // Foto Mahasiswa
                      _buildImagePicker(
                        label: 'Foto Mahasiswa',
                        imageUrl: _fotoMahasiswaUrl,
                        imageFile: _fotoMahasiswaFile,
                        onTap: () => _showImagePickerOptions(1),
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 16),
                      
                      // Nama Mahasiswa
                      TextFormField(
                        controller: _namaMahasiswaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Mahasiswa',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama mahasiswa tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // NIM Mahasiswa
                      TextFormField(
                        controller: _nimMahasiswaController,
                        decoration: const InputDecoration(
                          labelText: 'NIM Mahasiswa',
                          prefixIcon: Icon(Icons.badge),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'NIM mahasiswa tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Program Studi
                      TextFormField(
                        controller: _prodiMahasiswaController,
                        decoration: const InputDecoration(
                          labelText: 'Program Studi',
                          prefixIcon: Icon(Icons.school),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Program studi tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // === DOSEN PEMBIMBING 1 ===
                      Text(
                        'Identitas Dosen Pembimbing 1',
                        style: AppTheme.headingSmall,
                      ),
                      const SizedBox(height: 16),
                      
                      // Foto Dosen Pembimbing 1
                      _buildImagePicker(
                        label: 'Foto Dosen Pembimbing 1',
                        imageUrl: _fotoDospem1Url,
                        imageFile: _fotoDospem1File,
                        onTap: () => _showImagePickerOptions(2),
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      
                      // Nama Dosen Pembimbing 1
                      TextFormField(
                        controller: _namaDospem1Controller,
                        decoration: const InputDecoration(
                          labelText: 'Nama Dosen Pembimbing 1',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama dosen pembimbing 1 tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // NIP Dosen Pembimbing 1
                      TextFormField(
                        controller: _nipDospem1Controller,
                        decoration: const InputDecoration(
                          labelText: 'NIP Dosen Pembimbing 1',
                          prefixIcon: Icon(Icons.badge),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'NIP dosen pembimbing 1 tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      
                      // === DOSEN PEMBIMBING 2 ===
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Identitas Dosen Pembimbing 2',
                            style: AppTheme.headingSmall,
                          ),
                          Switch(
                            value: _hasDospem2,
                            onChanged: (value) {
                              setState(() {
                                _hasDospem2 = value;
                              });
                            },
                            activeColor: Colors.teal,
                          ),
                        ],
                      ),
                      Text(
                        _hasDospem2
                            ? 'Aktif'
                            : 'Tidak ada dosen pembimbing 2',
                        style: AppTheme.bodySmall.copyWith(
                          color: _hasDospem2 ? Colors.teal : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (_hasDospem2) ...[
                        // Foto Dosen Pembimbing 2
                        _buildImagePicker(
                          label: 'Foto Dosen Pembimbing 2',
                          imageUrl: _fotoDospem2Url ?? '',
                          imageFile: _fotoDospem2File,
                          onTap: () => _showImagePickerOptions(3),
                          color: Colors.teal,
                        ),
                        const SizedBox(height: 16),
                        
                        // Nama Dosen Pembimbing 2
                        TextFormField(
                          controller: _namaDospem2Controller,
                          decoration: const InputDecoration(
                            labelText: 'Nama Dosen Pembimbing 2',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (_hasDospem2 && (value == null || value.isEmpty)) {
                              return 'Nama dosen pembimbing 2 tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // NIP Dosen Pembimbing 2
                        TextFormField(
                          controller: _nipDospem2Controller,
                          decoration: const InputDecoration(
                            labelText: 'NIP Dosen Pembimbing 2',
                            prefixIcon: Icon(Icons.badge),
                          ),
                          validator: (value) {
                            if (_hasDospem2 && (value == null || value.isEmpty)) {
                              return 'NIP dosen pembimbing 2 tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                      
                      // Tombol Simpan
                      AppButton(
                        text: 'Simpan Identitas',
                        icon: Icons.save,
                        onPressed: _saveIdentitas,
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

  Widget _buildImagePicker({
    required String label,
    required String imageUrl,
    required File? imageFile,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.subtitleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                    ),
                  )
                : imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
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
                                    color: color.withOpacity(0.7),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gambar tidak dapat dimuat',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: color.withOpacity(0.7),
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
                              color: color.withOpacity(0.7),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap untuk memilih foto',
                              style: AppTheme.bodyMedium.copyWith(
                                color: color.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ),
        const SizedBox(height: 8),
        if (imageFile != null || imageUrl.isNotEmpty)
          AppButton(
            text: 'Ganti Foto',
            icon: Icons.photo_camera,
            type: ButtonType.outlined,
            onPressed: onTap,
            isFullWidth: true,
          ),
      ],
    );
  }
}