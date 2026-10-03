import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const ReelEngagementApp());

class ReelEngagementApp extends StatelessWidget {
  const ReelEngagementApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Reel Engagement Lab',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const DashboardScreen(),
  );
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final reelController = TextEditingController(text: 'REEL001');
  final usersController = TextEditingController(text: '10');
  int likes = 0;
  int comments = 0;
  bool running = false;
  bool commentRunning = false;
  String status = 'Backend not checked yet';
  List<Map<String, dynamic>> activity = [];

  String get apiBaseUrl =>
      kIsWeb ? 'http://localhost:4002' : 'http://10.0.2.2:4002';

  Future<void> loadReel() async {
    setState(() => status = 'Connecting to backend...');
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/reels/${reelController.text.trim()}'),
      );
      if (response.statusCode != 200) throw Exception('Reel not found');

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final rawActivity = (data['activity'] as List<dynamic>? ?? []);

      setState(() {
        likes = data['likes'] ?? 0;
        comments = data['comments'] ?? 0;
        activity = rawActivity
            .whereType<Map<String, dynamic>>()
            .toList();
        status = 'Backend connected';
      });
    } catch (e) {
      setState(() => status = 'Connection failed: $e');
    }
  }

  Future<void> startSimulation() async {
    final users = int.tryParse(usersController.text) ?? 10;
    setState(() {
      running = true;
      status = 'Running dummy like simulation...';
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/simulator/run'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reelId': reelController.text.trim(),
          'users': users,
        }),
      );

      if (response.statusCode != 200) throw Exception('Simulation failed');

      await loadReel();
      if (mounted) setState(() => status = 'Like simulation completed');
    } catch (e) {
      setState(() => status = 'Simulation failed: $e');
    } finally {
      if (mounted) setState(() => running = false);
    }
  }

  Future<void> startCommentSimulation() async {
    final users = int.tryParse(usersController.text) ?? 5;
    setState(() {
      commentRunning = true;
      status = 'Running dummy comment simulation...';
    });

    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/simulator/comments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'reelId': reelController.text.trim(),
          'users': users,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Comment simulation failed');
      }

      await loadReel();
      if (mounted) setState(() => status = 'Comment simulation completed');
    } catch (e) {
      setState(() => status = 'Comment simulation failed: $e');
    } finally {
      if (mounted) setState(() => commentRunning = false);
    }
  }

  @override
  void dispose() {
    reelController.dispose();
    usersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Reel Engagement Lab',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          onPressed: running || commentRunning ? null : loadReel,
          icon: const Icon(Icons.sync),
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Educational Reel Simulator',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Dummy Reel और Dummy Users के साथ API automation सीखें.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 18),
              Card(
                child: ListTile(
                  leading: Icon(
                    status.contains('connected') ||
                            status.contains('completed')
                        ? Icons.cloud_done
                        : Icons.cloud,
                  ),
                  title: const Text('Backend Status'),
                  subtitle: Text('$status\n$apiBaseUrl'),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: reelController,
                      decoration: const InputDecoration(
                        labelText: 'Reel ID',
                        hintText: 'REEL001',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: usersController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Dummy Users',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      'Likes',
                      likes.toString(),
                      Icons.favorite,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _statCard(
                      'Comments',
                      comments.toString(),
                      Icons.comment,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          running || commentRunning ? null : loadReel,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Load Reel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          running || commentRunning ? null : startSimulation,
                      icon: Icon(
                        running ? Icons.hourglass_top : Icons.favorite,
                      ),
                      label: Text(
                        running ? 'Running...' : 'Simulate Likes',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      running || commentRunning
                          ? null
                          : startCommentSimulation,
                  icon: Icon(
                    commentRunning
                        ? Icons.hourglass_top
                        : Icons.comment,
                  ),
                  label: Text(
                    commentRunning
                        ? 'Running Comments...'
                        : 'Simulate Comments',
                  ),
                ),
              ),
              const SizedBox(height: 35),
              const Text(
                'Activity Log',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _activityCard(),
              const SizedBox(height: 24),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.school),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Educational mode: यह simulator केवल dummy data पर चलता है.',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _statCard(String title, String value, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Icon(icon, size: 38),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _activityCard() {
    if (activity.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text('No activity yet. Start a dummy simulation.'),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: activity.map((item) {
          final user = item['userId']?.toString() ?? 'DUMMY_USER';
          final type = item['type']?.toString() ?? 'activity';
          final text = item['text']?.toString();
          final at = item['at']?.toString() ?? '';

          final action = type == 'comment'
              ? 'Comment${text == null ? '' : ': $text'}'
              : 'Like';

          return ListTile(
            leading: CircleAvatar(
              child: Icon(
                type == 'comment' ? Icons.comment : Icons.favorite,
              ),
            ),
            title: Text(user),
            subtitle: Text('$action\n$at'),
            isThreeLine: true,
            trailing: const Icon(Icons.check_circle),
          );
        }).toList(),
      ),
    );
  }
}
