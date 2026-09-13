import 'package:supabase_flutter/supabase_flutter.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority;
  final String status;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 'medium',
    this.status = 'pending',
  });

  factory Task.fromMap(Map<String, dynamic> m) => Task(
        id: m['id'],
        title: m['title'],
        description: m['description'],
        dueDate: m['due_date'] != null ? DateTime.parse(m['due_date']) : null,
        priority: m['priority'] ?? 'medium',
        status: m['status'] ?? 'pending',
      );
}

class TaskRepository {
  final _db = Supabase.instance.client;

  Future<List<Task>> list() async {
    final data = await _db.from('tasks').select().order('due_date');
    return (data as List).map((e) => Task.fromMap(e)).toList();
  }

  Future<void> create(Task t) async {
    await _db.from('tasks').insert({
      'user_id': _db.auth.currentUser!.id,
      'title': t.title,
      'description': t.description,
      'due_date': t.dueDate?.toIso8601String(),
      'priority': t.priority,
      'status': t.status,
    });
  }

  Future<void> updateStatus(String id, String status) async {
    await _db.from('tasks').update({'status': status}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _db.from('tasks').delete().eq('id', id);
  }
}
