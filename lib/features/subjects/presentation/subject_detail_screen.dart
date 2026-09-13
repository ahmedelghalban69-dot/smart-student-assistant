import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubjectDetailScreen extends StatefulWidget {
  final String subjectId;
  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen>
    with SingleTickerProviderStateMixin {
  final _db = Supabase.instance.client;
  late TabController _tabs;
  Map<String, dynamic>? _subject;
  List<Map<String, dynamic>> _lessons = [];
  List<Map<String, dynamic>> _files = [];
  List<Map<String, dynamic>> _summaries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _db.from('subjects').select().eq('id', widget.subjectId).single(),
        _db.from('lessons').select().eq('subject_id', widget.subjectId),
        _db.from('files').select().eq('subject_id', widget.subjectId),
        _db.from('summaries').select().eq('subject_id', widget.subjectId),
      ]);
      setState(() {
        _subject = results[0] as Map<String, dynamic>;
        _lessons = (results[1] as List).cast<Map<String, dynamic>>();
        _files = (results[2] as List).cast<Map<String, dynamic>>();
        _summaries = (results[3] as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final color = _subject!['color'] != null
        ? Color(int.parse('FF${_subject!['color'].substring(1)}', radix: 16))
        : Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(_subject!['name']),
        backgroundColor: color,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'الدروس (${_lessons.length})'),
            Tab(text: 'الملفات (${_files.length})'),
            Tab(text: 'الملخصات (${_summaries.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildList(_lessons, 'لا توجد دروس', _addLesson, (l) => l['title']),
          _buildList(_files, 'لا توجد ملفات', null, (f) => f['name']),
          _buildList(_summaries, 'لا توجد ملخصات', null, (s) => s['title'] ?? 'ملخص'),
        ],
      ),
      floatingActionButton: _tabs.index == 0
          ? FloatingActionButton(
              onPressed: _addLesson,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildList(List<Map<String, dynamic>> items, String empty,
      VoidCallback? onAdd, String Function(Map<String, dynamic>) title) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(empty),
            if (onAdd != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(onPressed: onAdd, child: const Text('إضافة')),
            ],
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(title: Text(title(items[i]))),
      ),
    );
  }

  Future<void> _addLesson() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إضافة درس'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'عنوان الدرس'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              await _db.from('lessons').insert({
                'subject_id': widget.subjectId,
                'title': ctrl.text.trim(),
              });
              if (_.mounted) Navigator.pop(_);
              _load();
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
