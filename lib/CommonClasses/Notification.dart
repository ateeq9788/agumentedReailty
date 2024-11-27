import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications {
  final String userId;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  Notifications({
    required this.userId,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'message': message,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }

  factory Notifications.fromMap(String id, Map<String, dynamic> data) {
    // Check if the timestamp is a Firestore Timestamp or a String
    var timestamp = data['timestamp'];
    DateTime dateTime;

    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is String) {
      dateTime = DateTime.parse(timestamp); // Handle it as a String (if applicable)
    } else {
      throw Exception("Invalid timestamp format");
    }

    return Notifications(
      userId: data['userId'] as String,
      message: data['message'] as String,
      timestamp: dateTime,
      isRead: data['isRead'] as bool? ?? false,
    );
  }
}
