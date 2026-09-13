import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:async';

// ========================== MAIN ==========================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );
  runApp(const SmartStudentApp());
}

// ========================== APP ==========================
class SmartStudentApp extends StatelessWidget {
  const SmartStudentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مساعد الطالب الذكي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        scaffoldBackgroundColor: const Color(0xFFF8F9FC),
        textTheme: GoogleFonts.cairoTextTheme(),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          titleTextStyle: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
      ),
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const RootGate(),
    );
  }
}

// ========================== ROOT GATE ==========================
class RootGate extends StatelessWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return user == null ? const LoginScreen() : const MainShell();
  }
}

// ========================== LOGIN ==========================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  bool _signUp = false;

  Future<void> _submit() async {
    if (_email.text.isEmpty || _pass.text.isEmpty) return;
    setState(() => _loading = true);
    try {
      if (_signUp) {
        await Supabase.instance.client.auth
            .signUp(email: _email.text.trim(), password: _pass.text.trim());
      } else {
        await Supabase.instance.client.auth
            .signInWithPassword(email: _email.text.trim(), password: _pass.text.trim());
      }
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const MainShell()));
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('خطأ: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Icon(Icons.school_rounded, size: 80, color: Color(0xFF4F46E5)),
              const SizedBox(height: 20),
              const Text('مساعد الطالب الذكي',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('نظّم مذاكرتك بذكاء',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'البريد الإلكتروني',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                ),
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(_signUp ? 'إنشاء حساب' : 'تسجيل الدخول',
                        style: const TextStyle(fontSize: 16)),
              ),
              TextButton(
                onPressed: () => setState(() => _signUp = !_signUp),
                child: Text(_signUp
                    ? 'لديك حساب؟ سجّل الدخول'
                    : 'ليس لديك حساب؟ أنشئ حسابًا'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ========================== MAIN SHELL ==========================
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _screens = const [
    DashboardTab(),
    SubjectsTab(),
    TasksTab(),
    TimerTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book), label: 'المواد'),
          NavigationDestination(
              icon: Icon(Icons.task_outlined),
              selectedIcon: Icon(Icons.task), label: 'المهام'),
          NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer), label: 'مؤقت'),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

