import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/post_office.dart';
import 'connectivity_service.dart';

/// Service class to handle all API calls to India Post APIs
class ApiService {
  static const String _baseUrl = 'https://api.postalpincode.in';
  static const Duration _timeoutDuration = Duration(seconds: 15);

  /// Fetch post office details by PIN code
  /// Returns list of PostOffice objects or throws exception on error
  static Future<List<PostOffice>> fetchByPincode(String pincode) async {
    // Check connectivity before making API call
    final connectivityService = ConnectivityService();
    final isConnected = await connectivityService.checkConnectivity();

    if (!isConnected) {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    }

    try {
      final url = Uri.parse('$_baseUrl/pincode/$pincode');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Check if API returned valid data
        if (data.isNotEmpty && data[0]['Status'] == 'Success') {
          final List<dynamic> postOffices = data[0]['PostOffice'] ?? [];
          if (postOffices.isEmpty) {
            throw Exception('No post office found for PIN code: $pincode');
          }
          return postOffices.map((json) => PostOffice.fromJson(json)).toList();
        } else {
          throw Exception('No post office found for PIN code: $pincode');
        }
      } else if (response.statusCode == 404) {
        throw Exception('No post office found for PIN code: $pincode');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Failed to fetch data. Please try again.');
      }
    } on SocketException {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    } on http.ClientException {
      throw Exception(
          'Network error. Please check your connection and try again.');
    } on FormatException {
      throw Exception('Invalid response from server. Please try again.');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
            'Request timed out. Please check your connection and try again.');
      }
      throw Exception(
          'Network error: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  /// Fetch post office details by Post Office name
  /// Returns list of PostOffice objects or throws exception on error
  static Future<List<PostOffice>> fetchByPostOfficeName(String name) async {
    // Check connectivity before making API call
    final connectivityService = ConnectivityService();
    final isConnected = await connectivityService.checkConnectivity();

    if (!isConnected) {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    }

    try {
      final url = Uri.parse('$_baseUrl/postoffice/$name');
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(_timeoutDuration);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Check if API returned valid data
        if (data.isNotEmpty && data[0]['Status'] == 'Success') {
          final List<dynamic> postOffices = data[0]['PostOffice'] ?? [];
          if (postOffices.isEmpty) {
            throw Exception('No post office found with name: $name');
          }
          return postOffices.map((json) => PostOffice.fromJson(json)).toList();
        } else {
          throw Exception('No post office found with name: $name');
        }
      } else if (response.statusCode == 404) {
        throw Exception('No post office found with name: $name');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Failed to fetch data. Please try again.');
      }
    } on SocketException {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    } on http.ClientException {
      throw Exception(
          'Network error. Please check your connection and try again.');
    } on FormatException {
      throw Exception('Invalid response from server. Please try again.');
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
            'Request timed out. Please check your connection and try again.');
      }
      throw Exception(
          'Network error: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }
}
