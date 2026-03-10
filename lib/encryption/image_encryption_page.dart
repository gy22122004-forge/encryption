import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_colors.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/glass_container.dart';
import '../services/blockchain_encryption_service.dart';

class ImageEncryptionPage extends StatefulWidget {
  const ImageEncryptionPage({super.key});

  @override
  State<ImageEncryptionPage> createState() => _ImageEncryptionPageState();
}

class _ImageEncryptionPageState extends State<ImageEncryptionPage> {
  final BlockchainEncryptionService _encryptionService =
      BlockchainEncryptionService();

  bool _isLoading = false;
  String? _selectedFileName;
  List<int>? _selectedFileBytes;
  EncryptResponse? _response;
  String? _error;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() {
        _selectedFileName = result.files.single.name;
        _selectedFileBytes = result.files.single.bytes;
        _response = null;
        _error = null;
      });
    }
  }

  void _encryptData() async {
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image to encrypt')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _response = null;
    });

    try {
      if (_selectedFileBytes == null)
        throw Exception("Could not read file data.");

      final response = await _encryptionService.encryptFile(
        _selectedFileBytes!,
        _selectedFileName!,
      );
      setState(() {
        _response = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
            child: SingleChildScrollView(
              child: GlassContainer(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        size: 60,
                        color: AppColors.primaryDark,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Image Encryption',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // File Selection Area
                      InkWell(
                        onTap: _pickFile,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primaryDark.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _selectedFileName != null
                                    ? Icons.check_circle
                                    : Icons.upload_file,
                                color: _selectedFileName != null
                                    ? Colors.green
                                    : AppColors.primaryDark,
                                size: 40,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _selectedFileName ?? 'Tap to select an image',
                                style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontWeight: _selectedFileName != null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      if (_error != null)
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
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
                          onPressed: _isLoading || _selectedFileName == null
                              ? null
                              : _encryptData,
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
          ),
        ],
      ),
    );
  }
}
