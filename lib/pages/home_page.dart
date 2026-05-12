import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../constants/colors.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../models/pet.dart';
import 'pet_list_page.dart';
import 'all_pets_page.dart';
import 'pet_detail_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import 'my_pets_page.dart';
import 'chat_list_page.dart';
import 'settings_page.dart';
import 'splash_screen.dart';
import '../services/pet_storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedCategory = 0;
  int selectedNavIndex = 0;
  final TextEditingController searchController = TextEditingController();
  final PetStorageService _petStorageService = PetStorageService();
  List<Pet> _userPets = [];
  List<Pet> _filteredPets = [];
  bool _isSearching = false;

  final List<String> categories = ['All', 'Dog', 'Cat', 'Bird', 'Hamster'];
  final List<String> categoryIcons = ['🐾', '🐕', '🐈', '🐦', '🐹'];

  @override
  void initState() {
    super.initState();
    _loadUserPets();
    _filteredPets = [];
    searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadUserPets() async {
    final allPets = await _petStorageService.getAllPets();
    setState(() {
      _userPets = allPets.map((p) => _petStorageService.mapToPet(p)).toList();
      _filteredPets = [..._userPets];
    });
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _filteredPets = [..._userPets];
      } else {
        _isSearching = true;
        _filteredPets = [..._userPets].where((pet) {
          return pet.name.toLowerCase().contains(query) ||
              pet.breed.toLowerCase().contains(query) ||
              (pet.category?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.darkText,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListPage()),
              );
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: AppColors.darkText),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.pets, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'PawConnect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: AppColors.primary),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets, color: AppColors.primary),
              title: const Text('All Pets'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllPetsPage(category: 'All'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: AppColors.primary),
              title: const Text('Favorites'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.primary),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle, color: AppColors.primary),
              title: const Text('List My Pet'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyPetsPage()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primary),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: AppColors.primary),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start your Journey with a Loving Pet',
              style: const TextStyle(fontSize: 25, color: AppColors.darkText),
            ),
            const SizedBox(height: 16),
            // Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search pets by name or breed...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Categories
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  categories.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PetListPage(
                              category: categories[index],
                              categoryIcon: categoryIcons[index],
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
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
                                style: const TextStyle(fontSize: 32),
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
            const SizedBox(height: 32),
            // List Your Pet Button
            InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyPetsPage()),
                );
                _loadUserPets();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'List Your Pet for Adoption',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Listings
            Text(
              _isSearching ? 'Search Results' : 'Pet Listings',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16),
            _filteredPets.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: const Text(
                      'No pets found',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        _filteredPets.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: _buildPetCard(_filteredPets[index]),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedNavIndex,
        onTap: (index) {
          if (index == 1) {
            // Navigate to All Pets page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllPetsPage(category: 'All'),
              ),
            );
          } else if (index == 2) {
            // Navigate to Favorites page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesPage()),
            );
          } else if (index == 3) {
            // Navigate to Profile page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          } else {
            // Home page - already here
            setState(() {
              selectedNavIndex = index;
            });
          }
        },
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
              description:
                  pet.description ??
                  'Friendly pet looking for a loving and responsible home.',
              ownerName: pet.ownerName ?? 'Foster Owner',
              location: pet.location ?? 'Cebu City',
            ),
          ),
        );
      },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primary.withOpacity(0.2),
          border: Border.all(color: AppColors.primary, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Image
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                color: Colors.grey[300],
              ),
              child: _buildPetImage(pet.image),
            ),
            // Pet Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      Text(
                        '${pet.gender} • ${pet.age}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
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
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
        child: Image.asset(
          image,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    if (image.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(image);
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      } catch (_) {}
    }
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.pets, color: Colors.white, size: 40),
      ),
    );
  }
}
