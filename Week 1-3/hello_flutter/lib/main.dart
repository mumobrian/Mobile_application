import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My First Flutter App',

      home: Scaffold(
        backgroundColor: Colors.blueAccent,

        appBar: AppBar(
          title: Text('Flutter Assignment App'),
        ),

        body: Center(
          child: Text(
            'Hello Flutter!',
            style: TextStyle(
              fontSize: 32,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}