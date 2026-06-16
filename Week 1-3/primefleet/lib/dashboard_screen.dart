import 'package:flutter/material.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PrimeFleet Dashboard")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(10),
        children: const [

          Card(child: Center(child: Text("Tyres"))),
          Card(child: Center(child: Text("Fleet"))),
          Card(child: Center(child: Text("Maintenance"))),
          Card(child: Center(child: Text("Reports"))),

        ],
      ),
    );
  }
}
