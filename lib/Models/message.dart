import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus {
  pending,
  sent,
  delivered,
  read,
}

class Message {
  final String text;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;
  MessageStatus status;

  Message({
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    this.status = MessageStatus.pending,
  });

  // Factory constructor to convert from a Map to a Message object
  factory Message.fromJson(Map<String, dynamic> map) {
    return Message(
      text: map['text'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      status: MessageStatus.values[map['status'] as int],
    );
  }

  
static List<Message> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Message.fromJson(json)).toList();
  }

  // Method to convert the Message object to a Map
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'status': status.index,
    };
  }
}
