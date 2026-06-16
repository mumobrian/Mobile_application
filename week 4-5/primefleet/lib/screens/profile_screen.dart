import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  // Connectivity
  bool _isConnected = true;
  String _connectionType = 'Unknown';
  late Connectivity _connectivity;

  // Ping / latency
  String _pingLatency = '-- ms';
  bool _isTestingSpeed = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _connectivity = Connectivity();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _initConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _isConnected = result != ConnectivityResult.none;
      switch (result) {
        case ConnectivityResult.wifi:
          _connectionType = 'Wi-Fi';
          break;
        case ConnectivityResult.mobile:
          _connectionType = 'Mobile Data';
          break;
        case ConnectivityResult.ethernet:
          _connectionType = 'Ethernet';
          break;
        case ConnectivityResult.none:
          _connectionType = 'No connection';
          break;
        default:
          _connectionType = 'Other';
      }
      if (_isConnected && _pingLatency == '-- ms') {
        _measureLatency();
      }
    });
  }

  Future<void> _measureLatency() async {
    if (!_isConnected) {
      setState(() {
        _pingLatency = 'No internet';
      });
      return;
    }
    setState(() {
      _isTestingSpeed = true;
      _pingLatency = '-- ms';
    });
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http
          .get(Uri.parse('https://dns.google/resolve?name=google.com'))
          .timeout(const Duration(seconds: 5));
      stopwatch.stop();
      if (response.statusCode == 200) {
        setState(() {
          _pingLatency = '${stopwatch.elapsedMilliseconds} ms';
        });
      } else {
        setState(() {
          _pingLatency = 'Error';
        });
      }
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _pingLatency = 'Timeout / No internet';
      });
    }
    setState(() {
      _isTestingSpeed = false;
    });
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout', style: TextStyle(color: Colors.black)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(color: Colors.black87)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.black54))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _auth.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: const Color(0xFF0D47A1),
        ),
        body: const Center(child: Text('User not logged in')),
      );
    }

    final displayName = _user!.displayName ?? 'Fleet Manager';
    final email = _user!.email ?? 'manager@primefleet.com';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFF0D47A1).withOpacity(0.1),
                      child: const Icon(Icons.person, size: 50, color: Color(0xFF0D47A1)),
                    ),
                    const SizedBox(height: 16),
                    Text(displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 4),
                    Text(email, style: const TextStyle(fontSize: 16, color: Colors.black54)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Network & Connectivity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(_isConnected ? Icons.wifi : Icons.wifi_off, color: _isConnected ? Colors.green : Colors.red),
                        const SizedBox(width: 12),
                        Text(_isConnected ? 'Connected' : 'Disconnected',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _isConnected ? Colors.green : Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.settings_ethernet, color: Colors.black54),
                        const SizedBox(width: 12),
                        Text('Connection type: $_connectionType', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.speed, color: Colors.black54),
                        const SizedBox(width: 12),
                        if (!_isConnected)
                          const Text('No internet connection', style: TextStyle(fontSize: 14, color: Colors.red))
                        else
                          Text('Ping latency: $_pingLatency', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                        const Spacer(),
                        if (_isTestingSpeed)
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        else if (_isConnected)
                          IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _measureLatency, tooltip: 'Measure ping again'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout', style: TextStyle(color: Colors.black87)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _logout,
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.black54),
                    title: const Text('Edit Profile', style: TextStyle(color: Colors.black87)),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit profile feature coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('PrimeFleet v1.0', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}