// ========================== DASHBOARD ==========================
class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('مساعد الطالب الذكي')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('أهلاً بك 👋', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          Text(email, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
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
                          style: TextStyle(color: Colors.white,
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('اسأل، لخّص، أنشئ اختبارات',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('اختصارات سريعة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: const [
              _QuickTile(icon: Icons.add_task, label: 'مهمة'),
              _QuickTile(icon: Icons.menu_book, label: 'مادة'),
              _QuickTile(icon: Icons.assignment, label: 'واجب'),
              _QuickTile(icon: Icons.timer, label: 'مؤقت'),
              _QuickTile(icon: Icons.summarize, label: 'ملخص'),
              _QuickTile(icon: Icons.quiz, label: 'أسئلة'),
            ],
          ),
          const SizedBox(height: 24),
          const Text('تقدم اليوم',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_fire_department, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('سلسلة 5 أيام 🔥',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                        value: 0.7, minHeight: 8),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF4F46E5)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ========================== SUBJECTS ==========================
class SubjectsTab extends StatefulWidget {
  const SubjectsTab({super.key});
  @override
  State<SubjectsTab> createState() => _SubjectsTabState();
}

class _SubjectsTabState extends State<SubjectsTab> {
  List<Map<String, dynamic>> _subjects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final uid = Supabase.instance.client.auth.currentUser!.id;
      final data = await Supabase.instance.client
          .from('subjects')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      setState(() {
        _subjects = (data as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('مادة جديدة'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'اسم المادة'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              try {
                await Supabase.instance.client.from('subjects').insert({
                  'user_id': Supabase.instance.client.auth.currentUser!.id,
                  'name': ctrl.text.trim(),
                });
                if (_.mounted) Navigator.pop(_);
                _load();
              } catch (e) {
                if (_.mounted) {
                  ScaffoldMessenger.of(_).showSnackBar(
                      SnackBar(content: Text('فشل: $e')));
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المادة؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_, false),
              child: const Text('إلغاء')),
          TextButton(
              onPressed: () => Navigator.pop(_, true),
              child: const Text('حذف')),
        ],
      ),
    );
    if (ok == true) {
      await Supabase.instance.client.from('subjects').delete().eq('id', id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📚 المواد')),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        backgroundColor: const Color(0xFF4F46E5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _subjects.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_outlined,
                          size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('لا توجد مواد بعد',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('اضغط + لإضافة أول مادة',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _subjects.length,
                  itemBuilder: (_, i) {
                    final s = _subjects[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF4F46E5),
                          child: Icon(Icons.menu_book, color: Colors.white),
                        ),
                        title: Text(s['name'] ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(s['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ========================== TASKS ==========================
class TasksTab extends StatefulWidget {
  const TasksTab({super.key});
  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  List<Map<String, dynamic>> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final uid = Supabase.instance.client.auth.currentUser!.id;
      final data = await Supabase.instance.client
          .from('tasks')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      setState(() {
        _tasks = (data as List).cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _add() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('مهمة جديدة'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'عنوان المهمة'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(_), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              try {
                await Supabase.instance.client.from('tasks').insert({
                  'user_id': Supabase.instance.client.auth.currentUser!.id,
                  'title': ctrl.text.trim(),
                  'status': 'pending',
                });
                if (_.mounted) Navigator.pop(_);
                _load();
              } catch (e) {
                if (_.mounted) {
                  ScaffoldMessenger.of(_).showSnackBar(
                      SnackBar(content: Text('فشل: $e')));
                }
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(Map<String, dynamic> t) async {
    final done = t['status'] == 'done';
    await Supabase.instance.client
        .from('tasks')
        .update({'status': done ? 'pending' : 'done'})
        .eq('id', t['id']);
    _load();
  }

  Future<void> _delete(String id) async {
    await Supabase.instance.client.from('tasks').delete().eq('id', id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📝 المهام')),
      floatingActionButton: FloatingActionButton(
        onPressed: _add,
        backgroundColor: const Color(0xFF4F46E5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('لا توجد مهام بعد',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('اضغط + لإضافة أول مهمة',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (_, i) {
                    final t = _tasks[i];
                    final done = t['status'] == 'done';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Checkbox(
                          value: done,
                          onChanged: (_) => _toggle(t),
                        ),
                        title: Text(
                          t['title'] ?? '',
                          style: TextStyle(
                            decoration: done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _delete(t['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// ========================== TIMER ==========================
class TimerTab extends StatefulWidget {
  const TimerTab({super.key});
  @override
  State<TimerTab> createState() => _TimerTabState();
}

class _TimerTabState extends State<TimerTab> {
  static const _focus = 25 * 60;
  static const _break = 5 * 60;
  int _remaining = _focus;
  bool _running = false;
  bool _isBreak = false;
  Timer? _timer;
  int _sessions = 0;

  void _toggle() {
    setState(() => _running = !_running);
    if (_running) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (_remaining <= 0) {
          _complete();
        } else {
          setState(() => _remaining--);
        }
      });
    } else {
      _timer?.cancel();
    }
  }

  Future<void> _complete() async {
    _timer?.cancel();
    setState(() => _running = false);
    if (!_isBreak) {
      _sessions++;
      try {
        await Supabase.instance.client.from('study_sessions').insert({
          'user_id': Supabase.instance.client.auth.currentUser!.id,
          'duration_minutes': 25,
          'ended_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isBreak ? '✅ انتهت الراحة!' : '🎉 أنهيت جلسة!')),
      );
    }
    setState(() {
      _isBreak = !_isBreak;
      _remaining = _isBreak ? _break : _focus;
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _running = false;
      _remaining = _isBreak ? _break : _focus;
    });
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = _isBreak ? _break : _focus;
    final progress = 1 - (_remaining / total);
    return Scaffold(
      appBar: AppBar(title: const Text('⏱️ جلسة مذاكرة')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Text(_isBreak ? '☕ وقت الراحة' : '📖 وقت التركيز',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            SizedBox(
              width: 240, height: 240,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    color: const Color(0xFF4F46E5),
                  ),
                  Center(
                    child: Text(_fmt(_remaining),
                        style: const TextStyle(
                            fontSize: 52, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Text('الجلسات المكتملة: $_sessions',
                style: const TextStyle(fontSize: 16)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                    onPressed: _reset,
                    iconSize: 32,
                    icon: const Icon(Icons.refresh)),
                const SizedBox(width: 20),
                IconButton.filled(
                  onPressed: _toggle,
                  iconSize: 48,
                  padding: const EdgeInsets.all(20),
                  style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5)),
                  icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                ),
                const SizedBox(width: 20),
                IconButton.filledTonal(
                    onPressed: _complete,
                    iconSize: 32,
                    icon: const Icon(Icons.skip_next)),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ========================== PROFILE ==========================
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
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
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFF4F46E5),
                    child: Icon(Icons.person, size: 36, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('طالب مجتهد',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(email, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('تسجيل الخروج',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                      context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text('مساعد الطالب الذكي v1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
