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
  String status = 'Backend not checked yet';

  String get apiBaseUrl => kIsWeb ? 'http://localhost:4002' : 'http://10.0.2.2:4002';

  Future<void> loadReel() async {
    setState(() => status = 'Connecting to backend...');
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/reels/${reelController.text.trim()}'),
      );
      if (response.statusCode != 200) throw Exception('Reel not found');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        likes = data['likes'] ?? 0;
        comments = data['comments'] ?? 0;
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
      status = 'Running dummy simulation...';
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
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        likes = data['likes'] ?? likes;
        comments = data['comments'] ?? comments;
        status = 'Simulation completed';
      });
    } catch (e) {
      setState(() => status = 'Simulation failed: $e');
    } finally {
      if (mounted) setState(() => running = false);
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
      title: const Text('Reel Engagement Lab', style: TextStyle(fontWeight: FontWeight.bold)),
      actions: [IconButton(onPressed: loadReel, icon: const Icon(Icons.sync))],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Educational Reel Simulator',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Dummy Reel और Dummy Users के साथ API automation सीखें.',
                style: TextStyle(fontSize: 16)),
              const SizedBox(height: 18),
              Card(child: ListTile(
                leading: Icon(status.contains('connected') || status.contains('completed')
                    ? Icons.cloud_done : Icons.cloud),
                title: const Text('Backend Status'),
                subtitle: Text('$status\n$apiBaseUrl'),
              )),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: TextField(
                  controller: reelController,
                  decoration: const InputDecoration(
                    labelText: 'Reel ID', hintText: 'REEL001',
                    border: OutlineInputBorder()),
                )),
                const SizedBox(width: 16),
                Expanded(child: TextField(
                  controller: usersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Dummy Users', border: OutlineInputBorder()),
                )),
              ]),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: _statCard('Likes', likes.toString(), Icons.favorite)),
                const SizedBox(width: 16),
                Expanded(child: _statCard('Comments', comments.toString(), Icons.comment)),
              ]),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton.icon(
                  onPressed: running ? null : loadReel,
                  icon: const Icon(Icons.refresh), label: const Text('Load Reel'))),
                const SizedBox(width: 16),
                Expanded(child: ElevatedButton.icon(
                  onPressed: running ? null : startSimulation,
                  icon: Icon(running ? Icons.hourglass_top : Icons.play_arrow),
                  label: Text(running ? 'Running...' : 'Start Simulation'))),
              ]),
              const SizedBox(height: 35),
              const Text('Activity Log',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(child: Column(children: [
                _activity('BOT_USER_001', 'Like'),
                _activity('BOT_USER_002', 'Like'),
                _activity('BOT_USER_003', 'Comment'),
                _activity('BOT_USER_004', 'Like'),
              ])),
              const SizedBox(height: 24),
              const Card(child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(children: [
                  Icon(Icons.school), SizedBox(width: 12),
                  Expanded(child: Text(
                    'Educational mode: यह simulator केवल dummy data पर चलता है.')),
                ]),
              )),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _statCard(String title, String value, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(22),
      child: Row(children: [
        Icon(icon, size: 38), const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title), const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ]),
      ]),
    ),
  );

  Widget _activity(String user, String action) => ListTile(
    leading: const CircleAvatar(child: Icon(Icons.person)),
    title: Text(user),
    subtitle: Text('Dummy user → $action'),
    trailing: const Icon(Icons.check_circle),
  );
}
