import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdoptionRequestService {
  static const String _requestsKey = 'paw_connect_adoption_requests';

  // Helper method to generate next unique ID based on existing requests
  Future<String> _getNextRequestId() async {
    final prefs = await SharedPreferences.getInstance();
    final requestsJson = prefs.getString(_requestsKey);

    int maxId = 0;
    if (requestsJson != null && requestsJson.isNotEmpty) {
      try {
        final decoded = json.decode(requestsJson);
        if (decoded is List) {
          for (var item in decoded) {
            if (item is Map<String, dynamic> && item['id'] is String) {
              final idStr = (item['id'] as String).replaceFirst('req_', '');
              final idNum = int.tryParse(idStr) ?? 0;
              if (idNum > maxId) maxId = idNum;
            }
          }
        }
      } catch (e) {
        // If there's an error parsing, just use 0
      }
    }

    return 'req_${maxId + 1}';
  }

  // Get all adoption requests
  Future<List<Map<String, dynamic>>> getAllRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final requestsJson = prefs.getString(_requestsKey);
    if (requestsJson == null) return [];
    return List<Map<String, dynamic>>.from(json.decode(requestsJson));
  }

  // Get requests for a specific pet owner (requests made TO this user)
  Future<List<Map<String, dynamic>>> getRequestsForOwner(String ownerId) async {
    final allRequests = await getAllRequests();
    return allRequests.where((req) => req['ownerId'] == ownerId).toList();
  }

  // Get requests made BY a specific user
  Future<List<Map<String, dynamic>>> getRequestsByUser(String userId) async {
    final allRequests = await getAllRequests();
    return allRequests.where((req) => req['requesterId'] == userId).toList();
  }

  // Submit adoption request (CREATE)
  Future<Map<String, dynamic>> submitRequest({
    required String requesterId,
    required String requesterName,
    required String requesterEmail,
    required String ownerId,
    required String petId,
    required String petName,
    required String name,
    required String age,
    required String email,
    required String contact,
    required String address,
    required String householdType,
    required String bringHome,
    required String reason,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = prefs.getString(_requestsKey);
      List<Map<String, dynamic>> requests = [];
      if (requestsJson != null) {
        requests = List<Map<String, dynamic>>.from(json.decode(requestsJson));
      }

      final nextId = await _getNextRequestId();
      final newRequest = {
        'id': nextId,
        'requesterId': requesterId,
        'requesterName': requesterName,
        'requesterEmail': requesterEmail,
        'ownerId': ownerId,
        'petId': petId,
        'petName': petName,
        'name': name,
        'age': age,
        'email': email,
        'contact': contact,
        'address': address,
        'householdType': householdType,
        'bringHome': bringHome,
        'reason': reason,
        'status': 'Pending',
        'createdAt': DateTime.now().toIso8601String(),
      };

      requests.add(newRequest);
      await prefs.setString(_requestsKey, json.encode(requests));

      return {
        'success': true,
        'message': 'Adoption request submitted',
        'request': newRequest,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to submit request: $e'};
    }
  }

  // Update request status (UPDATE)
  Future<Map<String, dynamic>> updateRequestStatus({
    required String requestId,
    required String status, // 'Pending', 'Approved', 'Rejected'
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = prefs.getString(_requestsKey);
      if (requestsJson == null) {
        return {'success': false, 'message': 'No requests found'};
      }

      final requests = List<Map<String, dynamic>>.from(
        json.decode(requestsJson),
      );
      bool found = false;

      for (var i = 0; i < requests.length; i++) {
        if (requests[i]['id'] == requestId) {
          requests[i]['status'] = status;
          requests[i]['updatedAt'] = DateTime.now().toIso8601String();
          found = true;
          break;
        }
      }

      if (!found) {
        return {'success': false, 'message': 'Request not found'};
      }

      await prefs.setString(_requestsKey, json.encode(requests));
      return {'success': true, 'message': 'Request status updated'};
    } catch (e) {
      return {'success': false, 'message': 'Update failed: $e'};
    }
  }

  // Delete request (DELETE)
  Future<Map<String, dynamic>> deleteRequest(String requestId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = prefs.getString(_requestsKey);
      if (requestsJson == null) {
        return {'success': false, 'message': 'No requests found'};
      }

      final requests = List<Map<String, dynamic>>.from(
        json.decode(requestsJson),
      );
      requests.removeWhere((req) => req['id'] == requestId);

      await prefs.setString(_requestsKey, json.encode(requests));
      return {'success': true, 'message': 'Request deleted'};
    } catch (e) {
      return {'success': false, 'message': 'Delete failed: $e'};
    }
  }
}
