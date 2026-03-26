import 'dart:convert';

enum Urgency { urgent, lessUrgent }

enum Importance { important, lessImportant }

class TodoItem {
  final String id;
  String title;
  bool isDone;
  Urgency urgency;
  Importance importance;

  TodoItem({
    required this.id,
    required this.title,
    this.isDone = false,
    this.urgency = Urgency.lessUrgent,
    this.importance = Importance.lessImportant,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'isDone': isDone,
        'urgency': urgency.index,
        'importance': importance.index,
      };

  factory TodoItem.fromMap(Map<String, dynamic> map) => TodoItem(
        id: map['id'],
        title: map['title'],
        isDone: map['isDone'],
        urgency: Urgency.values[map['urgency']],
        importance: Importance.values[map['importance']],
      );

  String toJson() => jsonEncode(toMap());
  factory TodoItem.fromJson(String source) =>
      TodoItem.fromMap(jsonDecode(source));

  TodoItem copyWith({
    String? title,
    bool? isDone,
    Urgency? urgency,
    Importance? importance,
  }) =>
      TodoItem(
        id: id,
        title: title ?? this.title,
        isDone: isDone ?? this.isDone,
        urgency: urgency ?? this.urgency,
        importance: importance ?? this.importance,
      );
}