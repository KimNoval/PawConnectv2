class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String petName;
  final String content;
  final String? imageBase64;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.petName,
    required this.content,
    this.imageBase64,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'petName': petName,
      'content': content,
      'imageBase64': imageBase64,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] is String ? map['id'] as String : '',
      conversationId: map['conversationId'] is String ? map['conversationId'] as String : '',
      senderId: map['senderId'] is String ? map['senderId'] as String : '',
      senderName: map['senderName'] is String ? map['senderName'] as String : '',
      receiverId: map['receiverId'] is String ? map['receiverId'] as String : '',
      receiverName: map['receiverName'] is String ? map['receiverName'] as String : '',
      petName: map['petName'] is String ? map['petName'] as String : '',
      content: map['content'] is String ? map['content'] as String : '',
      imageBase64: map['imageBase64'] is String ? map['imageBase64'] as String : null,
      timestamp: map['timestamp'] is int
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
    );
  }
}
