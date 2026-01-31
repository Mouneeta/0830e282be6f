import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiTestScreen extends StatelessWidget {
  const ApiTestScreen({super.key});

  static const String baseUrl = "http://192.168.10.119:3000";

  Future<void> postStats() async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/vitals"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "thermal": 1,
        "battery": 80,
        "memory": 45,
      }),
    );

    debugPrint("POST response: ${response.body}");
  }

  Future<void> getStats() async {
    final response = await http.get(
      Uri.parse("$baseUrl/api/vitals"),
    );

    debugPrint("GET response: ${response.body}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("API Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: postStats,
              child: const Text("POST /vitals"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: getStats,
              child: const Text("GET /vitals"),
            ),
          ],
        ),
      ),
    );
  }
}
