import 'package:flutter/material.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📅 خطتي')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_available,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('المخطط الذكي',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('سيتم توليد جدولك تلقائيًا هنا'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة تنظيم الخطة'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🚧 قريبًا: توليد الجدول')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
