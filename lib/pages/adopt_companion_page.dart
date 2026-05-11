import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../models/pet.dart';
import '../widgets/custom_button.dart';
import 'home_page.dart';

class AdoptCompanionPage extends StatefulWidget {
  const AdoptCompanionPage({super.key});

  @override
  State<AdoptCompanionPage> createState() => _AdoptCompanionPageState();
}

class _AdoptCompanionPageState extends State<AdoptCompanionPage> {
  int currentIndex = 0;

  final List<Pet> pets = [
    Pet(
      name: 'Max',
      breed: 'Pug',
      image: 'assets/images/Max.jpg',
      description: 'A friendly and playful companion',
    ),
    Pet(
      name: 'Bella',
      breed: 'Persian Cat',
      image: 'assets/images/Bella.webp',
      description: 'A calm and affectionate friend',
    ),
    Pet(
      name: 'Charlie',
      breed: 'Shih Tzu',
      image: 'assets/images/Charlie.jpg',
      description: 'An energetic and loyal companion',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Heading
              const Text(
                'Adopt a Furever\nCompanion',
                textAlign: TextAlign.center,
                style: AppStyles.heading2,
              ),
              const SizedBox(height: 24),
              // Pet card carousel
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[300],
                ),
                child: PageView.builder(
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemCount: pets.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[300],
                        image: DecorationImage(
                          image: AssetImage(pets[index].image),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: pets[index].image.isEmpty
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.pets,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Dots indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pets.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: currentIndex == index ? 24 : 8,
                    decoration: BoxDecoration(
                      color: currentIndex == index
                          ? AppColors.primary
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Pet details
              Column(
                children: [
                  Text(
                    pets[currentIndex].name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pets[currentIndex].breed,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pets[currentIndex].description ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.darkText,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Skip to next pet
                        if (currentIndex < pets.length - 1) {
                          setState(() {
                            currentIndex++;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.close, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Adopt',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
