import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/services/phone_verification_service.dart';

/// Firebase implementation of PhoneVerificationService
/// 
/// Uses Firebase Phone Authentication for OTP verification.
/// Automatically handles SMS sending and verification through Firebase.
class FirebasePhoneVerificationService implements PhoneVerificationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String? _verificationId;
  int? _resendToken;

  @override
  Future<String> sendOTP(String phoneNumber) async {
    final completer = Completer<String>();

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification completed (Android only)
        // This happens when SMS is automatically detected
        await _auth.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          completer.completeError(
            Exception('The phone number format is invalid'),
          );
        } else if (e.code == 'too-many-requests') {
          completer.completeError(
            Exception('Too many requests. Please try again later'),
          );
        } else {
          completer.completeError(
            Exception('Verification failed: ${e.message}'),
          );
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
    );

    return completer.future;
  }

  @override
  Future<bool> verifyOTP(String verificationId, String otpCode) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        // Save phone verification in Firestore
        await _savePhoneVerification(userCredential.user!);
        return true;
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<String> resendOTP(String phoneNumber) async {
    // Use the resend token if available
    return sendOTP(phoneNumber);
  }

  @override
  Future<String?> getVerifiedPhoneNumber() async {
    final user = _auth.currentUser;
    return user?.phoneNumber;
  }

  @override
  Future<void> savePhoneNumber(String phoneNumber) async {
    // Phone number is already saved via Firebase Auth
    // This method is called after successful verification
    final user = _auth.currentUser;
    if (user != null) {
      await _savePhoneVerification(user);
    }
  }

  @override
  Future<void> removePhoneNumber() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Remove from Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({
        'phoneNumber': FieldValue.delete(),
        'phoneVerifiedAt': FieldValue.delete(),
      });
      
      // Sign out (but don't delete the account)
      await _auth.signOut();
    }
  }

  Future<void> _savePhoneVerification(User user) async {
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set({
      'phoneNumber': user.phoneNumber,
      'phoneVerifiedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
