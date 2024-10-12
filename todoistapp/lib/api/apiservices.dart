import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model.dart';

class ApiServices {
  String baseUrl = 'https://api.todoist.com/rest/v2';
  String apiToken = 'c78bb3f174befb71e706b6b4ff064bc3972b0085';

  Future<List<Api>> getTasks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Authorization': 'Bearer $apiToken'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Api.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<Api?> createTask(Api api) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(api.toJson()),
    );

    if (response.statusCode == 201) {
      return Api.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create task: ${response.body}');
    }
  }

  Future<Api?> updateTask(String id, Api api) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(api.toJson()),
    );

    if (response.statusCode == 200) {
      return Api.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update task: ${response.body}');
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {'Authorization': 'Bearer $apiToken'},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete task: ${response.body}');
    }
  }
}
