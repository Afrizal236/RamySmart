import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign in with email and password - robust implementation
  // Enhanced signInWithEmailAndPassword method with PigeonUserDetails error handling
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      print('Firebase Service: Attempting login with email $email');

      // First attempt standard login
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('Firebase Service: Login successful for user: ${credential.user?.uid}');

      // Update last login timestamp in Firestore
      try {
        if (credential.user != null) {
          await _firestore.collection('users').doc(credential.user!.uid).update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }
      } catch (firestoreError) {
        // Non-critical error, just log it
        print('Firebase Service: Error updating last login: $firestoreError');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'user-disabled') {
        message = 'This user account has been disabled.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many failed login attempts. Please try again later.';
      } else {
        message = e.message ?? 'An error occurred during login.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } catch (e) {
      print('Login general error: ${e.toString()}');

      // Handle PigeonUserDetails error specifically
      if (e.toString().contains('PigeonUserDetails')) {
        print('Firebase Service: PigeonUserDetails error detected during login');

        // Wait a moment for Firebase to complete the operation
        await Future.delayed(const Duration(milliseconds: 500));

        // Check if user is logged in despite the error
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          print('Firebase Service: User is logged in despite error: ${currentUser.uid}');

          // Since we can't create a UserCredential directly, we'll try to get auth token
          // to confirm user is properly authenticated
          try {
            await currentUser.getIdToken();
            print('Firebase Service: User authentication confirmed via token');

            // Update last login timestamp in Firestore
            try {
              await _firestore.collection('users').doc(currentUser.uid).update({
                'lastLogin': FieldValue.serverTimestamp(),
              });
            } catch (firestoreError) {
              // Non-critical error, just log it
              print('Firebase Service: Error updating last login: $firestoreError');
            }

            // Return null but caller should check getCurrentUser() to handle this case
            return null;
          } catch (tokenError) {
            print('Firebase Service: Error getting token: $tokenError');
            // User might not be fully authenticated
          }
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  // Modified createUserWithEmailAndPassword function with enhanced error handling
  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
  }) async {
    try {
      print('Firebase Service: Attempting to create user with email $email');

      // First create user account
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      print('Firebase Service: User created successfully with UID: ${user?.uid}');

      // If user creation is successful
      if (user != null) {
        // 1. Update the display name safely
        try {
          // Small delay for Firebase to fully initialize
          await Future.delayed(const Duration(milliseconds: 500));

          try {
            // Try to update display name
            await user.updateDisplayName(name);
            print('Firebase Service: Display name updated successfully');
          } catch (displayNameError) {
            print('Firebase Service: Error updating display name: $displayNameError');

            // Special handling for PigeonUserDetails error
            if (displayNameError.toString().contains('PigeonUserDetails')) {
              print('Firebase Service: PigeonUserDetails error detected, continuing process');

              // Alternative approach - try to reload user and then update
              try {
                await user.reload();
                await Future.delayed(const Duration(milliseconds: 300));
                // Try again after reload
                await user.updateDisplayName(name);
                print('Firebase Service: Display name updated after reload');
              } catch (reloadError) {
                print('Firebase Service: Error after reload: $reloadError');
                // Continue even if this fails
              }
            }
          }
        } catch (e) {
          print('Firebase Service: Error in display name update process: $e');
          // Continue process even if display name update fails
        }

        // 2. Save user data to Firestore
        try {
          // Create user data map - include all necessary fields
          final Map<String, dynamic> userData = {
            'name': name,
            'email': email,
            'createdAt': FieldValue.serverTimestamp(),
            'uid': user.uid,
            'displayName': name, // Store display name in Firestore as backup
            'lastLogin': FieldValue.serverTimestamp(),
          };

          print('Firebase Service: Attempting to save data to Firestore...');

          // Use a transaction for better reliability
          await _firestore.runTransaction((transaction) async {
            final docRef = _firestore.collection('users').doc(user.uid);
            transaction.set(docRef, userData);
          }).timeout(
              const Duration(seconds: 10),
              onTimeout: () {
                print('Firebase Service: Timeout when saving to Firestore');
                throw Exception('Firestore timeout');
              }
          );

          print('Firebase Service: Data successfully saved to Firestore');
        } catch (firestoreError) {
          // Firestore error shouldn't stop the registration process
          print('Firebase Service: Error when saving to Firestore: $firestoreError');
          print('Firebase Service: Continuing process as account was already created');
        }

        // Always return the user if created successfully
        return user;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      String message;
      print('Firebase Service: FirebaseAuthException: ${e.code} - ${e.message}');

      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = e.message ?? 'An error occurred during sign up.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    } catch (e) {
      print('Firebase Service: Other error during signup: ${e.runtimeType} - $e');

      // Special handling for PigeonUserDetails error
      if (e.toString().contains('PigeonUserDetails')) {
        print('Firebase Service: Handling special PigeonUserDetails error');

        // Check if user was actually created despite the error
        await Future.delayed(const Duration(milliseconds: 1000));
        User? currentUser = _auth.currentUser;
        if (currentUser != null) {
          print('Firebase Service: User was still created despite error: ${currentUser.uid}');
          return currentUser;
        }
      }

      // Check if user was actually created despite any error
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        print('Firebase Service: User was created despite error: ${currentUser.uid}');
        return currentUser;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign up failed. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  // Reset password
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset link sent to your email'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Failed to send reset email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Enhanced sign out with proper error handling
  Future<bool> signOut({BuildContext? context}) async {
    try {
      print('Firebase Service: Attempting to sign out user');
      await _auth.signOut();
      print('Firebase Service: User signed out successfully');

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true;
    } catch (e) {
      print('Firebase Service: Error during sign out: $e');

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  // Get user email
  String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  // Get user display name
  String? getUserDisplayName() {
    return _auth.currentUser?.displayName;
  }

  // Get user ID
  String? getUserId() {
    return _auth.currentUser?.uid;
  }

  // Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}