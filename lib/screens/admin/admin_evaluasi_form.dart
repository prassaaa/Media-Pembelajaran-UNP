import 'package:flutter/material.dart';
import 'package:pembelajaran_app/config/constants.dart';
import 'package:pembelajaran_app/config/theme.dart';
import 'package:pembelajaran_app/models/models.dart';
import 'package:pembelajaran_app/services/firebase_service.dart';
import 'package:pembelajaran_app/widgets/app_button.dart';
import 'package:pembelajaran_app/widgets/loading_widget.dart';

class AdminEvaluasiForm extends StatefulWidget {
  const AdminEvaluasiForm({Key? key}) : super(key: key);

  @override
  State<AdminEvaluasiForm> createState() => _AdminEvaluasiFormState();
}

class _AdminEvaluasiFormState extends State<AdminEvaluasiForm> {
  final FirebaseService _firebaseService = FirebaseService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  bool _isEditMode = false;
  bool _isLoading = false;
  String _evaluasiId = '';
  List<Soal> _soalList = [];
  List<String> _soalIds = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Object? args = ModalRoute.of(context)?.settings.arguments;
    
    if (args != null && args is Evaluasi) {
      _isEditMode = true;
      _evaluasiId = args.id;
      _judulController.text = args.judul;
      _deskripsiController.text = args.deskripsi;
      _soalIds = List<String>.from(args.soalIds);
      
      // Load existing soal
      _loadSoal();
    } else {
      _isEditMode = false;
      _evaluasiId = '';
      _soalIds = [];
      _soalList = [];
    }
  }

  Future<void> _loadSoal() async {
    if (_soalIds.isEmpty) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      List<Soal> soalList = [];
      
      // Gunakan pendekatan yang aman - ambil satu per satu tanpa modifikasi list saat iterasi
      for (int i = 0; i < _soalIds.length; i++) {
        String id = _soalIds[i];
        try {
          final soal = await _firebaseService.getSoalById(id);
          soalList.add(soal);
        } catch (e) {
          // Log error tapi tidak mengubah _soalIds disini
        }
      }
      
      // Set state dengan soal yang berhasil dimuat
      setState(() {
        _soalList = soalList;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat soal: ${e.toString()}'),
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

  // Fungsi untuk membersihkan ID soal yang tidak valid
  Future<void> _cleanupInvalidSoalIds() async {
    if (!_isEditMode || _soalIds.isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      List<String> validIds = [];
      
      for (String id in List<String>.from(_soalIds)) {
        try {
          await _firebaseService.getSoalById(id);
          validIds.add(id);
        } catch (e) {
          // ID tidak valid, jangan tambahkan ke validIds
        }
      }
      
      if (validIds.length != _soalIds.length) {
        setState(() {
          _soalIds = validIds;
        });
        
        // Update evaluasi di Firestore
        final Evaluasi updatedEvaluasi = Evaluasi(
          id: _evaluasiId,
          judul: _judulController.text,
          deskripsi: _deskripsiController.text,
          soalIds: _soalIds,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _firebaseService.updateEvaluasi(updatedEvaluasi);
        
        // Reload soal
        await _loadSoal();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Soal tidak valid berhasil dibersihkan'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada soal tidak valid yang perlu dibersihkan'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membersihkan soal: ${e.toString()}'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _saveEvaluasi() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validasi soal
    if (_soalIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evaluasi harus memiliki minimal 1 soal'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final judul = _judulController.text;
      final deskripsi = _deskripsiController.text;

      if (_isEditMode) {
        // Update evaluasi
        final Evaluasi evaluasi = Evaluasi(
          id: _evaluasiId,
          judul: judul,
          deskripsi: deskripsi,
          soalIds: _soalIds,
          createdAt: DateTime.now(), // Will be ignored on update
          updatedAt: DateTime.now(),
        );

        await _firebaseService.updateEvaluasi(evaluasi);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Evaluasi berhasil diperbarui'),
              backgroundColor: AppTheme.successColor,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // Add new evaluasi
        final Evaluasi evaluasi = Evaluasi(
          id: '',
          judul: judul,
          deskripsi: deskripsi,
          soalIds: _soalIds,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        try {
          await _firebaseService.addEvaluasi(evaluasi);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Evaluasi berhasil ditambahkan'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          throw e;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Gagal ${_isEditMode ? 'memperbarui' : 'menambahkan'} evaluasi: ${e.toString()}'),
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

  Future<void> _addSoal() async {
    final result = await Navigator.pushNamed(
      context,
      AppConstants.routeAdminSoalForm,
    );

    if (result != null && result is Soal) {
      // Verifikasi soal ada di Firestore
      try {
        await _firebaseService.getSoalById(result.id);
        
        // Soal berhasil diverifikasi, tambahkan ke list
        setState(() {
          _soalList.add(result);
          _soalIds.add(result.id);
        });
        
        // Perbarui evaluasi di Firestore jika dalam mode edit
        if (_isEditMode) {
          try {
            setState(() {
              _isLoading = true;
            });
            
            final Evaluasi updatedEvaluasi = Evaluasi(
              id: _evaluasiId,
              judul: _judulController.text,
              deskripsi: _deskripsiController.text,
              soalIds: _soalIds,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );
            
            await _firebaseService.updateEvaluasi(updatedEvaluasi);
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Soal berhasil ditambahkan dan evaluasi diperbarui'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error saat memperbarui evaluasi: ${e.toString()}'),
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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Soal tidak dapat diverifikasi: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _editSoal(int index) async {
    final result = await Navigator.pushNamed(
      context,
      AppConstants.routeAdminSoalForm,
      arguments: _soalList[index],
    );

    if (result != null && result is Soal) {
      setState(() {
        _soalList[index] = result;
        // ID remains the same
      });
      
      // Perbarui evaluasi di Firestore jika dalam mode edit
      if (_isEditMode) {
        try {
          setState(() {
            _isLoading = true;
          });
          
          final Evaluasi updatedEvaluasi = Evaluasi(
            id: _evaluasiId,
            judul: _judulController.text,
            deskripsi: _deskripsiController.text,
            soalIds: _soalIds,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          
          await _firebaseService.updateEvaluasi(updatedEvaluasi);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Soal berhasil diedit dan evaluasi diperbarui'),
                backgroundColor: AppTheme.successColor,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error saat memperbarui evaluasi: ${e.toString()}'),
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
    }
  }

  Future<void> _deleteSoal(int index) async {
    final soalId = _soalIds[index];
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus soal ini? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                setState(() {
                  _isLoading = true;
                });
                
                try {
                  await _firebaseService.deleteSoal(soalId);
                  
                  setState(() {
                    _soalList.removeAt(index);
                    _soalIds.removeAt(index);
                  });
                  
                  // Perbarui evaluasi setelah menghapus soal
                  if (_isEditMode) {
                    try {
                      final Evaluasi updatedEvaluasi = Evaluasi(
                        id: _evaluasiId,
                        judul: _judulController.text,
                        deskripsi: _deskripsiController.text,
                        soalIds: _soalIds,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      
                      await _firebaseService.updateEvaluasi(updatedEvaluasi);
                    } catch (e) {
                      // Error handling
                    }
                  }
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Soal berhasil dihapus'),
                        backgroundColor: AppTheme.successColor,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal menghapus soal: ${e.toString()}'),
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // Tambahkan metode untuk me-refresh data soal
  Future<void> _refreshSoal() async {
    await _loadSoal();
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
              backgroundColor: AppTheme.successColor,
              actions: [
                // Tombol untuk membersihkan soal tidak valid jika dalam mode edit
                if (_isEditMode)
                  IconButton(
                    icon: const Icon(Icons.cleaning_services),
                    onPressed: _cleanupInvalidSoalIds,
                    tooltip: 'Bersihkan Soal Tidak Valid',
                  ),
                // Tombol refresh
                if (_isEditMode)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _refreshSoal,
                    tooltip: 'Refresh Data Soal',
                  ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _isEditMode ? 'Edit Evaluasi' : 'Tambah Evaluasi',
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
                        AppTheme.successColor,
                        const Color(0xFF004D40),
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
                                Icons.assignment,
                                color: Colors.white,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _isEditMode 
                                    ? 'Edit Evaluasi Pembelajaran' 
                                    : 'Tambah Evaluasi Pembelajaran Baru',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Form untuk data evaluasi
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Form Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.successColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _isEditMode
                                      ? Icons.edit_note
                                      : Icons.assignment_add,
                                  color: AppTheme.successColor,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _isEditMode
                                        ? 'Edit evaluasi pembelajaran'
                                        : 'Tambahkan evaluasi pembelajaran baru',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.successColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Judul Evaluasi
                          TextFormField(
                            controller: _judulController,
                            decoration: const InputDecoration(
                              labelText: 'Judul Evaluasi',
                              hintText: 'Masukkan judul evaluasi',
                              prefixIcon: Icon(Icons.title),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Judul evaluasi tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Deskripsi Evaluasi
                          TextFormField(
                            controller: _deskripsiController,
                            decoration: const InputDecoration(
                              labelText: 'Deskripsi Evaluasi',
                              hintText: 'Masukkan deskripsi evaluasi',
                              prefixIcon: Icon(Icons.description),
                            ),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Deskripsi evaluasi tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Soal Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daftar Soal (${_soalList.length})',
                                style: AppTheme.subtitleLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _addSoal,
                                icon: const Icon(Icons.add),
                                label: const Text('Tambah Soal'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.successColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),

                    // List Soal
                    Expanded(
                      child: _soalList.isEmpty
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.all(32),
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
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppTheme.successColor.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.question_mark,
                                        size: 48,
                                        color: AppTheme.successColor,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Belum Ada Soal',
                                      style: AppTheme.subtitleLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tambahkan soal untuk evaluasi ini',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppTheme.secondaryTextColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    AppButton(
                                      text: 'Tambah Soal Sekarang',
                                      icon: Icons.add,
                                      onPressed: _addSoal,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _soalList.length,
                              itemBuilder: (context, index) {
                                final soal = _soalList[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.successColor.withOpacity(0.1),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        dividerColor: Colors.transparent,
                                      ),
                                      child: ExpansionTile(
                                        leading: CircleAvatar(
                                          backgroundColor: AppTheme.successColor,
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          soal.pertanyaan,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.subtitleMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              color: AppTheme.primaryColor,
                                              onPressed: () => _editSoal(index),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              color: AppTheme.errorColor,
                                              onPressed: () => _deleteSoal(index),
                                            ),
                                          ],
                                        ),
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // Gambar jika ada
                                                if (soal.gambarUrl != null &&
                                                    soal.gambarUrl!.isNotEmpty) ...[
                                                  Container(
                                                    height: 150,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                      color: Colors.grey
                                                          .withOpacity(0.1),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(12),
                                                      child: Image.network(
                                                        soal.gambarUrl!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error,
                                                            stackTrace) {
                                                          return const Center(
                                                            child: Icon(
                                                              Icons.broken_image,
                                                              size: 48,
                                                              color: Colors.grey,
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                ],

                                                // Opsi jawaban
                                                Container(
                                                  padding: const EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.withOpacity(0.05),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Opsi Jawaban:',
                                                        style: AppTheme.subtitleMedium.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 12),
                                                      ...List.generate(
                                                        soal.opsi.length,
                                                        (i) => Padding(
                                                          padding: const EdgeInsets.only(
                                                              bottom: 12.0),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(12),
                                                            decoration: BoxDecoration(
                                                              color: i == soal.jawabanBenar
                                                                  ? AppTheme.successColor
                                                                      .withOpacity(0.1)
                                                                  : Colors.white,
                                                              borderRadius:
                                                                  BorderRadius.circular(12),
                                                              border: Border.all(
                                                                color: i == soal.jawabanBenar
                                                                    ? AppTheme.successColor
                                                                    : Colors.grey.withOpacity(0.3),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              children: [
                                                                Container(
                                                                  width: 28,
                                                                  height: 28,
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.circle,
                                                                    color: i ==
                                                                            soal.jawabanBenar
                                                                        ? AppTheme
                                                                            .successColor
                                                                        : Colors.grey
                                                                            .withOpacity(0.2),
                                                                  ),
                                                                  child: Center(
                                                                    child: i ==
                                                                            soal.jawabanBenar
                                                                        ? const Icon(
                                                                            Icons.check,
                                                                            color:
                                                                                Colors.white,
                                                                            size: 16,
                                                                          )
                                                                        : Text(
                                                                            String.fromCharCode(
                                                                                'A'.codeUnitAt(
                                                                                        0) +
                                                                                    i),
                                                                            style: const TextStyle(
                                                                                color: Colors
                                                                                    .white),
                                                                          ),
                                                                  ),
                                                                ),
                                                                const SizedBox(width: 12),
                                                                Expanded(
                                                                  child: Text(
                                                                    soal.opsi[i],
                                                                    style: AppTheme.bodyMedium
                                                                        .copyWith(
                                                                      fontWeight: i ==
                                                                              soal
                                                                                  .jawabanBenar
                                                                          ? FontWeight.bold
                                                                          : FontWeight
                                                                              .normal,
                                                                    ),
                                                                  ),
                                                                ),
                                                                if (i == soal.jawabanBenar)
                                                                  Container(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal: 8,
                                                                      vertical: 4,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      color: AppTheme.successColor,
                                                                      borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                    child: Text(
                                                                      'Benar',
                                                                      style: AppTheme.bodySmall.copyWith(
                                                                        color: Colors.white,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                
                                                const SizedBox(height: 16),
                                                // Tombol Aksi
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    OutlinedButton.icon(
                                                      onPressed: () => _editSoal(index),
                                                      icon: const Icon(Icons.edit),
                                                      label: const Text('Edit'),
                                                      style: OutlinedButton.styleFrom(
                                                        foregroundColor: AppTheme.primaryColor,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton.icon(
                                                      onPressed: () => _deleteSoal(index),
                                                      icon: const Icon(Icons.delete),
                                                      label: const Text('Hapus'),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppTheme.errorColor,
                                                        foregroundColor: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // Tombol Simpan
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AppButton(
                        text: _isEditMode ? 'Perbarui Evaluasi' : 'Simpan Evaluasi',
                        icon: _isEditMode ? Icons.save : Icons.check,
                        onPressed: _saveEvaluasi,
                        isLoading: _isLoading,
                        isFullWidth: true,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}