import 'dart:convert';

class TodoItem {
  final String id;
  final String title;
  final bool done;

  const TodoItem({
    required this.id,
    required this.title,
    this.done = false,
  });

  TodoItem copyWith({String? title, bool? done}) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      done: done ?? this.done,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'] as String,
        title: json['title'] as String,
        done: json['done'] as bool,
      );

  static List<TodoItem> listFromJson(String jsonStr) {
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => TodoItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<TodoItem> todos) {
    return jsonEncode(todos.map((e) => e.toJson()).toList());
  }
}
