import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('👤 حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: const Icon(Icons.person, size: 36),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('طالب مجتهد',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(user?.email ?? '',
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _tile(context, Icons.bar_chart, '📊 تقدمي', () => context.push('/stats')),
          _tile(context, Icons.folder, '📂 مكتبتي', () => context.push('/library')),
          _tile(context, Icons.search, '🔍 البحث', () => context.push('/search')),
          _tile(context, Icons.timer, '⏱️ جلسة مذاكرة', () => context.push('/timer')),
          _tile(context, Icons.task, '📝 المهام', () => context.push('/tasks')),
          const SizedBox(height: 12),
          _tile(context, Icons.logout, 'تسجيل الخروج', () async {
            await Supabase.instance.client.auth.signOut();
            if (context.mounted) context.go('/login');
          }, color: Colors.red),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, VoidCallback onTap,
      {Color? color}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color)),
        trailing: const Icon(Icons.arrow_back_ios_new, size: 14),
        onTap: onTap,
      ),
    );
  }
}
