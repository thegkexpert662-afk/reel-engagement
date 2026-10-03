import 'package:flutter/material.dart';

void main() {
  runApp(const ReelEngagementApp());
}

class ReelEngagementApp extends StatelessWidget {
  const ReelEngagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reel Engagement Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
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

  void startSimulation() {
    final users = int.tryParse(usersController.text) ?? 10;

    setState(() {
      running = true;
      likes += users;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => running = false);
      }
    });
  }

  @override
  void dispose() {
    reelController.dispose();
    usersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reel Engagement Lab',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
                const SizedBox(height: 30),
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
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: _statCard('Likes', likes.toString(), Icons.favorite),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _statCard('Comments', comments.toString(), Icons.comment),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: running ? null : startSimulation,
                    icon: Icon(running ? Icons.hourglass_top : Icons.play_arrow),
                    label: Text(
                      running ? 'Simulation Running...' : 'Start Simulation',
                    ),
                  ),
                ),
                const SizedBox(height: 35),
                const Text(
                  'Activity Log',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _activity('BOT_USER_001', 'Like'),
                        _activity('BOT_USER_002', 'Like'),
                        _activity('BOT_USER_003', 'Comment'),
                        _activity('BOT_USER_004', 'Like'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.school),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Educational mode: यह simulator केवल dummy data पर चलता है।',
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
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Card(
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
  }

  Widget _activity(String user, String action) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(user),
      subtitle: Text('Dummy user → $action'),
      trailing: const Icon(Icons.check_circle),
    );
  }
}
