class NoteEntity {
  final String id;
  final String title;
  final String body;
  final String type; // default, list, design, travel, meeting, quote
  final int stickingStyleId; // 1 to 5
  final bool isUnread;
  final DateTime dateCreated;
  final DateTime dateModified;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.stickingStyleId,
    required this.isUnread,
    required this.dateCreated,
    required this.dateModified,
  });

  NoteEntity copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    int? stickingStyleId,
    bool? isUnread,
    DateTime? dateCreated,
    DateTime? dateModified,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      stickingStyleId: stickingStyleId ?? this.stickingStyleId,
      isUnread: isUnread ?? this.isUnread,
      dateCreated: dateCreated ?? this.dateCreated,
      dateModified: dateModified ?? this.dateModified,
    );
  }

  factory NoteEntity.fromJson(Map<dynamic, dynamic> json) {
    return NoteEntity(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      stickingStyleId: json['stickingStyleId'] as int,
      isUnread: json['isUnread'] as bool,
      dateCreated: DateTime.parse(json['dateCreated'] as String),
      dateModified: DateTime.parse(json['dateModified'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'stickingStyleId': stickingStyleId,
      'isUnread': isUnread,
      'dateCreated': dateCreated.toIso8601String(),
      'dateModified': dateModified.toIso8601String(),
    };
  }
}
