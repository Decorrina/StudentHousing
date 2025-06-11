import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:graduation_project/file/apartment_model.dart';

class ApiService {
  // URLs for backend endpoints
  static const String apartmentsUrl = 'http://10.0.2.2:5175/api/Apartments/paginated-search';
  static const String registerUrl = 'http://10.0.2.2:5175/api/Accounts/Register';
  static const String loginUrl = 'http://10.0.2.2:5175/api/Accounts/Login';
  static const String addApartmentUrl = 'http://10.0.2.2:5175/api/Apartments';

  /// Fetch apartments with optional filters
  static Future<List<Apartment>> fetchApartments({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final Map<String, dynamic> body = {
        'pageIndex': 1,
        'pageSize': 20,
        'searchType': 2,
      };

      if (filters != null) {
        print('📦 Applied Filters: $filters');

        if (filters['university'] != null) {
          body['searchWithUniversityName'] = filters['university'];
        }
        if (filters['gender'] != null) {
          body['gender'] = filters['gender'];
        }
        if (filters['minFloor'] != null) {
          body['floor'] = filters['minFloor'];
        }
        if (filters['minPrice'] != null) {
          body['priceFrom'] = filters['minPrice'];
        }
        if (filters['maxPrice'] != null) {
          body['priceTo'] = filters['maxPrice'];
        }
      }

      print('📤 POST to: $apartmentsUrl');
      print('📄 Body: ${jsonEncode(body)}');

      final response = await http.post(
        Uri.parse(apartmentsUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
                                                    
      if (response.statusCode == 200) {
        final Map<String, dynamic> decoded = json.decode(response.body);
        final List<dynamic> data = decoded['data'] ?? [];

        final apartments = data.map((json) => Apartment.fromJson(json)).toList();

        final uniqueApartments = {
          for (var a in apartments) a.id: a
        }.values.toList();

        print('🏠 Loaded ${uniqueApartments.length} unique apartments');
        return uniqueApartments;
      } else {
        throw Exception('❌ Failed to load apartments: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('🌐 Network error: $e');
    }
  }

  /// Register user (Student/Owner)
  static Future<http.Response> registerUser(Map<String, dynamic> body) async {
    print('📤 Registering user to: $registerUrl');
    print('📦 Body: ${jsonEncode(body)}');

    final response = await http.post(
      Uri.parse(registerUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return response;
  }

  /// Login user
  static Future<http.Response> loginUser(String email, String password) async {
    final body = {
      'email': email,
      'password': password,
    };

    print('📤 Logging in to: $loginUrl');
    print('📦 Body: ${jsonEncode(body)}');

    final response = await http.post(
      Uri.parse(loginUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    return response;
  }

  /// Add a new apartment
  static Future<http.Response> addApartment(Map<String, dynamic> apartmentData) async {
    print('📤 Adding apartment to: $addApartmentUrl');
    print('📦 Payload: ${jsonEncode(apartmentData)}');

    final response = await http.post(
      Uri.parse(addApartmentUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(apartmentData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Apartment added successfully');
    } else {
      print('❌ Failed to add apartment: ${response.statusCode}');
      print(response.body);
    }

    return response;
  }
}
