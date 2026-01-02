import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:production/variables.dart';

/// API Service for Login Screen
/// Handles all API operations related to login functionality
class LoginApiService {
  /// Get base URL configuration
  Future<Map<String, dynamic>?> fetchBaseUrl() async {
    try {
      final response = await http.post(
        processRequest,
        headers: <String, String>{
          'VMETID':
              'byrZ4bZrKm09R4O7WH6SPd7tvAtGnK1/plycMSP8sD5TKI/VZR0tHBKyO/ogYUIf4Qk6HJXvgyGzg58v0xmlMoRJABt3qUUWGtnJj/EKBsrOaFFGZ6xAbf6k6/ktf2gKsruyfbF2/D7r1CFZgUlmTmubGS1oMZZTSU433swBQbwLnPSreMNi8lIcHJKR2WepQnzNkwPPXxA4/XuZ7CZqqsfO6tmjnH47GoHr7H+FC8GK24zU3AwGIpX+Yg/efeibwapkP6mAya+5BTUGtNtltGOm0q7+2EJAfNcrSTdmoDB8xBerLaNNHhwVHowNIu+8JZl2QM0F/gmVpB55cB8rqg=='
        },
        body: jsonEncode(<String, String>{"baseURL": mainbaseurl}),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody != null && responseBody['result'] != null) {
          baseurlresponsebody = responseBody;
          baseurlresult = responseBody['result'];
          return responseBody;
        } else {
          print('Invalid base URL response structure');
          return null;
        }
      } else {
        print('Failed to get base URL: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error in fetchBaseUrl(): $e');
      return null;
    }
  }

