import 'package:supabase_flutter/supabase_flutter.dart';

class Subject {
  final String id;
  final String name;
  final String? color;
  final int progress;
  Subject({required this.id, required this.name, this.color, this.progress = 0});

  factory Subject.fromMap(Map<String, dynamic> m) => Subject(
        id: m['id'],
        name: m['name'],
        color: m['color'],
        progress: m['progress'] ?? 0,
      );
}

class SubjectRepository {
  final _db = Supabase.instance.client;

  Future<List<Subject>> list() async {
    final data = await _db
        .from('subjects')
        .select()
        .order('created_at', ascending: false);
    return (data as List).map((e) => Subject.fromMap(e)).toList();
  }

  Future<void> create({required String name, String? color}) async {
    await _db.from('subjects').insert({
      'name': name,
      'color': color,
      'user_id': _db.auth.currentUser!.id,
    });
  }

  Future<void> update(String id, Map<String, dynamic> patch) async {
    await _db.from('subjects').update(patch).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _db.from('subjects').delete().eq('id', id);
  }
}
