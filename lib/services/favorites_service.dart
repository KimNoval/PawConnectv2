import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/pet.dart';
import '../services/auth_service.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();
  final AuthService _authService = AuthService();

  List<Pet> _favorites = [];
  bool _loaded = false;

  List<Pet> get favorites {
    return List.unmodifiable(_favorites);
  }

  String _favoritesKeyForUser(String userId) => 'favorites_$userId';

  Future<String?> _getCurrentUserId() async {
    final user = await _authService.getCurrentUser();
    return user?.id;
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final userId = await _getCurrentUserId();
    if (userId == null) {
      _favorites = [];
      _loaded = true;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = prefs.getString(_favoritesKeyForUser(userId));
    if (favoritesJson != null && favoritesJson.isNotEmpty) {
      final List<dynamic> decoded = json.decode(favoritesJson);
      _favorites = decoded
          .map(
            (json) => Pet(
              id: json['id'],
              ownerId: json['ownerId'],
              name: json['name'] ?? '',
              breed: json['breed'] ?? '',
              age: json['age'],
              gender: json['gender'],
              image: json['image'] ?? 'assets/images/dog1.png',
              description: json['description'],
              category: json['category'],
              ownerName: json['ownerName'],
              location: json['location'],
            ),
          )
          .toList();
    }
    _loaded = true;
  }

  Future<void> _saveFavorites() async {
    final userId = await _getCurrentUserId();
    if (userId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final favoritesJson = json.encode(
      _favorites
          .map(
            (pet) => {
              'id': pet.id,
              'ownerId': pet.ownerId,
              'name': pet.name,
              'breed': pet.breed,
              'age': pet.age,
              'gender': pet.gender,
              'image': pet.image,
              'description': pet.description,
              'category': pet.category,
              'ownerName': pet.ownerName,
              'location': pet.location,
            },
          )
          .toList(),
    );
    await prefs.setString(_favoritesKeyForUser(userId), favoritesJson);
  }

  Future<bool> isFavorite(Pet pet) async {
    await _ensureLoaded();
    return _favorites.any(
      (fav) =>
          (fav.id != null && pet.id != null)
              ? fav.id == pet.id
              : (fav.name == pet.name && fav.breed == pet.breed),
    );
  }

  Future<void> toggleFavorite(Pet pet) async {
    await _ensureLoaded();
    if (_favorites.any((fav) =>
        (fav.id != null && pet.id != null)
            ? fav.id == pet.id
            : (fav.name == pet.name && fav.breed == pet.breed))) {
      _favorites.removeWhere((fav) =>
          (fav.id != null && pet.id != null)
              ? fav.id == pet.id
              : (fav.name == pet.name && fav.breed == pet.breed));
    } else {
      _favorites.add(pet);
    }
    await _saveFavorites();
  }

  Future<void> refresh() async {
    _loaded = false;
    await _ensureLoaded();
  }
}
