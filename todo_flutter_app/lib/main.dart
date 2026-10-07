import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/liquid_glass_card.dart';

// Update IP address for testing:
// - Android Emulator: http://10.0.2.2:5000
// - iOS Simulator / macOS: http://localhost:5000
// - Physical Device: http://<YOUR_MAC_IP_ADDRESS>:5000
const String baseUrl = 'http://localhost:5000/api';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Glass Todo',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B1329),
        colorScheme: const ColorScheme.dark(
          primary: Colors.greenAccent,
          secondary: Colors.cyanAccent,
          surface: Color(0xFF1E293B),
        ),
      ),
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;
  bool isLoading = false;

  Future<void> submitAuth() async {
    setState(() => isLoading = true);
    final endpoint = isLogin ? '/auth/login' : '/auth/register';

    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TodoHomeScreen()),
        );
      } else {
        _showError(data['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError('Server connection error');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Orbs for Liquid Glass Refraction
          Positioned(
            top: -60,
            left: -50,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.greenAccent.withValues(alpha: 0.7),
                    Colors.greenAccent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.deepPurpleAccent.withValues(alpha: 0.8),
                    Colors.deepPurple.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: LiquidGlassCard(
                glowColor: Colors.greenAccent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLogin ? 'Welcome Back' : 'Create Account',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Username',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.greenAccent, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Colors.greenAccent, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: isLoading ? null : submitAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent.shade400,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 6,
                        shadowColor: Colors.greenAccent.withValues(alpha: 0.5),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                            )
                          : Text(
                              isLogin ? 'Login' : 'Sign Up',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin),
                      child: Text(
                        isLogin ? "Don't have an account? Sign Up" : "Already have an account? Login",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- TODO HOME SCREEN WITH REMINDER FEATURE ---

class TodoHomeScreen extends StatefulWidget {
  const TodoHomeScreen({super.key});

  @override
  State<TodoHomeScreen> createState() => _TodoHomeScreenState();
}

class _TodoHomeScreenState extends State<TodoHomeScreen> {
  List todos = [];
  final _todoController = TextEditingController();
  DateTime? _newTodoReminder;
  Timer? _reminderPollTimer;
  final Set<int> _notifiedTodoIds = {};

  @override
  void initState() {
    super.initState();
    fetchTodos();
    _startReminderChecker();
  }

  @override
  void dispose() {
    _reminderPollTimer?.cancel();
    _todoController.dispose();
    super.dispose();
  }

  void _startReminderChecker() {
    // Check every 20 seconds for due reminders
    _reminderPollTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      _checkDueReminders();
    });
  }

  void _checkDueReminders() {
    final now = DateTime.now();
    for (final todo in todos) {
      final id = todo['id'];
      final isCompleted = todo['is_completed'] == true;
      final reminderStr = todo['reminder_at'];

      if (!isCompleted && reminderStr != null && !_notifiedTodoIds.contains(id)) {
        final reminderDt = DateTime.tryParse(reminderStr)?.toLocal();
        if (reminderDt != null && now.isAfter(reminderDt)) {
          _notifiedTodoIds.add(id);
          _showDueReminderNotification(todo['id'], todo['title']);
          break; // Show one at a time
        }
      }
    }
  }

  void _showDueReminderNotification(int id, String title) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: LiquidGlassCard(
          glowColor: Colors.amberAccent,
          borderRadius: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.alarm_on_rounded, color: Colors.amberAccent, size: 36),
              ),
              const SizedBox(height: 14),
              const Text(
                'Task Reminder!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Dismiss'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.greenAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        toggleTodo(id, false);
                      },
                      child: const Text('Complete', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchTodos() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/todos'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        setState(() => todos = jsonDecode(response.body));
        _checkDueReminders();
      }
    } catch (_) {}
  }

  Future<void> addTodo() async {
    if (_todoController.text.trim().isEmpty) return;
    final token = await _getToken();
    final bodyData = {
      'title': _todoController.text.trim(),
      if (_newTodoReminder != null) 'reminder_at': _newTodoReminder!.toUtc().toIso8601String(),
    };

    try {
      await http.post(
        Uri.parse('$baseUrl/todos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bodyData),
      );
      _todoController.clear();
      setState(() => _newTodoReminder = null);
      fetchTodos();
    } catch (_) {}
  }

  Future<void> toggleTodo(int id, bool currentStatus) async {
    final token = await _getToken();
    try {
      await http.put(
        Uri.parse('$baseUrl/todos/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'is_completed': !currentStatus}),
      );
      fetchTodos();
    } catch (_) {}
  }

  Future<void> updateTodoReminder(int id, DateTime? reminderDt) async {
    final token = await _getToken();
    try {
      await http.put(
        Uri.parse('$baseUrl/todos/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reminder_at': reminderDt?.toUtc().toIso8601String(),
        }),
      );
      if (reminderDt != null) {
        _notifiedTodoIds.remove(id); // reset notification state if updated
      }
      fetchTodos();
    } catch (_) {}
  }

  Future<void> deleteTodo(int id) async {
    final token = await _getToken();
    try {
      await http.delete(
        Uri.parse('$baseUrl/todos/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );
      fetchTodos();
    } catch (_) {}
  }

  Future<DateTime?> _pickDateTime({DateTime? initial}) async {
    final now = DateTime.now();
    final firstDate = now.subtract(const Duration(days: 1));
    final initialDate = initial != null && initial.isAfter(now) ? initial : now;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.greenAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return null;
    if (!mounted) return null;

    final initialTime = initial != null
        ? TimeOfDay(hour: initial.hour, minute: initial.minute)
        : TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)));

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.greenAccent,
              onPrimary: Colors.black,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return null;

    return DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
  }

  String _formatReminder(DateTime dt) {
    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final tomorrow = now.add(const Duration(days: 1));
    final isTomorrow = dt.year == tomorrow.year && dt.month == tomorrow.month && dt.day == tomorrow.day;

    final hour12 = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour12:$minuteStr $period';

    if (isToday) {
      return 'Today, $timeStr';
    } else if (isTomorrow) {
      return 'Tomorrow, $timeStr';
    } else {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]}, $timeStr';
    }
  }

  void _showReminderOptions(Map<String, dynamic> todo) {
    final int id = todo['id'];
    final String? reminderStr = todo['reminder_at'];
    final DateTime? currentReminder = reminderStr != null ? DateTime.tryParse(reminderStr)?.toLocal() : null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LiquidGlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.alarm_rounded, color: Colors.cyanAccent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    todo['title'] ?? 'Task Reminder',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (currentReminder != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Text(
                  'Current reminder: ${_formatReminder(currentReminder)}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                ),
              ),
            ListTile(
              leading: const Icon(Icons.edit_calendar_rounded, color: Colors.greenAccent),
              title: Text(
                currentReminder == null ? 'Set Reminder' : 'Change Reminder',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                final picked = await _pickDateTime(initial: currentReminder);
                if (picked != null) {
                  updateTodoReminder(id, picked);
                }
              },
            ),
            if (currentReminder != null)
              ListTile(
                leading: const Icon(Icons.alarm_off_rounded, color: Colors.redAccent),
                title: const Text('Remove Reminder', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(ctx);
                  updateTodoReminder(id, null);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liquid Glass Tasks', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
              );
            },
          )
        ],
      ),
      body: Stack(
        children: [
          // Background Liquid Gradient Orbs
          Positioned(
            top: 60,
            right: -40,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.blueAccent.withValues(alpha: 0.6),
                    Colors.blueAccent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purpleAccent.withValues(alpha: 0.5),
                    Colors.purpleAccent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Top Task Input with Reminder Selector
                LiquidGlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  glowColor: _newTodoReminder != null ? Colors.cyanAccent : null,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _todoController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Add a new task...',
                                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                                border: InputBorder.none,
                              ),
                              onSubmitted: (_) => addTodo(),
                            ),
                          ),
                          // Reminder Trigger Icon
                          IconButton(
                            icon: Icon(
                              _newTodoReminder != null ? Icons.alarm_on_rounded : Icons.alarm_add_rounded,
                              color: _newTodoReminder != null ? Colors.cyanAccent : Colors.white70,
                              size: 26,
                            ),
                            tooltip: _newTodoReminder != null ? 'Edit reminder' : 'Set reminder',
                            onPressed: () async {
                              final picked = await _pickDateTime(initial: _newTodoReminder);
                              if (picked != null) {
                                setState(() => _newTodoReminder = picked);
                              }
                            },
                          ),
                          // Add Task Button
                          IconButton(
                            icon: const Icon(Icons.add_circle, color: Colors.greenAccent, size: 34),
                            onPressed: addTodo,
                          ),
                        ],
                      ),
                      // Selected Reminder Pill
                      if (_newTodoReminder != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0, bottom: 4.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.cyanAccent.withValues(alpha: 0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.alarm, size: 14, color: Colors.cyanAccent),
                                  const SizedBox(width: 6),
                                  Text(
                                    _formatReminder(_newTodoReminder!),
                                    style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => setState(() => _newTodoReminder = null),
                                    child: const Icon(Icons.close, size: 14, color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Task List
                Expanded(
                  child: todos.isEmpty
                      ? Center(
                          child: Text(
                            'No tasks yet. Create one above!',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          itemCount: todos.length,
                          itemBuilder: (context, index) {
                            final todo = todos[index];
                            final isCompleted = todo['is_completed'] == true;
                            final reminderStr = todo['reminder_at'];
                            final reminderDt = reminderStr != null ? DateTime.tryParse(reminderStr)?.toLocal() : null;

                            final isOverdue = reminderDt != null && !isCompleted && DateTime.now().isAfter(reminderDt);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: LiquidGlassCard(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                glowColor: isOverdue ? Colors.amberAccent : null,
                                child: ListTile(
                                  leading: Checkbox(
                                    value: isCompleted,
                                    activeColor: Colors.greenAccent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    onChanged: (_) => toggleTodo(todo['id'], isCompleted),
                                  ),
                                  title: Text(
                                    todo['title'] ?? '',
                                    style: TextStyle(
                                      color: isCompleted ? Colors.white54 : Colors.white,
                                      fontWeight: FontWeight.w500,
                                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  subtitle: reminderDt != null
                                      ? Padding(
                                          padding: const EdgeInsets.only(top: 6.0),
                                          child: GestureDetector(
                                            onTap: () => _showReminderOptions(todo),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: isCompleted
                                                    ? Colors.white.withValues(alpha: 0.05)
                                                    : isOverdue
                                                        ? Colors.amberAccent.withValues(alpha: 0.16)
                                                        : Colors.cyanAccent.withValues(alpha: 0.14),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(
                                                  color: isCompleted
                                                      ? Colors.white24
                                                      : isOverdue
                                                          ? Colors.amberAccent.withValues(alpha: 0.5)
                                                          : Colors.cyanAccent.withValues(alpha: 0.4),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    isOverdue ? Icons.warning_amber_rounded : Icons.alarm_rounded,
                                                    size: 13,
                                                    color: isCompleted
                                                        ? Colors.white38
                                                        : isOverdue
                                                            ? Colors.amberAccent
                                                            : Colors.cyanAccent,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    _formatReminder(reminderDt),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: isCompleted
                                                          ? Colors.white38
                                                          : isOverdue
                                                              ? Colors.amberAccent
                                                              : Colors.cyanAccent,
                                                    ),
                                                  ),
                                                  if (isOverdue) ...[
                                                    const SizedBox(width: 4),
                                                    const Text(
                                                      '• Overdue',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.amberAccent,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // If no reminder is set yet, show button to add one directly
                                      if (reminderDt == null)
                                        IconButton(
                                          icon: Icon(
                                            Icons.alarm_add_outlined,
                                            color: Colors.white.withValues(alpha: 0.5),
                                            size: 22,
                                          ),
                                          tooltip: 'Set Reminder',
                                          onPressed: () => _showReminderOptions(todo),
                                        ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                                        tooltip: 'Delete Task',
                                        onPressed: () => deleteTodo(todo['id']),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}