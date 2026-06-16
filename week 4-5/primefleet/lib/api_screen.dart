import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiScreen extends StatefulWidget {
  const ApiScreen({super.key});

  @override
  State<ApiScreen> createState() => _ApiScreenState();
}

class _ApiScreenState extends State<ApiScreen> {
  List<dynamic> _vehicleMakes = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchVehicleMakes();
  }

  Future<void> _fetchVehicleMakes() async {
    try {
      final response = await http.get(
        Uri.parse('https://vpic.nhtsa.dot.gov/api/vehicles/getallmakes?format=json'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // The API returns a "Results" array containing makes
        final makes = data['Results'] as List<dynamic>;
        setState(() {
          _vehicleMakes = makes;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load vehicle makes (${response.statusCode})');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Makes – Public API'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: _isLoading
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
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = '';
                  _fetchVehicleMakes();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: _vehicleMakes.length,
        itemBuilder: (context, index) {
          final make = _vehicleMakes[index];
          final makeName = make['Make_Name'] ?? 'Unknown';
          final makeId = make['Make_ID'] ?? 'N/A';
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF0D47A1).withOpacity(0.1),
                child: const Icon(Icons.directions_car, color: Color(0xFF0D47A1)),
              ),
              title: Text(
                makeName,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              subtitle: Text(
                'Make ID: $makeId',
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.black54),
            ),
          );
        },
      ),
    );
  }
}