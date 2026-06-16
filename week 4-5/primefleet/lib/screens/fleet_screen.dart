import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database_helper.dart';

class FleetScreen extends StatefulWidget {
  const FleetScreen({super.key});

  @override
  State<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends State<FleetScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final DatabaseHelper _db = DatabaseHelper();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Metrics
  int _totalVehicles = 0;
  int _activeVehicles = 0;
  double _avgTyreHealth = 0.0;
  int _pendingMaintenance = 0;
  double _fuelEfficiency = 0.0;
  double _tyreEfficiency = 0.0;
  List<double> _fuelData = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _loadMetrics();
  }

  @override
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    try {
      final total = await _db.getTotalVehicles();
      final active = await _db.getActiveVehicles();
      final avgHealth = await _db.getAverageTyreHealth();
      final pending = await _db.getPendingMaintenanceCount();
      final efficiencies = await _db.getEfficiencies();
      final fuelTrend = await _db.getFuelTrend();

      setState(() {
        _totalVehicles = total;
        _activeVehicles = active;
        _avgTyreHealth = avgHealth;
        _pendingMaintenance = pending;
        _tyreEfficiency = efficiencies['tyre']!;
        _fuelEfficiency = efficiencies['fuel']!;
        _fuelData = fuelTrend;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  void _openChatbot() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) => const ChatBotSheet(),
    ).catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat not available')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final adminName = user?.displayName ?? user?.email?.split('@').first ?? 'Admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fleet Dashboard"),
        backgroundColor: const Color(0xFF0D47A1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMetrics,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMetrics,
                child: const Text('Retry'),
              ),
            ],
          ),
        )
            : FadeTransition(
          opacity: _animationController,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting + Admin Name
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getGreeting(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            adminName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D47A1).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF0D47A1),
                        size: 32,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        "Total Fleet",
                        "$_totalVehicles",
                        Icons.local_shipping,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        "Active",
                        "$_activeVehicles",
                        Icons.play_circle_filled,
                        Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        "Tyre Health",
                        "${_avgTyreHealth.toStringAsFixed(0)}%",
                        Icons.tire_repair,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        "Maintenance Due",
                        "$_pendingMaintenance",
                        Icons.build,
                        Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Efficiency Cards
                Text(
                  "Performance Metrics",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildEfficiencyCard(
                        "Fuel Efficiency",
                        _fuelEfficiency,
                        Icons.local_gas_station,
                        Colors.teal,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildEfficiencyCard(
                        "Tyre Efficiency",
                        _tyreEfficiency,
                        Icons.tire_repair,
                        const Color(0xFF0D47A1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Analytics Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Fuel Consumption Trend (last 7 weeks)",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(_fuelData.length, (index) {
                            final value = _fuelData[index];
                            final height = (value / 100) * 100;
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  width: 30,
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D47A1).withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${value.toStringAsFixed(0)}%",
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInsightTile(Icons.warning_amber,
                              "$_pendingMaintenance tyres need attention", Colors.orange),
                          _buildInsightTile(Icons.calendar_today,
                              "Upcoming services due", Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openChatbot,
        backgroundColor: Colors.white,
        icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF0D47A1)),
        label: const Text("AI Assistant", style: TextStyle(color: Color(0xFF0D47A1))),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Helper widgets (same as before, but ensure deep black text)
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyCard(String title, double percentage, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "${percentage.toStringAsFixed(0)}%",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey.shade200,
              color: color,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightTile(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }
}

// ---------------------------------------------------------------------
// AI Chatbot Bottom Sheet (unchanged, kept from previous version)
// ---------------------------------------------------------------------
class ChatBotSheet extends StatefulWidget {
  const ChatBotSheet({super.key});

  @override
  State<ChatBotSheet> createState() => _ChatBotSheetState();
}

class _ChatBotSheetState extends State<ChatBotSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {"role": "bot", "text": "Hello! I'm your fleet AI assistant. How can I help today?"},
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({"role": "user", "text": text});
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _messages.add({
            "role": "bot",
            "text": "Thanks for your message. Our team will get back to you soon. (Demo response)"
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0D47A1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              children: [
                const Icon(Icons.chat, color: Colors.white),
                const SizedBox(width: 12),
                const Text("AI Fleet Assistant", style: TextStyle(color: Colors.white, fontSize: 18)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF0D47A1) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Ask me anything...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF0D47A1),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}