  /// Perform login request
  Future<LoginApiResponse> performLogin(
      String mobileNumber, String password) async {
    print("performLogin() called 📊📊📊📊📊📊📊📊📊📊📊📊📊📊📊📊");

    try {
      // Check if baseurlresult is available
      if (baseurlresult == null) {
        return LoginApiResponse(
          success: false,
          errorMessage: "Base URL not loaded. Please try again.",
        );
      }

      final response = await http.post(
        processRequest,
        headers: <String, String>{
          'DEVICETYPE': '2',
          'Content-Type': 'application/json; charset=UTF-8',
          'VPID': baseurlresult?['vpid']?.toString() ?? '',
          "BASEURL": mainbaseurl,
          'VPTEMPLATEID': baseurlresult?['vptemplteID']?.toString() ?? '',
          'VMETID':
              'jcd3r0UZg4FnqnFKCfAZqwj+d5Y7TJhxN6vIvKsoJIT++90iKP3dELmti79Q+W7aVywvVbhfoF5bdW32p33PbRRTT27Jt3pahRrFzUe5s0jQBoeE0jOraLITDQ6RBv0QoscoOGxL7n0gEWtLE15Bl/HSF2kG5pQYft+ZyF4DNsLf7tGXTz+w/30bv6vMTGmwUIDWqbEet/+5AAjgxEMT/G4kiZifX0eEb3gMxycdMchucGbMkhzK+4bvZKmIjX+z6uz7xqb1SMgPnjKmoqCk8w833K9le4LQ3KSYkcVhyX9B0Q3dDc16JDtpEPTz6b8rTwY8puqlzfuceh5mWogYuA==',
        },
        body: jsonEncode(<String, dynamic>{
          "mobileNumber": mobileNumber,
          "password": password,
        }),
      );

      print(
          "Login HTTP status: 📊📊📊📊📊📊📊📊📊📊📊📊📊📊📊 ${response.statusCode}");

      // Print response body in chunks to avoid truncation
      final responseBody = response.body;
      print("Login HTTP response length: ${responseBody.length}");
      const chunkSize = 800;
      for (int i = 0; i < responseBody.length; i += chunkSize) {
        final end = (i + chunkSize < responseBody.length)
            ? i + chunkSize
            : responseBody.length;
        final chunk = responseBody.substring(i, end);
        print("Login HTTP response chunk ${(i ~/ chunkSize) + 1}: $chunk");
      }

      if (response.statusCode == 200) {
        try {
          final responseBody = json.decode(response.body);
          print("📊 Decoded JSON response:");
          print("📊 Response keys: ${responseBody.keys.toList()}");

          if (responseBody['responseData'] != null) {
            print(
                "📊 ResponseData keys: ${responseBody['responseData'].keys.toList()}");
            print("📊 ResponseData content: ${responseBody['responseData']}");

            // Check if profileImage exists in responseData
            if (responseBody['responseData']['profileImage'] != null) {
              print(
                  "📸 ProfileImage found in responseData: ${responseBody['responseData']['profileImage']}");
            } else {
              print("⚠️ ProfileImage NOT found in responseData");
            }
          }

          if (responseBody['vsid'] != null) {
            print("📊 VSID: ${responseBody['vsid']}");
          }

          if (responseBody != null && responseBody['responseData'] != null) {
            // Update global variables
            loginresponsebody = responseBody;
            loginresult = responseBody['responseData'];

            // Update global variables from login response
            if (responseBody['responseData'] is Map) {
              final responseData = responseBody['responseData'];
              projectId = responseData['projectId'] ?? '';
              managerName = responseData['managerName'] ?? '';
              registeredMovie = responseData['projectName'] ?? '';
              vmid = responseData['vmid'] ?? 0;
              productionTypeId = responseData['productionTypeId'] ?? 0;
              productionHouse = responseData['productionHouse'] ?? '';

              print('📊 Updated global variables from login response');
            }

            // Extract ProfileImage
            String? loginProfileImage = _extractProfileImage(responseBody);

            // Get unitid for conditional logic
            final int? unitid = responseBody['responseData']?['unitid'];

            return LoginApiResponse(
              success: true,
              responseBody: responseBody,
              profileImage: loginProfileImage,
              unitid: unitid,
            );
          } else {
            return LoginApiResponse(
              success: false,
              errorMessage: "Invalid response from server",
            );
          }
        } catch (e) {
          print("Error parsing login response: $e");
          return LoginApiResponse(
            success: false,
            errorMessage: "Failed to process login response",
          );
        }
      } else {
        try {
          final errorBody = json.decode(response.body);
          loginresponsebody = errorBody;
          return LoginApiResponse(
            success: false,
            errorMessage: errorBody?['errordescription'] ?? "Login failed",
          );
        } catch (e) {
          print("Error parsing error response: $e");
          return LoginApiResponse(
            success: false,
            errorMessage: "Login failed",
          );
        }
      }
    } catch (e) {
      print("Error in performLogin(): $e");
      return LoginApiResponse(
        success: false,
        errorMessage: "Network error. Please try again.",
      );
    }
  }

