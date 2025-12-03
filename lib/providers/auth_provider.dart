import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../models/user_model.dart';

enum AuthState { initial, authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  AuthState _authState = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthState get authState => _authState;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _authState == AuthState.authenticated;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authState = AuthState.loading;
    notifyListeners();

    // Listen to authentication state changes
    _firebaseService.auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserData(user.uid);
      } else {
        _authState = AuthState.unauthenticated;
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firebaseService.usersCollection.doc(uid).get();
      if (userDoc.exists) {
        _currentUser = UserModel.fromFirestore(userDoc);
        _authState = AuthState.authenticated;
      } else {
        // User exists in Auth but not in Firestore - create profile
        await _createUserProfile();
      }
    } catch (e) {
      _errorMessage = 'Failed to load user data: $e';
      _authState = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> _createUserProfile() async {
    User? firebaseUser = _firebaseService.currentUser;
    if (firebaseUser != null) {
      UserModel newUser = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email!,
        name: firebaseUser.displayName ?? 'User',
        phoneNumber: firebaseUser.phoneNumber,
        role: UserRole.citizen, // Default role
        createdAt: DateTime.now(),
        isVerified: false,
        profileImageUrl: firebaseUser.photoURL,
      );

      await _firebaseService.usersCollection.doc(firebaseUser.uid).set(newUser.toFirestore());
      _currentUser = newUser;
      _authState = AuthState.authenticated;
      notifyListeners();
    }
  }

  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      _authState = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      await _firebaseService.signInWithEmailAndPassword(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _authState = AuthState.unauthenticated;
      _errorMessage = _getAuthErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _authState = AuthState.unauthenticated;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createUserWithEmailAndPassword(String email, String password, String name) async {
    try {
      _authState = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      UserCredential result = await _firebaseService.createUserWithEmailAndPassword(email, password);

      // Update display name
      await result.user?.updateDisplayName(name);

      // Create user profile in Firestore
      await _createUserProfile();

      return true;
    } on FirebaseAuthException catch (e) {
      _authState = AuthState.unauthenticated;
      _errorMessage = _getAuthErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _authState = AuthState.unauthenticated;
      _errorMessage = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
      _authState = AuthState.unauthenticated;
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to sign out: $e';
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseService.auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send password reset email: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      await _firebaseService.usersCollection.doc(updatedUser.id).update(updatedUser.toFirestore());
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      notifyListeners();
      return false;
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
