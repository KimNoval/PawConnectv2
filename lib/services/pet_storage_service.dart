import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet.dart';

class PetStorageService {
  static const String _petsKey = 'paw_connect_pets';
  static int _nextId = 1;

  // Get all pet listings
  Future<List<Map<String, dynamic>>> getAllPets() async {
    final prefs = await SharedPreferences.getInstance();
    final petsJson = prefs.getString(_petsKey);
    if (petsJson == null) return [];
    return List<Map<String, dynamic>>.from(json.decode(petsJson));
  }

  // Get pets listed by specific user
  Future<List<Map<String, dynamic>>> getUserPets(String userId) async {
    final allPets = await getAllPets();
    return allPets.where((pet) => pet['ownerId'] == userId).toList();
  }

  // Add new pet listing (CREATE)
  Future<Map<String, dynamic>> addPet({
    required String ownerId,
    required String ownerName,
    required String name,
    required String breed,
    required String category,
    String? age,
    String? gender,
    String? description,
    String? location,
    String image = 'assets/images/dog1.png',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petsJson = prefs.getString(_petsKey);
      List<Map<String, dynamic>> pets = [];
      if (petsJson != null) {
        pets = List<Map<String, dynamic>>.from(json.decode(petsJson));
      }

      final newPet = {
        'id': 'pet_${_nextId++}',
        'ownerId': ownerId,
        'ownerName': ownerName,
        'name': name,
        'breed': breed,
        'category': category,
        'age': age,
        'gender': gender,
        'description': description,
        'location': location,
        'image': image,
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'Available',
      };

      pets.add(newPet);
      await prefs.setString(_petsKey, json.encode(pets));

      return {'success': true, 'message': 'Pet listed successfully', 'pet': newPet};
    } catch (e) {
      return {'success': false, 'message': 'Failed to add pet: $e'};
    }
  }

  // Update pet listing (UPDATE)
  Future<Map<String, dynamic>> updatePet({
    required String petId,
    required String ownerId,
    String? name,
    String? breed,
    String? category,
    String? age,
    String? gender,
    String? description,
    String? status,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petsJson = prefs.getString(_petsKey);
      if (petsJson == null) {
        return {'success': false, 'message': 'No pets found'};
      }

      final pets = List<Map<String, dynamic>>.from(json.decode(petsJson));
      bool found = false;

      for (var i = 0; i < pets.length; i++) {
        if (pets[i]['id'] == petId && pets[i]['ownerId'] == ownerId) {
          if (name != null) pets[i]['name'] = name;
          if (breed != null) pets[i]['breed'] = breed;
          if (category != null) pets[i]['category'] = category;
          if (age != null) pets[i]['age'] = age;
          if (gender != null) pets[i]['gender'] = gender;
          if (description != null) pets[i]['description'] = description;
          if (status != null) pets[i]['status'] = status;
          pets[i]['updatedAt'] = DateTime.now().toIso8601String();
          found = true;
          break;
        }
      }

      if (!found) {
        return {'success': false, 'message': 'Pet not found or unauthorized'};
      }

      await prefs.setString(_petsKey, json.encode(pets));
      return {'success': true, 'message': 'Pet updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Update failed: $e'};
    }
  }

  // Delete pet listing (DELETE)
  Future<Map<String, dynamic>> deletePet({
    required String petId,
    required String ownerId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petsJson = prefs.getString(_petsKey);
      if (petsJson == null) {
        return {'success': false, 'message': 'No pets found'};
      }

      final pets = List<Map<String, dynamic>>.from(json.decode(petsJson));
      final originalLength = pets.length;
      pets.removeWhere((pet) => pet['id'] == petId && pet['ownerId'] == ownerId);

      if (pets.length == originalLength) {
        return {'success': false, 'message': 'Pet not found or unauthorized'};
      }

      await prefs.setString(_petsKey, json.encode(pets));
      return {'success': true, 'message': 'Pet removed successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Delete failed: $e'};
    }
  }

  // Convert stored pet map to Pet model
  Pet mapToPet(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] is String ? map['id'] as String : null,
      ownerId: map['ownerId'] is String ? map['ownerId'] as String : null,
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      age: map['age'],
      gender: map['gender'],
      image: map['image'] ?? 'assets/images/dog1.png',
      description: map['description'],
      category: map['category'],
      ownerName: map['ownerName'],
      location: map['location'],
    );
  }
}
