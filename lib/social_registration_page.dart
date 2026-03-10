import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_container.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/top_nav_bar.dart';
import '../services/auth_service.dart';
import '../services/blockchain_encryption_service.dart';
import '../registration_success_page.dart';

class SocialRegistrationPage extends StatefulWidget {
  final String providerName;

  const SocialRegistrationPage({super.key, required this.providerName});

  @override
  State<SocialRegistrationPage> createState() => _SocialRegistrationPageState();
}

class _SocialRegistrationPageState extends State<SocialRegistrationPage> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  String? _verificationId;

  void _navigateToSuccessPage() {
    // Generate a placeholder username ID for social registrants
    final generatedId = DateTime.now().millisecondsSinceEpoch.toString().substring(5);
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => RegistrationSuccessPage(
          username: generatedId,
          email: _emailController.text,
          mobileNumber: _mobileController.text,
          password: _passwordController.text,
        ),
      ),
    );
  }

  void _sendOTP() async {
    final mobileNumber = _mobileController.text.trim();
    if (mobileNumber.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final fullNumber = '+91$mobileNumber'; 
    
    await _authService.verifyPhoneNumber(
      phoneNumber: fullNumber,
      onCodeSent: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent successfully! (Check console for 123456)')),
        );
      },
      onError: (String error) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
  }

  bool _validatePasswords() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return false;
    }

    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecial = RegExp(r'[!@#\$&*~`%^()_\-+={\[}\]|\\:;"<,>.?/]').hasMatch(password);

    if (!hasLetter || !hasNumber || !hasSpecial || password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 8 chars long and contain a letter, number, and special character.'),
          duration: Duration(seconds: 4),
        ),
      );
      return false;
    }
    return true;
  }

  void _verifyOTPAndRegister() async {
    if (!_validatePasswords()) return;
    
    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please click Send OTP first.')),
      );
      return;
    }

    final otpCode = _otpController.text.trim();
    if (otpCode.isEmpty || otpCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid OTP code.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Register logic simulating creation on the Go backend
      final response = await BlockchainEncryptionService().register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!response.success) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
        return;
      }

      // 2. Perform OTP sign-in simulation
      await _authService.signInWithOTP(
        verificationId: _verificationId!,
        smsCode: otpCode,
      );
      setState(() => _isLoading = false);
      
      _navigateToSuccessPage();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Social Registration failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/data_cloud_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          
          const TopNavBar(isLogin: false),
          
          Positioned.fill(
            top: 100,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 40),
              child: Center(
                child: GlassContainer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: AppColors.white),
                              onPressed: () => Navigator.pop(context),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Complete ${widget.providerName} Registration',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Email',
                        icon: Icons.email_outlined,
                        controller: _emailController,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Password',
                        icon: Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Confirm Password',
                        icon: Icons.lock_outline,
                        controller: _confirmPasswordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Mobile Number',
                        icon: Icons.phone_android,
                        controller: _mobileController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isLoading ? null : _sendOTP,
                          child: _isLoading && _verificationId == null
                              ? const SizedBox(
                                  width: 15, 
                                  height: 15, 
                                  child: CircularProgressIndicator(strokeWidth: 2)
                                )
                              : const Text(
                                  'Send OTP',
                                  style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      CustomTextField(
                        label: 'Verification Code',
                        icon: Icons.domain_verification,
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _verifyOTPAndRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading && _verificationId != null
                              ? const CircularProgressIndicator(color: AppColors.white)
                              : const Text(
                                  'Register Account',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
