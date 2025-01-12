import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project2/backend/django_auth.dart';
class ApiCalls {
  static final String baseUrl =
      dotenv.env['SERVER_URL']!; // Replace with your API URL
  static String? _accessToken;
  static String? _refreshToken;

  static Future<void> _loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
  }

  /// Static method to fetch places
  static Future<List<Map<String, dynamic>>> fetchPlaces({
    required List<String> keywords,
    required String travelMode,
    required double latitude,
    required double longitude,
  }) async {
    try {
      String currentLocation = '${latitude},${longitude}';

      // Construct the request payload
      final payload = {
        'location': currentLocation,
        'radius': 5000, // 5 km in meters
        'keywords': keywords,
        'travel_mode': travelMode, // Add default travel mode if required
      };

      // Make the API request
      final url = Uri.parse('$baseUrl/api/places/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response
        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        if (responseData.containsKey('itinerary')) {
          return List<Map<String, dynamic>>.from(responseData['itinerary']);
        } else {
          throw Exception('Invalid response format: "itinerary" key missing');
        }
      } else {
        // Handle error response
        final errorData = jsonDecode(response.body);
        throw Exception(
            'Failed to fetch places: ${errorData['error'] ?? 'Unknown error'}');
      }
    } catch (e) {
      // Handle other errors
      throw Exception('Error occurred: $e');
    }
  }

  /// Create a new schedule
  static Future<String> createSchedule(
      List<Map<String, dynamic>> schedule, String title) async {
    await _loadTokens();
    try {
      final url = Uri.parse('$baseUrl/api/schedule/create/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({'schedule': schedule, 'title': title}),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['schedule_id'];
      } else {
        throw Exception('Failed to create schedule: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  /// Mark the start of a visit
  static Future<void> startVisit(String venueName, String scheduleId) async {
    await _loadTokens();
    try {
      final url = Uri.parse('$baseUrl/api/schedule/check_in/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'venue_name': venueName,
          'schedule_id': scheduleId,
          'start_time': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to start visit: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  /// Mark the end of a visit
  static Future<void> endVisit(String venueName, String scheduleId) async {
    await _loadTokens();
    try {
      final url = Uri.parse('$baseUrl/api/schedule/check_out/');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'venue_name': venueName,
          'schedule_id': scheduleId,
          'end_time': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to end visit: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  static Future<Map<String, dynamic>?> getNextVenue() async {
    await _loadTokens();
    final url = Uri.parse('$baseUrl/api/schedule/get_next_venue/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData.containsKey('next_venue')) {
        return responseData;
      } else if (responseData.containsKey('message')) {
        print(responseData['message']);
      }
      return null;
    } else {
      print("Error fetching next venue: ${response.body}");
      return null;
    }
  }

  /// Get the active schedule
  static Future<Map<String, dynamic>> getActiveSchedule() async {
    try {
      final url = Uri.parse('$baseUrl/api/get_active_schedule/');
      final response = await http.get(
        url,
       headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch active schedule: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  /// Get schedule history
  static Future<List<Map<String, dynamic>>> getScheduleHistory() async {
    await _loadTokens();

    try {
      final url = Uri.parse('$baseUrl/api/schedule/history/');
      final response = await http.get(
        url,
        headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(
            jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch schedule history: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  static Future<Map<String, dynamic>> getVenueDetails(String givenVenueId) async {
    await _loadTokens();
    try {
      final url = Uri.parse('$baseUrl/api/places/details/$givenVenueId/');
      final response = await http.get(
        url, 
        headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final responseBody = jsonDecode(response.body);
        if(responseBody.containsKey('code') && responseBody['code'] == 'token_not_valid') {
          await DjangoBackend().refreshToken();
        }
        throw Exception('Failed to fetch venue details: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }

  /// Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final url = Uri.parse('$baseUrl/api/profile/get');
      final response = await http.get(
        url,
       headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to fetch active schedule: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error occurred: $e');
    }
  }
}
