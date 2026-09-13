import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/subject_repository.dart';
import '../../../shared/widgets/empty_state.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});
  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final _repo = SubjectRepository();
  late Future<List<Subject>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.list();
  }

  void _refresh() => setState(() => _future = _repo.list());

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController();
    String color = '#4F46E5';
    final colors = ['#4F46E5', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#06B6D4'];

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
              Text('إضافة مادة', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'اسم المادة'),
              ),
              const SizedBox(height: 16),
              const Text('اللون'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                children: colors.map((c) {
                  final selected = c == color;
                  return GestureDetector(
                    onTap: () => setSt(() => color = c),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Color(int.parse('FF${c.substring(1)}', radix: 16)),
                        shape: BoxShape.circle,
                        border: selected
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) return;
                  await _repo.create(name: nameCtrl.text.trim(), color: color);
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

  Future<void> _confirmDelete(Subject s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المادة؟'),
        content: Text('سيتم حذف "${s.name}" وكل ما يتعلق بها.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(_, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(_, true), child: const Text('حذف')),
        ],
      ),
    );
    if (ok == true) {
      await _repo.delete(s.id);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📚 المواد')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        icon: const Icon(Icons.add),
        label: const Text('مادة جديدة'),
      ),
      body: FutureBuilder<List<Subject>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final subjects = snap.data ?? [];
          if (subjects.isEmpty) {
            return EmptyState(
              icon: Icons.menu_book_outlined,
              title: 'لا توجد مواد بعد',
              subtitle: 'أضف أول مادة لتبدأ رحلتك',
              actionLabel: 'إضافة مادة',
              action: _showAddDialog,
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: subjects.length,
            itemBuilder: (_, i) {
              final s = subjects[i];
              final color = s.color != null
                  ? Color(int.parse('FF${s.color!.substring(1)}', radix: 16))
                  : Theme.of(context).colorScheme.primary;
              return InkWell(
                onTap: () => context.push('/subjects/${s.id}'),
                onLongPress: () => _confirmDelete(s),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.menu_book, color: color, size: 32),
                      const Spacer(),
                      Text(s.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: s.progress / 100,
                        backgroundColor: color.withOpacity(0.2),
                        color: color,
                        minHeight: 4,
                      ),
                      const SizedBox(height: 4),
                      Text('${s.progress}%',
                          style: TextStyle(fontSize: 12, color: color)),
                    ],
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
