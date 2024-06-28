class NotificationModel {
  final String id;
  final String title;
  final String content;
  final String dateTime;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.dateTime,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      dateTime: json['dateTime'],
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'dateTime': dateTime.toString(),
      'isRead': isRead,
    };
  }
}
