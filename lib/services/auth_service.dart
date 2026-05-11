import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_user;

class AuthService {
  static const String _usersKey = 'paw_connect_users';
  static const String _currentUserKey = 'paw_connect_current_user';

  // Helper method to generate next unique ID based on existing users
  Future<String> _getNextUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    int maxId = 0;
    if (usersJson != null && usersJson.isNotEmpty) {
      try {
        final decoded = json.decode(usersJson);
        if (decoded is List) {
          for (var item in decoded) {
            if (item is Map<String, dynamic> && item['id'] is String) {
              final idStr = (item['id'] as String).replaceFirst('user_', '');
              final idNum = int.tryParse(idStr) ?? 0;
              if (idNum > maxId) maxId = idNum;
            }
          }
        }
      } catch (e) {
        // If there's an error parsing, just use 0
      }
    }

    return 'user_${maxId + 1}';
  }

  // Register a new user (CREATE)
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Validation
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'All fields are required'};
      }

      if (!email.contains('@')) {
        return {'success': false, 'message': 'Invalid email format'};
      }

      if (password.length < 6) {
        return {
          'success': false,
          'message': 'Password must be at least 6 characters',
        };
      }

      // Get existing users — if stored data is corrupted, wipe it and start fresh
      List<Map<String, dynamic>> users = [];
      try {
        final usersJson = prefs.getString(_usersKey);
        if (usersJson != null && usersJson.isNotEmpty) {
          final decoded = json.decode(usersJson);
          if (decoded is List) {
            for (var item in decoded) {
              if (item is Map<String, dynamic>) {
                users.add(item);
              }
            }
          }
        }
      } catch (e) {
        // Corrupted storage — clear it so registration can proceed
        await prefs.remove(_usersKey);
      }

      // Check if email already exists
      for (var user in users) {
        if (user['email'] == email) {
          return {'success': false, 'message': 'Email already registered'};
        }
      }

      // Create new user with unique ID
      final nextId = await _getNextUserId();
      final newUser = app_user.User(
        id: nextId,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      users.add(
        newUser.toMap()
          ..['id'] = newUser.id
          ..['password'] = password,
      );
      await prefs.setString(_usersKey, json.encode(users));

      // Set as current user
      await prefs.setString(
        _currentUserKey,
        json.encode(newUser.toMap()..['id'] = newUser.id),
      );

      return {
        'success': true,
        'message': 'Account created successfully',
        'user': newUser,
      };
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  // Clear all stored auth data (useful for debugging)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_currentUserKey);
  }

  // Login user (READ/Auth)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'Email and password required'};
      }

      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) {
        return {'success': false, 'message': 'No users found'};
      }

      final decoded = json.decode(usersJson);
      if (decoded is! List) {
        return {'success': false, 'message': 'Corrupted user data'};
      }
      final users = <Map<String, dynamic>>[];
      for (var item in decoded) {
        if (item is Map<String, dynamic>) {
          users.add(item);
        }
      }

      for (var userData in users) {
        if (userData['email'] == email && userData['password'] == password) {
          final id = userData['id'];
          if (id is! String) {
            return {'success': false, 'message': 'Corrupted user record'};
          }
          final user = app_user.User.fromMap(userData, id);
          await prefs.setString(_currentUserKey, json.encode(userData));
          return {'success': true, 'message': 'Login successful', 'user': user};
        }
      }

      return {'success': false, 'message': 'Invalid email or password'};
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  // Get user data (READ)
  Future<app_user.User?> getUserData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) return null;

      final decoded = json.decode(usersJson);
      if (decoded is! List) return null;
      for (var item in decoded) {
        if (item is Map<String, dynamic>) {
          final id = item['id'];
          if (id is String && id == userId) {
            return app_user.User.fromMap(item, id);
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get current logged in user
  Future<app_user.User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserJson = prefs.getString(_currentUserKey);

      if (currentUserJson == null) return null;

      final userData = json.decode(currentUserJson);
      if (userData is! Map<String, dynamic>) return null;
      final id = userData['id'];
      if (id is! String) return null;
      return app_user.User.fromMap(userData, id);
    } catch (e) {
      return null;
    }
  }

  // Update user data (UPDATE)
  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String name,
    String? phone,
    String? address,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) {
        return {'success': false, 'message': 'No users found'};
      }

      final decoded = json.decode(usersJson);
      if (decoded is! List) {
        return {'success': false, 'message': 'Corrupted user data'};
      }
      final users = <Map<String, dynamic>>[];
      for (var item in decoded) {
        if (item is Map<String, dynamic>) {
          users.add(item);
        }
      }
      bool found = false;

      for (var i = 0; i < users.length; i++) {
        if (users[i]['id'] == userId) {
          users[i]['name'] = name;
          users[i]['phone'] = phone;
          users[i]['address'] = address;
          users[i]['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
          found = true;

          // Update current user if it's the same user
          final currentUserJson = prefs.getString(_currentUserKey);
          if (currentUserJson != null) {
            final currentUser = json.decode(currentUserJson);
            if (currentUser is Map<String, dynamic> &&
                currentUser['id'] == userId) {
              await prefs.setString(_currentUserKey, json.encode(users[i]));
            }
          }
          break;
        }
      }

      if (!found) {
        return {'success': false, 'message': 'User not found'};
      }

      await prefs.setString(_usersKey, json.encode(users));
      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Update failed: $e'};
    }
  }

  // Delete user account (DELETE)
  Future<Map<String, dynamic>> deleteAccount(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null) {
        return {'success': false, 'message': 'No users found'};
      }

      final decoded = json.decode(usersJson);
      if (decoded is! List) {
        return {'success': false, 'message': 'Corrupted user data'};
      }
      final users = <Map<String, dynamic>>[];
      for (var item in decoded) {
        if (item is Map<String, dynamic>) {
          users.add(item);
        }
      }
      users.removeWhere((user) => user['id'] == userId);

      await prefs.setString(_usersKey, json.encode(users));
      await prefs.remove(_currentUserKey);

      return {'success': true, 'message': 'Account deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Delete failed: $e'};
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentUserKey) != null;
  }

  // Find user data by email (for forgot password)
  Future<Map<String, dynamic>?> getUserDataByEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);

    if (usersJson == null || usersJson.isEmpty) return null;

    final decoded = json.decode(usersJson);
    if (decoded is! List) return null;

    for (var item in decoded) {
      if (item is Map<String, dynamic>) {
        if (item['email'] == email) {
          return item;
        }
      }
    }
    return null;
  }

  // Reset password for a user by email
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String newPassword,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getString(_usersKey);

      if (usersJson == null || usersJson.isEmpty) {
        return {'success': false, 'message': 'No users found'};
      }

      final decoded = json.decode(usersJson);
      if (decoded is! List) {
        return {'success': false, 'message': 'Corrupted user data'};
      }

      final users = <Map<String, dynamic>>[];
      for (var item in decoded) {
        if (item is Map<String, dynamic>) {
          users.add(item);
        }
      }

      bool found = false;
      for (var i = 0; i < users.length; i++) {
        if (users[i]['email'] == email) {
          users[i]['password'] = newPassword;
          found = true;
          break;
        }
      }

      if (!found) {
        return {'success': false, 'message': 'User not found'};
      }

      await prefs.setString(_usersKey, json.encode(users));
      return {'success': true, 'message': 'Password reset successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Reset failed: $e'};
    }
  }
}
