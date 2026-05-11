import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../widgets/custom_button.dart';
import 'adopt_companion_page.dart';
import 'contact_form_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              // About PawConnect heading
              const Text('About PawConnect', style: AppStyles.heading2),
              const SizedBox(height: 24),
              // About PawConnect image
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/AboutImage.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Description text
              const Text(
                'Connect to a social space designed to bring together and celebrate pet owners and pet lovers from all around you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.darkText,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),
              // Contact Information Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem('📧', 'info@pawconnect.com'),
                    const SizedBox(height: 8),
                    _buildContactItem('📞', '+1 (555) 123-4567'),
                    const SizedBox(height: 8),
                    _buildContactItem('📍', '123 Pet Street, Furry City'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Send us your info button
              CustomButton(
                text: 'Send us your info',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactFormPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Explore button - navigate to adopt companion
              CustomButton(
                text: 'Explore',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdoptCompanionPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(String icon, String text) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.darkText),
          ),
        ),
      ],
    );
  }
}
