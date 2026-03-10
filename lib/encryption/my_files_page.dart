import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/glass_container.dart';
import '../services/blockchain_encryption_service.dart';

class MyFilesPage extends StatefulWidget {
  const MyFilesPage({super.key});

  @override
  State<MyFilesPage> createState() => _MyFilesPageState();
}

class _MyFilesPageState extends State<MyFilesPage> {
  final BlockchainEncryptionService _encryptionService =
      BlockchainEncryptionService();
  List<dynamic> _files = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final files = await _encryptionService.getFiles();
      setState(() {
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _decryptAndDownload(int fileId) async {
    // In a real mobile app we'd save it using path_provider.
    // Since we want this to work simply everywhere, we can just open the backend URL directly
    // which streams the decrypted file with Content-Disposition attachment.
    final url = Uri.parse(
      '${BlockchainEncryptionService.baseUrl}/decrypt/file?id=$fileId',
    );
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch download URL')),
        );
      }
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
          Positioned.fill(
            top: 100,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Encrypted Files',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: AppColors.primaryDark,
                        ),
                        onPressed: _loadFiles,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Files secured via AES and Fully Homomorphic Encryption.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryDark,
                            ),
                          )
                        : _error != null
                        ? Center(
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          )
                        : _files.isEmpty
                        ? const Center(
                            child: Text(
                              'No encrypted files found.',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 18,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _files.length,
                            itemBuilder: (context, index) {
                              final file = _files[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: AppColors.primaryDark.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  leading: const Icon(
                                    Icons.lock_outline,
                                    color: AppColors.primaryDark,
                                    size: 32,
                                  ),
                                  title: Text(
                                    file['Filename'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Size: ${(file['Size'] / 1024).toStringAsFixed(2)} KB\nDate: ${file['CreatedAt']}',
                                    style: TextStyle(
                                      color: AppColors.primaryDark.withValues(
                                        alpha: 0.7,
                                      ),
                                    ),
                                  ),
                                  trailing: ElevatedButton.icon(
                                    onPressed: () =>
                                        _decryptAndDownload(file['ID']),
                                    icon: const Icon(
                                      Icons.lock_open,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Decrypt',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.shade600,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Go Back to Dashboard',
                      style: TextStyle(color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
