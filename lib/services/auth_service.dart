import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  // Instances
  // Note: Removed GoogleSignIn instance as it requires web configuration.
  
  /// Google Sign In
  Future<void> signInWithGoogle() async {
    try {
      debugPrint('Initiating Google Sign-In...');
      // Simulated Google Sign-In for testing
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Simulated Google Sign-In Success!');
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      rethrow;
    }
  }

  /// Apple Sign In
  Future<void> signInWithApple() async {
    try {
      debugPrint('Initiating Apple Sign-In...');
      // Note: Requires Apple Developer Portal configuration (Services ID, Keys)
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      debugPrint('Apple Sign-In Success! Identity Token: ${credential.identityToken}');
      // TODO: Send credential.identityToken to Go backend to verify.
    } catch (e) {
      debugPrint('Error during Apple Sign-In: $e');
      rethrow;
    }
  }

  /// Facebook Sign In
  Future<void> signInWithFacebook() async {
    try {
      debugPrint('Initiating Facebook Sign-In...');
      // Note: Requires Facebook App ID configured in Android/iOS/Web
      final LoginResult result = await FacebookAuth.instance.login();
      
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        debugPrint('Facebook Sign-In Success! Token: ${accessToken.tokenString}');
        // TODO: Send accessToken.tokenString to Go backend to verify.
      } else {
        debugPrint('Facebook Sign-In Status: ${result.status}');
        debugPrint('Facebook Sign-In Message: ${result.message}');
      }
    } catch (e) {
      debugPrint('Error during Facebook Sign-In: $e');
      rethrow;
    }
  }

  /// Send SMS OTP Verification (SIMULATED FOR TESTING)
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      debugPrint('Initiating SIMULATED Phone Verification for: $phoneNumber');
      
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Generate a fake 6-digit OTP for testing
      final fakeOtpCode = '123456'; 
      final fakeVerificationId = 'simulated_vid_${DateTime.now().millisecondsSinceEpoch}';
      
      debugPrint('===================================================');
      debugPrint('🚨 SIMULATED OTP CODE FOR $phoneNumber is: $fakeOtpCode 🚨');
      debugPrint('===================================================');
      
      onCodeSent(fakeVerificationId);
    } catch (e) {
      debugPrint('Simulated verify phone error: $e');
      onError(e.toString());
    }
  }

  /// Sign In with SMS OTP (SIMULATED FOR TESTING)
  Future<void> signInWithOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      if (verificationId.startsWith('simulated_vid_') && smsCode == '123456') {
        debugPrint('Simulated OTP Verification Successful!');
        return; // Success
      } else {
        throw Exception('Invalid Simulated OTP Code. Please enter 123456');
      }
    } catch (e) {
      debugPrint('Failed to verify Simulated OTP: $e');
      rethrow;
    }
  }
}
