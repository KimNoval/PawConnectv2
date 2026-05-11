import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class MessageService {
  static const String _messagesKey = 'paw_connect_messages';
  static const String _readStateKey = 'paw_connect_read_state';

  String _conversationId(String userAId, String userBId, String petName) {
    final ids = [userAId, userBId]..sort();
    return '${ids[0]}_${ids[1]}_$petName';
  }

  Map<String, dynamic>? _asStringDynamicMap(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return null;
  }

  Future<List<Message>> getMessagesForConversation(
    String currentUserId,
    String otherUserId,
    String petName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final conversationId = _conversationId(currentUserId, otherUserId, petName);
    final allMessagesJson = prefs.getString(_messagesKey);
    if (allMessagesJson == null || allMessagesJson.isEmpty) return [];

    final decoded = json.decode(allMessagesJson);
    if (decoded is! List) return [];

    final messages = <Message>[];
    for (final item in decoded) {
      final map = _asStringDynamicMap(item);
      if (map != null && map['conversationId'] == conversationId) {
        messages.add(Message.fromMap(map));
      }
    }

    messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return messages;
  }

  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final allMessagesJson = prefs.getString(_messagesKey);
    final readStateJson = prefs.getString(_readStateKey);
    final readState = readStateJson == null || readStateJson.isEmpty
        ? <String, dynamic>{}
        : (_asStringDynamicMap(json.decode(readStateJson)) ?? <String, dynamic>{});
    if (allMessagesJson == null || allMessagesJson.isEmpty) return [];

    final decoded = json.decode(allMessagesJson);
    if (decoded is! List) return [];

    final conversations = <String, Map<String, dynamic>>{};
    for (final item in decoded) {
      final map = _asStringDynamicMap(item);
      if (map == null) continue;

      final senderId = map['senderId'] is String ? map['senderId'] as String : '';
      final receiverId = map['receiverId'] is String ? map['receiverId'] as String : '';
      if (senderId != userId && receiverId != userId) continue;
      final convId = map['conversationId'] is String ? map['conversationId'] as String : '';
      if (convId.isEmpty) continue;

      final otherUserId = senderId == userId ? receiverId : senderId;
      final otherUserName = senderId == userId
          ? (map['receiverName'] is String ? map['receiverName'] as String : 'Unknown')
          : (map['senderName'] is String ? map['senderName'] as String : 'Unknown');
      final petName = map['petName'] is String ? map['petName'] as String : '';

      if (!conversations.containsKey(convId)) {
        conversations[convId] = {
          'conversationId': convId,
          'otherUserId': otherUserId,
          'otherUserName': otherUserName,
          'petName': petName,
          'lastMessage': (map['content'] is String && (map['content'] as String).isNotEmpty)
              ? map['content']
              : ((map['imageBase64'] is String) ? 'Photo' : ''),
          'lastTimestamp': map['timestamp'] is int
              ? map['timestamp']
              : DateTime.now().millisecondsSinceEpoch,
          'unreadCount': 0,
        };
      } else {
        final ts = map['timestamp'];
        if (ts is int && ts > (conversations[convId]!['lastTimestamp'] as int)) {
          conversations[convId]!['lastMessage'] =
              (map['content'] is String && (map['content'] as String).isNotEmpty)
              ? map['content']
              : ((map['imageBase64'] is String) ? 'Photo' : '');
          conversations[convId]!['lastTimestamp'] = ts;
        }
      }

      final ts = map['timestamp'];
      final lastRead = readState[convId] is int ? readState[convId] as int : 0;
      if (ts is int && senderId != userId && ts > lastRead) {
        final current = conversations[convId]!['unreadCount'] as int;
        conversations[convId]!['unreadCount'] = current + 1;
      }
    }

    final result = conversations.values.toList();
    result.sort((a, b) => (b['lastTimestamp'] as int).compareTo(a['lastTimestamp'] as int));
    return result;
  }

  Future<void> sendMessage(
    String userId,
    String senderName,
    String receiverId,
    String receiverName,
    String petName,
    String content, {
    String? imageBase64,
  }) async {
    final trimmedContent = content.trim();
    final hasImage = imageBase64 != null && imageBase64.isNotEmpty;
    if (trimmedContent.isEmpty && !hasImage) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final conversationId = _conversationId(userId, receiverId, petName);

      final allMessages = <Map<String, dynamic>>[];
      final allMessagesJson = prefs.getString(_messagesKey);
      if (allMessagesJson != null && allMessagesJson.isNotEmpty) {
        final decoded = json.decode(allMessagesJson);
        if (decoded is List) {
          for (final item in decoded) {
            final map = _asStringDynamicMap(item);
            if (map != null) allMessages.add(map);
          }
        }
      }

      final message = Message(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        conversationId: conversationId,
        senderId: userId,
        senderName: senderName,
        receiverId: receiverId,
        receiverName: receiverName,
        petName: petName,
        content: trimmedContent,
        imageBase64: hasImage ? imageBase64 : null,
        timestamp: DateTime.now(),
      );

      allMessages.add(message.toMap());
      await prefs.setString(_messagesKey, json.encode(allMessages));
    } catch (_) {
      // Keep chat responsive even if stored JSON is malformed.
    }
  }

  Future<void> markConversationAsRead(
    String currentUserId,
    String otherUserId,
    String petName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final conversationId = _conversationId(currentUserId, otherUserId, petName);
    final readStateJson = prefs.getString(_readStateKey);
    final readState = readStateJson == null || readStateJson.isEmpty
        ? <String, dynamic>{}
        : (_asStringDynamicMap(json.decode(readStateJson)) ?? <String, dynamic>{});
    readState[conversationId] = DateTime.now().millisecondsSinceEpoch;
    await prefs.setString(_readStateKey, json.encode(readState));
  }
}
