import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import 'adopt_companion_page.dart';
import 'contact_form_page.dart';
import 'home_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'PawConnect',
          style: TextStyle(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
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
              // About Button
              ElevatedButton(
                onPressed: () {
                  print('=== ABOUT BUTTON PRESSED ===');
                  try {
                    showAboutDialog(
                      context: context,
                      applicationName: 'PawConnect',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.pets, size: 48),
                      children: const [
                        Text('Connect to a social space for pet adoption!'),
                        SizedBox(height: 16),
                        Text('© 2024 PawConnect'),
                      ],
                    );
                    print('About dialog shown');
                  } catch (e) {
                    print('Error showing about dialog: $e');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('About PawConnect v1.0.0')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'ABOUT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // TEST BUTTON - Simple functionality check
              ElevatedButton(
                onPressed: () {
                  print('TEST BUTTON WORKS!');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Button is working!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'TEST BUTTON',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              // Go to Home button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Go to Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Send us your info button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ContactFormPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Send us your info',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Explore button - navigate to adopt companion
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdoptCompanionPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Explore',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
