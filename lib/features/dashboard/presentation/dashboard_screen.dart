import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('أهلاً بك 👋', style: theme.textTheme.bodyMedium),
                      Text('طالب مجتهد',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.person,
                      color: theme.colorScheme.onPrimaryContainer),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _AiHeroCard(onTap: () => context.go('/ai')),
            const SizedBox(height: 20),
            Text('اختصارات سريعة',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _QuickAction(icon: Icons.add_task, label: 'مهمة',
                    onTap: () => context.push('/tasks')),
                _QuickAction(icon: Icons.menu_book, label: 'مادة',
                    onTap: () => context.go('/subjects')),
                _QuickAction(icon: Icons.assignment, label: 'واجب',
                    onTap: () => context.push('/tasks')),
                _QuickAction(icon: Icons.timer, label: 'مؤقت',
                    onTap: () => context.push('/timer')),
                _QuickAction(icon: Icons.summarize, label: 'ملخص',
                    onTap: () => context.go('/ai')),
                _QuickAction(icon: Icons.quiz, label: 'أسئلة',
                    onTap: () => context.go('/ai')),
              ],
            ),
            const SizedBox(height: 24),
            Text('تقدم اليوم',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_fire_department,
                            color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('سلسلة 5 أيام 🔥'),
                        const Spacer(),
                        Text('70%',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 0.7,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiHeroCard extends StatelessWidget {
  final VoidCallback onTap;
  const _AiHeroCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withOpacity(0.7),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 36),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✨ مساعد الذكاء الاصطناعي',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('اسأل، لخّص، أنشئ اختبارات',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
