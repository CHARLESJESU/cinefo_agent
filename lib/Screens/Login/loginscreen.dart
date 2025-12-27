import 'dart:convert';
import 'dart:async';
// import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nfc_manager/nfc_manager.dart';
import 'package:production/Screens/Route/RouteScreenforAgent.dart';
import 'package:production/variables.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Import modular service files
import 'package:production/Screens/Login/login_sqlite_service.dart';
import 'package:production/Screens/Login/login_api_service.dart';
import 'package:production/Screens/Login/login_dialog_helper.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  // Service instances
  final LoginSQLiteService _sqliteService = LoginSQLiteService();
  final LoginApiService _apiService = LoginApiService();

  bool _isLoading = false;
  bool _obscureText = true;
  String? managerName;
  String? ProfileImage;
  int? vmid;

  // Wrapper methods to maintain compatibility with existing code
  void showmessage(BuildContext context, String message, String ok) {
    LoginDialogHelper.showMessage(context, message, ok);
  }

  Future<void> baseurl() async {
    final result = await _apiService.fetchBaseUrl();
    if (result != null) {
      setState(() {
        // Global variables are already set in the API service
      });
    }
  }

  // SQLite wrapper methods - delegate to service
  Future<void> saveLoginData() async {
    await _sqliteService.saveLoginData(
      loginmobilenumber.text,
      loginpassword.text,
      ProfileImage,
    );
  }

  Future<void> updateDriverLoginData(String projectName, String projectId,
      String productionHouse, int productionTypeId) async {
    await _sqliteService.updateDriverLoginData(
      projectName,
      projectId,
      productionHouse,
      productionTypeId,
    );
  }

  Future<void> updateDriverField(bool isDriver) async {
    await _sqliteService.updateDriverField(isDriver);
  }

  Future<void> testSQLite() async {
    await _sqliteService.testSQLite();
  }

  Future<bool> isNfcSupported() async {
    return await NfcManager.instance.isAvailable();
  }

  Future<void> loginr() async {
    print("loginr() called📊📊📊📊📊📊📊📊📊📊📊📊📊📊📊📊");
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if baseurlresult is available
      if (baseurlresult == null) {
        setState(() {
          _isLoading = false;
        });
        showmessage(context, "Base URL not loaded. Please try again.", "ok");
        return;
      }
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final response = await http.post(
        processRequest,
        headers: <String, String>{
          'DEVICETYPE': '2',
          'Content-Type': 'application/json; charset=UTF-8',
          'VPID': baseurlresult?['vpid']?.toString() ?? '',
          // "BASEURL": driverbaseurlfordev,  // production for driver
          // "BASEURL": agentbaseurlforproduction,
          // "BASEURL": settingbaseurlforproduction,
          // "BASEURL": settingbaseurlfordev,
          // "BASEURL": dancebaseurlfordev,
          // "BASEURL": dancebaseurlforproduction,
          "BASEURL": agentbaseurlfordev,
          // "BASEURL": driverbaseurlforproduction,
          'VPTEMPLATEID': baseurlresult?['vptemplteID']?.toString() ?? '',
          'VMETID':
              'jcd3r0UZg4FnqnFKCfAZqwj+d5Y7TJhxN6vIvKsoJIT++90iKP3dELmti79Q+W7aVywvVbhfoF5bdW32p33PbRRTT27Jt3pahRrFzUe5s0jQBoeE0jOraLITDQ6RBv0QoscoOGxL7n0gEWtLE15Bl/HSF2kG5pQYft+ZyF4DNsLf7tGXTz+w/30bv6vMTGmwUIDWqbEet/+5AAjgxEMT/G4kiZifX0eEb3gMxycdMchucGbMkhzK+4bvZKmIjX+z6uz7xqb1SMgPnjKmoqCk8w833K9le4LQ3KSYkcVhyX9B0Q3dDc16JDtpEPTz6b8rTwY8puqlzfuceh5mWogYuA==',
        },
        body: jsonEncode(<String, dynamic>{
          "mobileNumber": loginmobilenumber.text,
          "password": loginpassword.text,
        }),
      );

      print(
          "Login HTTP status:📊📊📊📊📊📊📊📊📊📊📊📊📊📊📊hvjhjvkjhgvhjgjmnvbkjgjbvn📊 ${response.statusCode}");

      // Print response body in chunks to avoid truncation
      final responseBody = response.body;
      print("Login HTTP response length: ${responseBody.length}");
      const chunkSize = 800; // Safe chunk size for Flutter console
      for (int i = 0; i < responseBody.length; i += chunkSize) {
        final end = (i + chunkSize < responseBody.length)
            ? i + chunkSize
            : responseBody.length;
        final chunk = responseBody.substring(i, end);
        print("Login HTTP response chunk ${(i ~/ chunkSize) + 1}: $chunk");
      }
      setState(() {
        _isLoading = false;
      });

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
            setState(() {
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
                ProfileImage = responseData['profileImage'] ?? '';

                print('📊 Updated global variables from login response');
              }

              // Update ProfileImage from login response if available
              // Check multiple possible locations for profileImage
              String? loginProfileImage;

              if (responseBody['responseData'] is Map &&
                  responseBody['responseData']['profileImage'] != null) {
                loginProfileImage =
                    responseBody['responseData']['profileImage'];
                print(
                    '📸 Found ProfileImage in responseData map: $loginProfileImage');
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
                print(
                    '📸 Found ProfileImage in root response: $loginProfileImage');
              }

              if (loginProfileImage != null &&
                  loginProfileImage.isNotEmpty &&
                  loginProfileImage != 'Unknown') {
                ProfileImage = loginProfileImage;
                print(
                    '📸 Updated ProfileImage from login response: $ProfileImage');
              } else {
                print(
                    '⚠️ No valid ProfileImage found in login response, keeping existing: $ProfileImage');
              }
            });

            // Update ProfileImage from login response before saving
            String? loginProfileImage;

            if (responseBody['responseData'] is Map &&
                responseBody['responseData']['profileImage'] != null) {
              loginProfileImage = responseBody['responseData']['profileImage'];
              print(
                  '📸 Found ProfileImage in responseData map: $loginProfileImage');
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
              print(
                  '📸 Found ProfileImage in root response: $loginProfileImage');
            }

            if (loginProfileImage != null &&
                loginProfileImage.isNotEmpty &&
                loginProfileImage != 'Unknown') {
              ProfileImage = loginProfileImage;
              print('📸 Updated ProfileImage before saving: $ProfileImage');
            }

            // Save login data to SQLite after successful login
            // Saving login data is now conditional based on user's unitid.
            // It will only be saved for unitid == 9 (driver) or unitid == 18 (agent).
            print(
                '🔄 Skipping unconditional saveLoginData(); save will occur only for unitid 9 or 18');

            // Check if user is an agent
            if (mounted) {
              final int? _unitid = loginresponsebody?['unitid'];

              // This login screen is for agents only (unitid: 18, 10, 5)
              final bool isAgent = _unitid == 18;

              if (isAgent) {
                // Save login data for agents only
                try {
                  print(
                      '🔄 unitid is ${_unitid} (Agent) — saving login data to SQLite...');
                  await saveLoginData();
                } catch (e) {
                  print(
                      '❌ Error while saving login data for unitid ${_unitid}: $e');
                }

                // Make additional HTTP request to get session data
                try {
                  print(
                      '📡 Making session request for agent unitid ${_unitid}...');
                  final sessionResponse = await http.post(
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
                  print(
                      '📡 Session HTTP Response Status: ${sessionResponse.statusCode}');
                  print(
                      '📡 Session HTTP Response Body: ${sessionResponse.body}');

                  if (sessionResponse.statusCode == 200) {
                    try {
                      final sessionResponseBody =
                          json.decode(sessionResponse.body);
                      print('📡 Session Response JSON: $sessionResponseBody');
                      print(
                          '📡 Session Response Keys: ${sessionResponseBody.keys.toList()}');

                      // Update SQLite with session response data
                      final responseData = sessionResponseBody['responseData'];
                      final projectName =
                          responseData?['projectName']?.toString() ?? '';
                      final projectId =
                          responseData?['projectId']?.toString() ?? '';
                      final productionHouse =
                          responseData?['productionHouse']?.toString() ?? '';
                      final productionTypeId =
                          responseData?['productionTypeId'] ?? 0;

                      print('🔍 Extracted values from responseData:');
                      print('🔍 projectName: "$projectName"');
                      print('🔍 projectId: "$projectId"');
                      print('🔍 productionHouse: "$productionHouse"');
                      print('🔍 productionTypeId: "$productionTypeId"');

                      // Update SQLite with session data
                      print('📡 Attempting SQLite update...');
                      await updateDriverLoginData(projectName, projectId,
                          productionHouse, productionTypeId);
                      print('📡 SQLite update call completed');

                      if (projectName.isNotEmpty ||
                          projectId.isNotEmpty ||
                          productionHouse.isNotEmpty) {
                        print('📡 Updated SQLite with session response data');
                      } else {
                        print(
                            '⚠️ All session data fields are empty, but update was attempted');
                      }

                      // Update isDriver field in SQLite - always false for agents
                      await updateDriverField(false);
                      print(
                          '✅ Updated isDriver field to: false for agent unitid ${_unitid}');

                      // Navigate to RouteScreenforAgent
                      print(
                          '👔 Agent (unitid: ${_unitid}) - navigating to RouteScreenforAgent');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RoutescreenforAgent()),
                      );
                    } catch (e) {
                      print('❌ Error processing session response JSON: $e');
                      print(
                          '📡 Raw session response body: ${sessionResponse.body}');

                      // On JSON parsing error, still navigate with isDriver = false
                      await updateDriverField(false);
                      print(
                          '⚠️ JSON parsing failed, navigating to RouteScreenforAgent anyway');

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RoutescreenforAgent()),
                      );
                    }
                  } else {
                    print(
                        '❌ Session response status code: ${sessionResponse.statusCode}');
                    print('❌ Session response body: ${sessionResponse.body}');

                    // On session request failure, still navigate with isDriver = false
                    await updateDriverField(false);
                    print(
                        '⚠️ Session request failed, navigating to RouteScreenforAgent anyway');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RoutescreenforAgent()),
                    );
                  }
                } catch (e) {
                  print('❌ Error in session HTTP request: $e');

                  // On HTTP error, still navigate with isDriver = false
                  await updateDriverField(false);
                  print(
                      '⚠️ Session HTTP request failed, navigating to RouteScreenforAgent anyway');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RoutescreenforAgent()),
                  );
                }
              } else {
                // Show dialog for invalid users (non-agents)
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Access Denied'),
                      content: Text(
                          'This is an agent login screen. Only agents (unitid: 5, 10, 18) can access this application.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              }
            }
          } else {
            showmessage(context, "Invalid response from server", "ok");
          }
        } catch (e) {
          print("Error parsing login response: $e");
          showmessage(context, "Failed to process login response", "ok");
        }
      } else {
        try {
          final errorBody = json.decode(response.body);
          setState(() {
            loginresponsebody = errorBody;
          });
          showmessage(
              context, errorBody?['errordescription'] ?? "Login failed", "ok");
        } catch (e) {
          print("Error parsing error response: $e");
          showmessage(context, "Login failed", "ok");
        }
        print(response.body + "📊📊📊📊📊📊📊📊📊📊📊📊📊📊📊📊");
      }
    } catch (e) {
      print("Error in loginr(): $e");
      setState(() {
        _isLoading = false;
      });
      showmessage(context, "Network error. Please try again.", "ok");
    }
  }

  @override
  void dispose() {
    // Don't close database here - let it close naturally
    // _database?.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      print('🚀 Starting app initialization...');

      // Test SQLite functionality
      await testSQLite();

      // Load base URL
      print('🌐 Loading base URL...');
      await baseurl();
      print('✅ Base URL loaded');
    } catch (e) {
      print('❌ Error during app initialization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Remove the extra AppBar so the background gradient can fill the
      // entire screen. Make the scaffold itself transparent.

      body: Stack(
        children: [
          // Subtle background overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF164AE9).withOpacity(0.15),
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.04),
                // Logo/Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: screenWidth * 0.22,
                        height: screenWidth * 0.22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            cinefo__logo,
                            // cinefoagent,
                            // cinefodriver,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        // 'Agent Login',
                        // 'Driver Login',
                        'Agent Login',
                        // 'Setting Login',
                        style: TextStyle(
                          fontSize: screenWidth * 0.055,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF164AE9),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.07),
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06,
                              vertical: screenHeight * 0.04,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Login to Continue",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.04),
                                TextFormField(
                                  controller: loginmobilenumber,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'Mobile Number',
                                    prefixIcon: Icon(Icons.phone,
                                        color: Color(0xFF164AE9)),
                                    labelStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.025),
                                TextFormField(
                                  controller: loginpassword,
                                  keyboardType: TextInputType.visiblePassword,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock,
                                        color: Color(0xFF164AE9)),
                                    labelStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // TODO: Implement forgot password
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Color(0xFF164AE9),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                SizedBox(
                                  width: double.infinity,
                                  height: screenHeight * 0.07,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () {
                                            loginr();
                                          },
                                    style: ElevatedButton.styleFrom(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      padding: EdgeInsets.zero,
                                      backgroundColor: null,
                                    ).copyWith(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith<Color?>((states) {
                                        if (states
                                            .contains(MaterialState.disabled)) {
                                          return Colors.grey[400];
                                        }
                                        return null;
                                      }),
                                    ),
                                    child: Ink(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF164AE9),
                                            Color(0xFF4F8CFF),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: _isLoading
                                            ? CircularProgressIndicator(
                                                color: Colors.white,
                                              )
                                            : Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Login',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize:
                                                          screenWidth * 0.045,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(Icons.login,
                                                      color: Colors.white),
                                                ],
                                              ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
                  child: Text(
                    'V.4.0.2',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