  /// Fetch driver/incharge session data
  Future<DriverSessionResponse> fetchDriverSession() async {
    try {
      print('🚗 Fetching driver session data...');
      final response = await http.post(
        processSessionRequest,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'VMETID':
              'P8eqnuQ9H24nzw+j/Oq8qih3vw9biFxC4i2XpRLOiSOcHiiqKN5II1gsqhUCeEM5TXUq+Hl19zup0tT7YnANhHFUL5HX9awoCOuKdn+nbYUX4OV3p5oIdjfLmdXQqc4JwrnpQy3kVFX2qtPPooFy9kIRzSjEKcQd0Rhqg4CuDYUxiBVesHhZdpAiTvRvrd4VOreauP6FysEt72O7XhOWvZilN9hQv8mQ+5ALfBFOrTuRu+9P7FczirlqCdUMFhXa64XTupbb4acIq2+bTYBd0I5isowfPBRKFc+GJcJEFnhCknqpDq/r9yxowFOcJUgIMjc0Tc3/S4JiasDqIiouYQ==',
          'VSID': loginresponsebody?['vsid']?.toString() ?? "",
        },
        body: jsonEncode(<String, dynamic>{
          "vmId": loginresponsebody?['responseData']?['vmid'] ?? 0,
        }),
      );

      vsid = loginresponsebody?['vsid']?.toString() ?? "";
      print('🚗 Driver HTTP Response Status: ${response.statusCode}');
      print('🚗 Driver HTTP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final driverResponseBody = json.decode(response.body);
          print('🚗 Driver Response JSON: $driverResponseBody');
          print('🚗 Driver Response Keys: ${driverResponseBody.keys.toList()}');

          // Extract driver response data - Access nested responseData
          final responseData = driverResponseBody['responseData'];
          final projectName = responseData?['projectName']?.toString() ?? '';
          final projectId = responseData?['projectId']?.toString() ?? '';
          final productionHouse =
              responseData?['productionHouse']?.toString() ?? '';
          final productionTypeId = responseData?['productionTypeId'] ?? 0;

          print('🔍 Extracted values from responseData:');
          print('🔍 projectName: "$projectName"');
          print('🔍 projectId: "$projectId"');
          print('🔍 productionHouse: "$productionHouse"');
          print('🔍 productionTypeId: "$productionTypeId"');

          return DriverSessionResponse(
            success: true,
            responseBody: driverResponseBody,
            projectName: projectName,
            projectId: projectId,
            productionHouse: productionHouse,
            productionTypeId: productionTypeId,
          );
        } catch (e) {
          print('❌ Error processing driver response JSON: $e');
          print('🚗 Raw driver response body: ${response.body}');
          return DriverSessionResponse(
            success: false,
            errorMessage: "Failed to parse driver session response",
          );
        }
      } else {
        print('❌ Driver response status code: ${response.statusCode}');
        print('❌ Driver response body: ${response.body}');
        return DriverSessionResponse(
          success: false,
          errorMessage:
              "Driver session request failed with status ${response.statusCode}",
        );
      }
    } catch (e) {
      print('❌ Error in fetchDriverSession(): $e');
      return DriverSessionResponse(
        success: false,
        errorMessage: "Network error while fetching driver session",
      );
    }
  }

  /// Extract profile image from response
  String? _extractProfileImage(Map<String, dynamic> responseBody) {
    String? loginProfileImage;

    if (responseBody['responseData'] is Map &&
        responseBody['responseData']['profileImage'] != null) {
      loginProfileImage = responseBody['responseData']['profileImage'];
      print('📸 Found ProfileImage in responseData map: $loginProfileImage');
    } else if (responseBody['responseData'] is List &&
        (responseBody['responseData'] as List).isNotEmpty) {
      final firstItem = (responseBody['responseData'] as List)[0];
      if (firstItem is Map && firstItem['profileImage'] != null) {
        loginProfileImage = firstItem['profileImage'];
        print(
            '📸 Found ProfileImage in responseData list[0]: $loginProfileImage');
      }
    } else if (responseBody['profileImage'] != null) {
      loginProfileImage = responseBody['profileImage'];
      print('📸 Found ProfileImage in root response: $loginProfileImage');
    }

    if (loginProfileImage != null &&
        loginProfileImage.isNotEmpty &&
        loginProfileImage != 'Unknown') {
      print('📸 Valid ProfileImage extracted: $loginProfileImage');
      return loginProfileImage;
    } else {
      print('⚠️ No valid ProfileImage found in response');
      return null;
    }
  }
}

/// Login API Response Model
class LoginApiResponse {
  final bool success;
  final Map<String, dynamic>? responseBody;
  final String? errorMessage;
  final String? profileImage;
  final int? unitid;

  LoginApiResponse({
    required this.success,
    this.responseBody,
    this.errorMessage,
    this.profileImage,
    this.unitid,
  });
}

/// Driver Session Response Model
class DriverSessionResponse {
  final bool success;
  final Map<String, dynamic>? responseBody;
  final String? errorMessage;
  final String? projectName;
  final String? projectId;
  final String? productionHouse;
  final int? productionTypeId;

  DriverSessionResponse({
    required this.success,
    this.responseBody,
    this.errorMessage,
    this.projectName,
    this.projectId,
    this.productionHouse,
    this.productionTypeId,
  });
}
