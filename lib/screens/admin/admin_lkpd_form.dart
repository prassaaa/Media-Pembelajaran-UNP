import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class AdminLkpdForm extends StatefulWidget {
  const AdminLkpdForm({Key? key}) : super(key: key);

  @override
  State<AdminLkpdForm> createState() => _AdminLkpdFormState();
}

class _AdminLkpdFormState extends State<AdminLkpdForm> {
  final FirebaseService _firebaseService = FirebaseService();
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _kompetensiDasarController = TextEditingController();
  final TextEditingController _indikatorPencapaianController = TextEditingController();
  final TextEditingController _rubrikPenilaianController = TextEditingController();

  bool _isEditMode = false;
  bool _isLoading = false;
  String _lkpdId = '';
  File? _gambarFile;
  String _gambarUrl = '';
  int _estimasiWaktu = 60;
  
  List<Kegiatan> _kegiatanList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is LKPD) {
      // Edit mode
      _isEditMode = true;
      _lkpdId = args.id;
      _judulController.text = args.judul;
      _deskripsiController.text = args.deskripsi;
      _kompetensiDasarController.text = args.kompetensiDasar;
      _indikatorPencapaianController.text = args.indikatorPencapaian;
      _rubrikPenilaianController.text = args.rubrikPenilaian;
      _gambarUrl = args.gambarUrl;
      _estimasiWaktu = args.estimasiWaktu;
      _kegiatanList = List.from(args.kegiatanList);
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    _kompetensiDasarController.dispose();
    _indikatorPencapaianController.dispose();
    _rubrikPenilaianController.dispose();
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
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: Colors.orange,
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

  void _showAddKegiatanDialog() {
    final TextEditingController judulKegiatanController = TextEditingController();
    final TextEditingController instruksiController = TextEditingController();
    KegiatanType selectedType = KegiatanType.observasi;
    int estimasiWaktu = 30;
    List<String> pertanyaanPemandu = [''];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Tambah Kegiatan'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Judul Kegiatan
                      TextField(
                        controller: judulKegiatanController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Kegiatan',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Tipe Kegiatan
                      DropdownButtonFormField<KegiatanType>(
                        value: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Tipe Kegiatan',
                          border: OutlineInputBorder(),
                        ),
                        items: KegiatanType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(LKPDHelper.getKegiatanTypeText(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Estimasi Waktu
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Estimasi Waktu: $estimasiWaktu menit',
                              style: AppTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: estimasiWaktu.toDouble(),
                        min: 10,
                        max: 120,
                        divisions: 11,
                        label: '$estimasiWaktu menit',
                        onChanged: (value) {
                          setDialogState(() {
                            estimasiWaktu = value.round();
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Instruksi
                      TextField(
                        controller: instruksiController,
                        decoration: const InputDecoration(
                          labelText: 'Instruksi Kegiatan',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      // Pertanyaan Pemandu
                      Text(
                        'Pertanyaan Pemandu',
                        style: AppTheme.subtitleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...pertanyaanPemandu.asMap().entries.map((entry) {
                        final index = entry.key;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Pertanyaan ${index + 1}',
                                    border: const OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    pertanyaanPemandu[index] = value;
                                  },
                                ),
                              ),
                              IconButton(
                                onPressed: pertanyaanPemandu.length > 1
                                    ? () {
                                        setDialogState(() {
                                          pertanyaanPemandu.removeAt(index);
                                        });
                                      }
                                    : null,
                                icon: const Icon(Icons.remove_circle),
                                color: Colors.red,
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      TextButton.icon(
                        onPressed: () {
                          setDialogState(() {
                            pertanyaanPemandu.add('');
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Pertanyaan'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (judulKegiatanController.text.isNotEmpty &&
                        instruksiController.text.isNotEmpty) {
                      final kegiatan = Kegiatan(
                        id: 'kegiatan_${DateTime.now().millisecondsSinceEpoch}',
                        judul: judulKegiatanController.text,
                        instruksi: instruksiController.text,
                        type: selectedType,
                        pertanyaanPemandu: pertanyaanPemandu.where((p) => p.isNotEmpty).toList(),
                        estimasiWaktu: estimasiWaktu,
                      );
                      
                      setState(() {
                        _kegiatanList.add(kegiatan);
                        _updateEstimasiWaktu();
                      });
                      
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Tambah'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateEstimasiWaktu() {
    _estimasiWaktu = _kegiatanList.fold(0, (sum, kegiatan) => sum + kegiatan.estimasiWaktu);
  }

  void _removeKegiatan(int index) {
    setState(() {
      _kegiatanList.removeAt(index);
      _updateEstimasiWaktu();
    });
  }

  Future<void> _saveLkpd() async {
    if (!_formKey.currentState!.validate() || _kegiatanList.isEmpty) {
      if (_kegiatanList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tambahkan minimal satu kegiatan'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final lkpd = LKPD(
        id: _lkpdId,
        judul: _judulController.text,
        deskripsi: _deskripsiController.text,
        gambarUrl: _gambarUrl,
        kegiatanList: _kegiatanList,
        rubrikPenilaian: _rubrikPenilaianController.text,
        estimasiWaktu: _estimasiWaktu,
        kompetensiDasar: _kompetensiDasarController.text,
        indikatorPencapaian: _indikatorPencapaianController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_isEditMode) {
        await _firebaseService.updateLKPD(lkpd, _gambarFile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('LKPD berhasil diperbarui'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        await _firebaseService.addLKPD(lkpd, _gambarFile);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('LKPD berhasil ditambahkan'),
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
                'Gagal ${_isEditMode ? 'memperbarui' : 'menambahkan'} LKPD: ${e.toString()}'),
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
              backgroundColor: Colors.orange,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _isEditMode ? 'Edit LKPD' : 'Tambah LKPD',
                  style: AppTheme.subtitleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.orange,
                        Colors.orange.shade800,
                      ],
                    ),
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
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isEditMode ? Icons.edit_note : Icons.add_box,
                              color: Colors.orange,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _isEditMode
                                    ? 'Edit LKPD yang sudah ada'
                                    : 'Tambahkan LKPD baru',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Judul LKPD
                      TextFormField(
                        controller: _judulController,
                        decoration: const InputDecoration(
                          labelText: 'Judul LKPD',
                          hintText: 'Masukkan judul LKPD',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul LKPD tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi LKPD
                      TextFormField(
                        controller: _deskripsiController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi LKPD',
                          hintText: 'Masukkan deskripsi singkat LKPD',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Deskripsi LKPD tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Kompetensi Dasar
                      TextFormField(
                        controller: _kompetensiDasarController,
                        decoration: const InputDecoration(
                          labelText: 'Kompetensi Dasar',
                          hintText: 'Contoh: 3.2 Menganalisis pelaksanaan kewajiban...',
                          prefixIcon: Icon(Icons.school_outlined),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Kompetensi dasar tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Indikator Pencapaian
                      TextFormField(
                        controller: _indikatorPencapaianController,
                        decoration: const InputDecoration(
                          labelText: 'Indikator Pencapaian',
                          hintText: 'Contoh: Siswa dapat mengidentifikasi dan menganalisis...',
                          prefixIcon: Icon(Icons.track_changes_outlined),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Indikator pencapaian tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Gambar LKPD
                      Text(
                        'Gambar LKPD',
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
                            color: Colors.orange.withOpacity(0.05),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: _gambarFile != null
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
                                      child: Image.network(
                                        _gambarUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.broken_image,
                                                  size: 48,
                                                  color: Colors.orange.withOpacity(0.7),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Gambar tidak dapat dimuat',
                                                  style: AppTheme.bodyMedium.copyWith(
                                                    color: Colors.orange.withOpacity(0.7),
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
                                            color: Colors.orange.withOpacity(0.7),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Tap untuk memilih gambar LKPD',
                                            style: AppTheme.bodyMedium.copyWith(
                                              color: Colors.orange.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Kegiatan Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kegiatan LKPD (${_kegiatanList.length})',
                            style: AppTheme.subtitleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _showAddKegiatanDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Kegiatan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Kegiatan List
                      if (_kegiatanList.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.assignment_outlined,
                                  size: 48,
                                  color: Colors.grey.withOpacity(0.7),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Belum ada kegiatan',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: Colors.grey.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap "Tambah Kegiatan" untuk menambahkan',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._kegiatanList.asMap().entries.map((entry) {
                          final index = entry.key;
                          final kegiatan = entry.value;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange.withOpacity(0.2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${index + 1}',
                                          style: AppTheme.bodyMedium.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            kegiatan.judul,
                                            style: AppTheme.subtitleMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            '${LKPDHelper.getKegiatanTypeText(kegiatan.type)} • ${kegiatan.estimasiWaktu} menit',
                                            style: AppTheme.bodySmall.copyWith(
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _removeKegiatan(index),
                                      icon: const Icon(Icons.delete),
                                      color: Colors.red,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  kegiatan.instruksi,
                                  style: AppTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${kegiatan.pertanyaanPemandu.length} pertanyaan pemandu',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                      const SizedBox(height: 24),

                      // Estimasi Waktu Total
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.blue,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Estimasi Waktu',
                                    style: AppTheme.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  Text(
                                    LKPDHelper.getTotalEstimasiWaktu(_kegiatanList),
                                    style: AppTheme.subtitleMedium.copyWith(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Rubrik Penilaian
                      TextFormField(
                        controller: _rubrikPenilaianController,
                        decoration: const InputDecoration(
                          labelText: 'Rubrik Penilaian',
                          hintText: 'Masukkan kriteria penilaian LKPD',
                          prefixIcon: Icon(Icons.assessment),
                        ),
                        maxLines: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Rubrik penilaian tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Tombol Simpan
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _saveLkpd,
                          icon: Icon(_isEditMode ? Icons.save : Icons.add),
                          label: Text(_isEditMode ? 'Perbarui LKPD' : 'Simpan LKPD'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: AppTheme.subtitleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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