import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../constants/colors.dart';
import '../models/pet.dart';
import '../services/pet_storage_service.dart';
import 'pet_detail_page.dart';

class PetListPage extends StatefulWidget {
  final String category;
  final String categoryIcon;

  const PetListPage({
    super.key,
    required this.category,
    required this.categoryIcon,
  });

  @override
  State<PetListPage> createState() => _PetListPageState();
}

class _PetListPageState extends State<PetListPage> {
  final PetStorageService _petStorageService = PetStorageService();
  List<Pet> _listedPets = [];
  bool _isLoading = true;

  List<Pet> get availablePets {
    final filteredListed = _listedPets.where((p) => p.category == widget.category).toList();
    return filteredListed;
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(''),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      widget.categoryIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: availablePets.isEmpty
                  ? const Center(
                      child: Text(
                        'No listings in this category yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: availablePets.length,
                      itemBuilder: (context, index) {
                        return _buildPetCard(availablePets[index]);
                      },
                    ),
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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Image
            Container(
              height: 200,
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
            // Pet Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        pet.breed,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        pet.age ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pet.gender ?? 'Unknown',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetImage(String image) {
    if (image.isNotEmpty && image.startsWith('assets/')) {
      return Image.asset(
        image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (image.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(image);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
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
          size: 40,
        ),
      ),
    );
  }
}
