import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../constants/colors.dart';
import '../models/pet.dart';
import '../services/pet_storage_service.dart';
import 'pet_detail_page.dart';

class AllPetsPage extends StatefulWidget {
  const AllPetsPage({super.key});

  @override
  State<AllPetsPage> createState() => _AllPetsPageState();
}

class _AllPetsPageState extends State<AllPetsPage> {
  int selectedCategory = 0;
  final PetStorageService _petStorageService = PetStorageService();
  bool _isLoading = true;
  List<Pet> _listedPets = [];

  final List<String> categories = ['All', 'Dog', 'Cat', 'Bird', 'Hamster'];
  final List<String> categoryIcons = ['🐾', '🐕', '🐈', '🐦', '🐹'];

  List<Pet> get displayedPets {
    final selected = categories[selectedCategory];
    final listed = selected == 'All'
        ? _listedPets
        : _listedPets.where((pet) => pet.category == selected).toList();
    return listed;
  }

  @override
  void initState() {
    super.initState();
    _loadListedPets();
  }

  Future<void> _loadListedPets() async {
    final maps = await _petStorageService.getAllPets();
    if (!mounted) return;
    setState(() {
      _listedPets = maps.map((m) => _petStorageService.mapToPet(m)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'All Pets',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Categories
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  categories.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = index;
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: selectedCategory == index
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: selectedCategory == index
                                  ? null
                                  : Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                            ),
                            child: Center(
                              child: Text(
                                categoryIcons[index],
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            categories[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: selectedCategory == index
                                  ? AppColors.primary
                                  : AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Pet Grid
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: displayedPets.isEmpty
                        ? const Center(
                            child: Text(
                              'No user listings yet',
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.75,
                            ),
                            itemCount: displayedPets.length,
                            itemBuilder: (context, index) {
                              return _buildPetCard(displayedPets[index]);
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDetailPage(
              petId: pet.id,
              ownerId: pet.ownerId,
              name: pet.name,
              breed: pet.breed,
              age: pet.age ?? 'Unknown',
              gender: pet.gender ?? 'Unknown',
              image: pet.image,
              description: pet.description ??
                  'Friendly pet looking for a loving and responsible home.',
              ownerName: pet.ownerName ?? 'Foster Owner',
              location: pet.location ?? 'Cebu City',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: _buildPetImage(pet.image),
                ),
              ),
            ),
            // Pet Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pet.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pet.breed,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pet.age ?? 'Unknown',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetImage(String image) {
    if (image.isNotEmpty && image.startsWith('assets/')) {
      return Image.asset(image, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
    }
    if (image.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(image);
        return Image.memory(bytes, fit: BoxFit.cover, width: double.infinity, height: double.infinity);
      } catch (_) {}
    }
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.pets,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }
}
