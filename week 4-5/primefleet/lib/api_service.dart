import 'dart:convert';
import 'package:http/http.dart' as http;

// --- Data Model for an API Company ---
class ApiCompany {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;

  ApiCompany({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
  });

  factory ApiCompany.fromJson(Map<String, dynamic> json) {
    return ApiCompany(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      website: json['website'],
    );
  }
}

// --- API Service Class ---
class ApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<ApiCompany>> fetchCompanies() async {
    final response = await http.get(Uri.parse('$_baseUrl/users'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      // Map the JSON list to a list of ApiCompany objects
      return body.map((dynamic item) => ApiCompany.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load companies from API. Status code: ${response.statusCode}');
    }
  }
}