import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/auth_service.dart';
import '../social_registration_page.dart';

class SocialLoginButtons extends StatefulWidget {
  const SocialLoginButtons({super.key});

  @override
  State<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends State<SocialLoginButtons> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  void _handleSocialLogin(Future<void> Function() loginMethod, String provider) async {
    setState(() => _isLoading = true);
    
    // Show a loading snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Logging in with $provider...'),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      await loginMethod();
      // If successful, navigate to Social Registration page
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SocialRegistrationPage(providerName: provider),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString();
        // Clean up the Exception: prefix if it exists
        if (errorMessage.startsWith('Exception: ')) {
          errorMessage = errorMessage.substring(11);
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryDark),
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Divider(
                color: AppColors.primaryDark.withValues(alpha: 0.5),
                thickness: 1,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Or continue with',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppColors.primaryDark.withValues(alpha: 0.5),
                thickness: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              assetPath: 'assets/icons/google.png',
              onPressed: () => _handleSocialLogin(_authService.signInWithGoogle, 'Google'),
            ),
            const SizedBox(width: 20),
            _buildSocialButton(
              assetPath: 'assets/icons/apple.png',
              onPressed: () => _handleSocialLogin(_authService.signInWithApple, 'Apple'),
            ),
            const SizedBox(width: 20),
            _buildSocialButton(
              assetPath: 'assets/icons/facebook.png',
              onPressed: () => _handleSocialLogin(_authService.signInWithFacebook, 'Facebook'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String assetPath,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
          ),
        ),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
