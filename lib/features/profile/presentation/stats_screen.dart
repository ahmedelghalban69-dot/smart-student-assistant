import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📊 تقدمي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              _statCard(context, 'دقائق اليوم', '0', Icons.timer),
              const SizedBox(width: 12),
              _statCard(context, 'الجلسات', '0', Icons.play_circle),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _statCard(context, 'مهام مكتملة', '0', Icons.check_circle),
              const SizedBox(width: 12),
              _statCard(context, 'المستوى', '1', Icons.star),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
