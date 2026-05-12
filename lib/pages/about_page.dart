import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text('About', style: TextStyle(color: AppColors.darkText)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // App Logo and Name
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'PawConnect',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Text(
              'Connecting pets with loving families',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.darkText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),

            // Features Card
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      '🐾',
                      'Browse available pets for adoption',
                    ),
                    _buildFeatureItem('❤️', 'Save your favorite pets'),
                    _buildFeatureItem('💬', 'Direct messaging with pet owners'),
                    _buildFeatureItem('📝', 'Submit adoption requests'),
                    _buildFeatureItem('🏠', 'List your own pets for adoption'),
                    _buildFeatureItem('🔍', 'Advanced search filters'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Contact Information Card
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem('📧', 'info@pawconnect.com', true),
                    const SizedBox(height: 12),
                    _buildContactItem('📞', '+1 (555) 123-4567', true),
                    const SizedBox(height: 12),
                    _buildContactItem('🌐', 'www.pawconnect.com', true),
                    const SizedBox(height: 12),
                    _buildContactItem(
                      '📍',
                      '123 Pet Street, Furry City',
                      false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Social Media Card
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Follow Us',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSocialButton('Facebook', Icons.facebook),
                        _buildSocialButton('Twitter', Icons.alternate_email),
                        _buildSocialButton('Instagram', Icons.camera_alt),
                        _buildSocialButton('YouTube', Icons.play_arrow),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Legal Links
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildLegalLink('Terms of Service', () {
                      // Navigate to terms
                    }),
                    const Divider(),
                    _buildLegalLink('Privacy Policy', () {
                      // Navigate to privacy
                    }),
                    const Divider(),
                    _buildLegalLink('Licenses', () {
                      // Show licenses
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Made with ❤️ for pet lovers',
              style: TextStyle(fontSize: 16, color: AppColors.darkText),
            ),
            const SizedBox(height: 20),
            const Text(
              '© 2024 PawConnect. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: AppColors.darkText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String icon, String text, bool isClickable) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: AppColors.darkText),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String platform, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          platform,
          style: const TextStyle(fontSize: 12, color: AppColors.darkText),
        ),
      ],
    );
  }

  Widget _buildLegalLink(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
