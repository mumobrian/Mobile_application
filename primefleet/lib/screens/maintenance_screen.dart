import 'package:flutter/material.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maintenance"),
        backgroundColor: const Color(0xFF0D47A1),
      ),

      body: ListView(
        padding: const EdgeInsets.all(10),
        children: const [

          Card(
            child: ListTile(
              leading: Icon(Icons.build),
              title: Text("Truck A Service"),
              subtitle: Text("Due: 5 June 2026"),
              trailing: Icon(Icons.warning, color: Colors.orange),
            ),
          ),

          Card(
            child: ListTile(
              leading: Icon(Icons.build),
              title: Text("Truck B Tyre Replacement"),
              subtitle: Text("Overdue"),
              trailing: Icon(Icons.error, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}