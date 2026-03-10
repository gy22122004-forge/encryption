import 'package:flutter/material.dart';
import 'theme/app_colors.dart';
import 'widgets/top_nav_bar.dart';
import 'widgets/glass_container.dart';
import 'responsive.dart';

// Import feature pages
import 'encryption/text_encryption_page.dart';
import 'encryption/image_encryption_page.dart';
import 'encryption/document_encryption_page.dart';
import 'encryption/video_encryption_page.dart';
import 'encryption/fhe_simulation_page.dart';
import 'encryption/my_files_page.dart';
import 'messaging/messages_page.dart';

class EncryptionDashboard extends StatelessWidget {
  const EncryptionDashboard({super.key});

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget targetPage,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: GlassContainer(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppColors.primaryDark),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/data_cloud_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // Navigation Bar
          const TopNavBar(isLogin: false),

          // Main Content Grid
          Positioned.fill(
            top: 100, // Space for top nav bar
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Encryption Dashboard',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Select a tool to encrypt your data securely.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Grid of Encryption Options
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: Responsive.isDesktop(context)
                          ? 4
                          : Responsive.isTablet(context)
                          ? 3
                          : 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: Responsive.isDesktop(context)
                          ? 1.2
                          : 1.0,
                      children: [
                        _buildDashboardCard(
                          context,
                          title: 'Text\nEncryption',
                          icon: Icons.text_fields_outlined,
                          targetPage: const TextEncryptionPage(),
                        ),
                        _buildDashboardCard(
                          context,
                          title: 'Image\nEncryption',
                          icon: Icons.image_outlined,
                          targetPage: const ImageEncryptionPage(),
                        ),
                        _buildDashboardCard(
                          context,
                          title: 'Document\nEncryption',
                          icon: Icons.description_outlined,
                          targetPage: const DocumentEncryptionPage(),
                        ),
                        _buildDashboardCard(
                          context,
                          title: 'Video\nEncryption',
                          icon: Icons.video_library_outlined,
                          targetPage: const VideoEncryptionPage(),
                        ),
                        _buildDashboardCard(
                          context,
                          title: 'Advanced\nFHE Module',
                          icon: Icons.security_outlined,
                          targetPage: const FheSimulationPage(),
                        ),
                        _buildDashboardCard(
                          context,
                          title: 'My Encrypted\nFiles',
                          icon: Icons.folder_special_outlined,
                          targetPage: const MyFilesPage(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Floating Action Button for Messages
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MessagesPage()),
          );
        },
        backgroundColor: AppColors.primaryDark,
        elevation: 4,
        icon: const Icon(Icons.forum, color: AppColors.white),
        label: const Text(
          'Messages',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
