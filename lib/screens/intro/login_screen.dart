import 'package:flutter/material.dart';
import 'package:ramysmart/util/constants.dart';
import 'package:ramysmart/util/route_name.dart';
import 'package:ramysmart/screens/Home/database/firebase_service.dart';
import 'package:ramysmart/screens/Home/database/user_database.dart';
import 'package:ramysmart/screens/Home/course_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscure = true;
  bool _isLoading = false;

  // Firebase service instance
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to update local database with Firebase user info
  Future<void> _updateLocalUserDatabase() async {
    try {
      final currentUser = _firebaseService.getCurrentUser();
      if (currentUser != null && currentUser.email != null) {
        // Get current user from database
        final localUser = await DatabaseHelper.instance.getFirstUser();

        if (localUser != null) {
          // Update local user with Firebase email
          await DatabaseHelper.instance.updateUser(
            UserProfile(
              id: localUser.id,
              name: localUser.name,
              email: currentUser.email!, // Use Firebase email
              phone: localUser.phone,
              imagePath: localUser.imagePath,
            ),
          );
          print('Local user database updated with Firebase email: ${currentUser.email}');
        } else {
          // Create new user if none exists
          await DatabaseHelper.instance.insertUser(
            UserProfile(
              name: currentUser.displayName ?? "User",
              email: currentUser.email!,
              phone: "+62 812 3456 7890", // Default phone
            ),
          );
          print('Created new local user profile with Firebase email: ${currentUser.email}');
        }
      }
    } catch (e) {
      print('Error updating local database: $e');
    }
  }

  // Function to check if user has completed SNBT questionnaire
  Future<bool> _hasCompletedSNBT() async {
    try {
      final currentUser = _firebaseService.getCurrentUser();
      if (currentUser != null) {
        // You can implement this based on your preference:
        // Option 1: Check from local database
        // Option 2: Check from Firebase/shared preferences
        // Option 3: Always show SNBT on first login

        // For now, we'll assume new users haven't completed SNBT
        // You can modify this logic based on your requirements
        return false; // Always show SNBT for demonstration
      }
      return false;
    } catch (e) {
      print('Error checking SNBT completion status: $e');
      return false; // Default to showing SNBT if there's an error
    }
  }

  // Function to handle login - FIXED FOR PROPER NAVIGATION
  Future<void> _login() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('LoginScreen: Starting login process');

      // Get form data
      final String email = _emailController.text.trim();
      final String password = _passwordController.text;

      // Clear any previous error messages
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      // Attempt login using FirebaseService
      final credential = await _firebaseService.signInWithEmailAndPassword(
        email: email,
        password: password,
        context: context,
      );

      // Check if the login worked
      final currentUser = _firebaseService.getCurrentUser();
      final bool isLoggedIn = credential != null || currentUser != null;

      // Reset loading state if still mounted
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // If component is no longer mounted, exit early
      if (!mounted) return;

      if (isLoggedIn) {
        print('LoginScreen: Login successful, user ID: ${currentUser?.uid}');

        // Update local database with Firebase user info
        await _updateLocalUserDatabase();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // Small delay for snackbar
        await Future.delayed(const Duration(milliseconds: 500));

        // Check if user has completed SNBT questionnaire
        if (mounted) {
          final hasCompletedSNBT = await _hasCompletedSNBT();

          // Navigate to CourseHome with proper navigation
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => CourseHome(
                showSNBTPopup: !hasCompletedSNBT, // Show popup if SNBT not completed
              ),
            ),
                (route) => false, // Remove all previous routes
          );
        }

      } else {
        print('LoginScreen: Login failed - user not logged in after attempt');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login failed. Please check your credentials and try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('LoginScreen: Unhandled exception: $e');

      // Reset loading state
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Final safety check - see if user is logged in despite errors
      final lastChanceUser = _firebaseService.getCurrentUser();
      if (lastChanceUser != null) {
        print('LoginScreen: User is logged in despite errors, navigating to home');

        // Update local database before navigation
        await _updateLocalUserDatabase();

        try {
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            final hasCompletedSNBT = await _hasCompletedSNBT();

            // Navigate to CourseHome
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => CourseHome(
                  showSNBTPopup: !hasCompletedSNBT,
                ),
              ),
                  (route) => false,
            );
          }
        } catch (navError) {
          print('LoginScreen: Last-chance navigation error: $navError');
        }
      }
    }
  }

  // Function to handle password reset
  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();

    // Show a dialog to enter email
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController resetEmailController =
        TextEditingController(text: email);

        return AlertDialog(
          title: const Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email to receive a password reset link:'),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Close dialog first
                Navigator.pop(context);
                // Then send reset email with the updated email
                _firebaseService.resetPassword(
                  email: resetEmailController.text.trim(),
                  context: context,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
              ),
              child: const Text('Send Reset Link'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                // Logo atau Gambar
                Image.asset(
                  "assets/images/intro/intro.jpg",
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    // Handle gambar tidak ditemukan
                    return Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    );
                  },
                ),
                const SizedBox(height: 30),
                // Judul
                Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Sign in to continue learning",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: kPrimaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: kPrimaryColor, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(color: kPrimaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, RouteNames.signup);
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}