import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:ramysmart/util/constants.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:ramysmart/screens/Home/database/user_database.dart';
import 'package:ramysmart/screens/Home/database/firebase_service.dart'; // Import Firebase service

class AccountProfile extends StatefulWidget {
  final Function()? onNavigateToHome;

  const AccountProfile({
    super.key,
    this.onNavigateToHome,
  });

  @override
  State<AccountProfile> createState() => _AccountProfileState();
}

class _AccountProfileState extends State<AccountProfile> {
  // Variabel untuk menyimpan gambar yang dipilih
  File? _imageFile;
  String? _savedImagePath;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;

  // Controller untuk field input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Firebase service
  final FirebaseService _firebaseService = FirebaseService();

  // Mode edit
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from database
  Future<void> _loadUserData() async {
    try {
      // Set default values first in case database fails
      setState(() {
        _nameController.text = "Afrizal Ramy Diaman";
        _emailController.text = "mudamu@gmail.com";
        _phoneController.text = "+62 821 9785 3073";
      });

      // Check if user is logged in with Firebase
      final firebaseUser = _firebaseService.getCurrentUser();
      String? firebaseEmail;
      if (firebaseUser != null) {
        firebaseEmail = firebaseUser.email;
        print('Firebase user email: $firebaseEmail');
      }

      // Initialize database
      final db = await DatabaseHelper.instance.database;

      final user = await DatabaseHelper.instance.getFirstUser();
      if (user != null) {
        setState(() {
          _nameController.text = user.name;

          // Use Firebase email if available, otherwise use from local DB
          if (firebaseEmail != null) {
            _emailController.text = firebaseEmail;
          } else {
            _emailController.text = user.email;
          }

          _phoneController.text = user.phone;

          if (user.imagePath != null && File(user.imagePath!).existsSync()) {
            _savedImagePath = user.imagePath;
            _imageFile = File(user.imagePath!);
          }
        });

        // Update local database with Firebase email if it's different
        if (firebaseEmail != null && firebaseEmail != user.email) {
          await DatabaseHelper.instance.updateUser(
            UserProfile(
              id: user.id,
              name: user.name,
              email: firebaseEmail, // Update email from Firebase
              phone: user.phone,
              imagePath: user.imagePath,
            ),
          );
          print('Updated local DB with Firebase email');
        }
      } else {
        // Create default user if none exists
        String defaultEmail = firebaseEmail ?? "ramyhandsomeboy@example.com";

        await DatabaseHelper.instance.insertUser(
          UserProfile(
            name: "Afrizal Ramy Diaman",
            email: defaultEmail, // Use Firebase email if available
            phone: "+62 821 9785 3073",
          ),
        );
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    } finally {
      // Always mark loading as complete to prevent infinite loading state
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk logout dengan konfirmasi
  Future<void> _showLogoutConfirmation() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User harus memilih opsi
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red[600]),
              const SizedBox(width: 10),
              const Text('Konfirmasi Logout'),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun?',
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.grey[600]),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _performLogout();
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk melakukan logout
  Future<void> _performLogout() async {
    try {
      // Tampilkan loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Logout dari Firebase
      await _firebaseService.signOut();

      // Tutup loading dialog
      Navigator.of(context).pop();

      // Tampilkan snackbar berhasil logout
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Berhasil logout'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate ke halaman login atau halaman utama
      // Sesuaikan dengan routing aplikasi Anda
      if (widget.onNavigateToHome != null) {
        widget.onNavigateToHome!();
      }

      // Atau jika Anda ingin navigate ke halaman login:
      // Navigator.of(context).pushReplacementNamed('/login');

    } catch (e) {
      // Tutup loading dialog jika error
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal logout: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk menyimpan gambar ke penyimpanan lokal
  Future<String> _saveImageToLocal(File imageFile) async {
    try {
      // Try to use app documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = path.join(appDir.path, fileName);

      // Copy the image to app documents directory
      await imageFile.copy(filePath);

      return filePath;
    } catch (e) {
      // Fallback to temporary directory if documents directory fails
      try {
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String filePath = path.join(tempDir.path, fileName);

        // Copy the image to temp directory
        await imageFile.copy(filePath);

        return filePath;
      } catch (e) {
        // Last resort - use the original file path
        debugPrint('Error saving image: $e');
        return imageFile.path;
      }
    }
  }

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final String savedPath = await _saveImageToLocal(imageFile);

        setState(() {
          _imageFile = imageFile;
          _savedImagePath = savedPath;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: $e')),
      );
    }
  }

  // Fungsi untuk memilih gambar dari kamera
  Future<void> _takePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final String savedPath = await _saveImageToLocal(imageFile);

        setState(() {
          _imageFile = imageFile;
          _savedImagePath = savedPath;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil foto: $e')),
      );
    }
  }

  // Dialog untuk pilihan sumber gambar
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Pilih dari Galeri'),
            onTap: () {
              Navigator.of(context).pop();
              _pickImage();
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera),
            title: const Text('Ambil Foto'),
            onTap: () {
              Navigator.of(context).pop();
              _takePhoto();
            },
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menyimpan perubahan
  Future<void> _saveChanges() async {
    try {
      // Simpan path gambar ke database jika ada
      if (_savedImagePath != null) {
        await DatabaseHelper.instance.saveProfileImagePath(_savedImagePath!);
      }

      // Get current Firebase email if logged in
      final firebaseUser = _firebaseService.getCurrentUser();
      final String emailToUse = firebaseUser?.email ?? _emailController.text;

      // Simpan data profil ke database
      final user = await DatabaseHelper.instance.getFirstUser();
      if (user != null) {
        await DatabaseHelper.instance.updateUser(
          UserProfile(
            id: user.id,
            name: _nameController.text,
            email: emailToUse, // Always use Firebase email if available
            phone: _phoneController.text,
            imagePath: _savedImagePath,
          ),
        );
      }

      setState(() {
        _isEditing = false;
        // Update email field with Firebase email if available
        if (firebaseUser?.email != null) {
          _emailController.text = firebaseUser!.email!;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan profil: $e')),
      );
    }
  }

  // Fungsi untuk kembali ke halaman utama
  void _navigateBack() {
    if (widget.onNavigateToHome != null) {
      widget.onNavigateToHome!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateBack();
        return false; // Mencegah perilaku back default
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profil Saya'),
          backgroundColor: kPrimaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateBack,
          ),
          actions: [
            // Tombol Edit/Save
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _saveChanges();
                } else {
                  setState(() {
                    _isEditing = true;
                  });
                }
              },
              tooltip: _isEditing ? 'Simpan' : 'Edit Profil',
            ),
            // Tombol Logout
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _showLogoutConfirmation,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Foto profil dengan opsi untuk mengubah
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _getProfileImage(),
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: _showImageSourceOptions,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                // Informasi profil
                _buildProfileField(
                  icon: Icons.person,
                  label: 'Nama',
                  controller: _nameController,
                  enabled: _isEditing,
                ),
                _buildProfileField(
                  icon: Icons.email,
                  label: 'Email',
                  controller: _emailController,
                  enabled: false, // Always disable email editing since it comes from Firebase
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildProfileField(
                  icon: Icons.phone,
                  label: 'Nomor Telepon',
                  controller: _phoneController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 30),
                if (_isEditing)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    onPressed: _saveChanges,
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // New method to handle profile image loading
  ImageProvider _getProfileImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else {
      return const AssetImage('assets/images/default_avatar.png');
    }
  }

  // Widget untuk membuat field profil
  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool enabled = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: kPrimaryColor),
          labelText: label,
          labelStyle: TextStyle(color: enabled ? kPrimaryColor : Colors.grey),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}