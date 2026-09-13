import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/task_repository.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _repo = TaskRepository();
  late Future<List<Task>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.list();
  }

  void _refresh() => setState(() => _future = _repo.list());

  Future<void> _addTask() async {
    final titleCtrl = TextEditingController();
    DateTime? due;
    String priority = 'medium';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('مهمة جديدة', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(hintText: 'عنوان المهمة'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(hintText: 'الأولوية'),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                  DropdownMenuItem(value: 'medium', child: Text('متوسطة')),
                  DropdownMenuItem(value: 'high', child: Text('عالية')),
                ],
                onChanged: (v) => setSt(() => priority = v!),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(due == null
                    ? 'اختر موعد التسليم'
                    : DateFormat('yyyy/MM/dd').format(due!)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setSt(() => due = picked);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) return;
                  await _repo.create(Task(
                    id: '',
                    title: titleCtrl.text.trim(),
                    dueDate: due,
                    priority: priority,
                  ));
                  if (ctx.mounted) Navigator.pop(ctx);
                  _refresh();
                },
                child: const Text('إضافة'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📝 المهام')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Task>>(
        future: _future,
        builder: (_, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final tasks = snap.data!;
          if (tasks.isEmpty) {
            return const Center(child: Text('لا توجد مهام بعد'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tasks.length,
            itemBuilder: (_, i) {
              final t = tasks[i];
              final isDone = t.status == 'done';
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Checkbox(
                    value: isDone,
                    onChanged: (v) async {
                      await _repo.updateStatus(t.id, v! ? 'done' : 'pending');
                      _refresh();
                    },
                  ),
                  title: Text(
                    t.title,
                    style: TextStyle(
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: t.dueDate != null
                      ? Text('📅 ${DateFormat('yyyy/MM/dd').format(t.dueDate!)}')
                      : null,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await _repo.delete(t.id);
                      _refresh();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
