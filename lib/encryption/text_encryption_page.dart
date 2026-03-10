import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/glass_container.dart';
import '../widgets/custom_text_field.dart';
import '../services/blockchain_encryption_service.dart';
import 'dart:convert';

class TextEncryptionPage extends StatefulWidget {
  const TextEncryptionPage({super.key});

  @override
  State<TextEncryptionPage> createState() => _TextEncryptionPageState();
}

class _TextEncryptionPageState extends State<TextEncryptionPage> {
  final TextEditingController _textController = TextEditingController();
  final BlockchainEncryptionService _encryptionService =
      BlockchainEncryptionService();

  bool _isLoading = false;
  EncryptResponse? _response;
  String? _error;

  void _encryptData() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text to encrypt')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _response = null;
    });

    try {
      final fileBytes = utf8.encode(text);
      final filename =
          'text_message_${DateTime.now().millisecondsSinceEpoch}.txt';

      final response = await _encryptionService.encryptFile(
        fileBytes,
        filename,
      );
      setState(() {
        _response = response;
        _isLoading = false;
        _textController.clear();
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
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
          Center(
            child: GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.text_fields_outlined,
                      size: 60,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Text Encryption',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Enter text to encrypt',
                      icon: Icons.text_snippet,
                      controller: _textController,
                    ),
                    const SizedBox(height: 20),
                    if (_error != null)
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    if (_response != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '✅ Secured on testnet',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Block Index: ${_response!.blockchainEntry.index}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              'Block Hash: ${_response!.blockchainEntry.hash}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _encryptData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: AppColors.white,
                              )
                            : const Text(
                                'Encrypt & Secure',
                                style: TextStyle(color: AppColors.white),
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
