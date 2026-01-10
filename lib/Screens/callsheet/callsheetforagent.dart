import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:production/sessionexpired.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import '../../ApiCalls/apicall.dart' as apicalls;
import 'approval_screen.dart';
import 'callsheet_detail.dart';

class Callsheetforagent extends StatefulWidget {
  const Callsheetforagent({super.key});

  @override
  State<Callsheetforagent> createState() => _CallsheetforagentState();
}

class _CallsheetforagentState extends State<Callsheetforagent> {
  Database? _database;
  Map<String, dynamic>? logindata;
  bool _isLoading = false;
  List<Map<String, dynamic>> callSheetData = [];

  // Responsive helper methods
  double getResponsiveWidth(double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  double getResponsiveHeight(double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  double getResponsiveFontSize(double baseFontSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    return baseFontSize * (screenWidth / 375);
  }

  double getResponsiveSpacing(double baseSpacing) {
    double screenWidth = MediaQuery.of(context).size.width;
    return baseSpacing * (screenWidth / 375);
  }

  @override
  void initState() {
    super.initState();
    _initializeAndCallAPI();
  }

  // Initialize database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database connection
  Future<Database> _initDatabase() async {
    String dbPath = path.join(await getDatabasesPath(), 'production_login.db');
    return await openDatabase(
      dbPath,
      version: 1,
      // This just connects to existing database
    );
  }

  // Get login data from SQLite
  Future<Map<String, dynamic>?> _getLoginData() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'login_data',
        orderBy: 'id ASC',
        limit: 1,
      );

      if (maps.isNotEmpty) {
        print('📊 Login data found: ${maps.first}');
        return maps.first;
      }
      print('🔍 No login data found in table');
      return null;
    } catch (e) {
      print('❌ Error getting login data: $e');
      return null;
    }
  }

  // Initialize and call API
  Future<void> _initializeAndCallAPI() async {
    setState(() => _isLoading = true);

    try {
      // First fetch the login_data table values
      logindata = await _getLoginData();

      if (logindata != null) {
        // Call lookupcallsheetapi with retrieved values
        await _callLookupCallsheetAPI();
      } else {
        _showError('No login data found. Please login first.');
      }
    } catch (e) {
      _showError('Error initializing: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Call the lookup callsheet API
  Future<void> _callLookupCallsheetAPI() async {
    try {
      // Convert projectid to integer
      int projectidInt;
      final projectidValue = logindata!['project_id'];
      if (projectidValue is String) {
        projectidInt = int.tryParse(projectidValue) ?? 0;
      } else if (projectidValue is int) {
        projectidInt = projectidValue;
      } else {
        projectidInt = 0;
      }

      print(
          '🔄 Converting project_id: $projectidValue (${projectidValue.runtimeType}) → $projectidInt');

      final result = await apicalls.approvalofproductionmanagerapi(
        callsheetstatusid: 1,
        vsid: logindata!['vsid'] ?? '',
      );

      if (result['success']) {
        print('✅ Lookup callsheet API successful');
        print('📄 Response: ${result['body']}');

        // Parse the response and extract callsheet data
        _parseCallSheetResponse(result['body']);
        _showSuccess('Callsheet data loaded successfully!');
      } else {
        print('❌ Lookup callsheet API failed: ${result['body']}');
        // Check for session expiration
        try {
          Map error = jsonDecode(result['body']);
          if (error['errordescription'] == "Session Expired") {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const Sessionexpired()));
            return;
          }
        } catch (e) {
          print('Error parsing error response: $e');
        }
        _showError('Failed to load callsheet data: ${result['body']}');
      }
    } catch (e) {
      print('❌ Error calling lookup callsheet API: $e');
      _showError('Error loading callsheet data: $e');
    }
  }

  // Parse the API response and extract callsheet data
  void _parseCallSheetResponse(String responseBody) {
    try {
      final Map<String, dynamic> response = jsonDecode(responseBody);
      if (response['responseData'] != null &&
          response['responseData'] is List) {
        setState(() {
          callSheetData =
          List<Map<String, dynamic>>.from(response['responseData']);
        });
        print('📋 Parsed ${callSheetData.length} callsheet records');
      }
    } catch (e) {
      print('❌ Error parsing callsheet response: $e');
      setState(() {
        callSheetData = [];
      });
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2B5682),
                Color(0xFF24426B),
              ],
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(
              "Call Sheets",
              style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: getResponsiveFontSize(18)),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(getResponsiveSpacing(20.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: getResponsiveSpacing(30)),
                  // Call sheets list section
                  if (_isLoading)
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(getResponsiveSpacing(40)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(getResponsiveSpacing(15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: getResponsiveSpacing(6),
                              offset: Offset(0, getResponsiveSpacing(2)),
                            ),
                          ],
                        ),
                        child: CircularProgressIndicator(
                          color: Color(0xFF2B5682),
                        ),
                      ),
                    )
                  else if (callSheetData.isEmpty)
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(getResponsiveSpacing(40)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(getResponsiveSpacing(15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: getResponsiveSpacing(6),
                              offset: Offset(0, getResponsiveSpacing(2)),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: getResponsiveFontSize(60),
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: getResponsiveSpacing(16)),
                            Text(
                              "No Call Sheets Available",
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(16),
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Call Sheets Section
                        if (callSheetData.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.only(bottom: getResponsiveSpacing(12)),
                            child: Text(
                              "Call Sheets List",
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(18),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          ...callSheetData.map((callSheet) =>
                              _buildCallSheetCard(context, callSheet)),
                        ],
                      ],
                    ),
                  // Add extra bottom padding to prevent content from being hidden by navigation
                  SizedBox(height: getResponsiveSpacing(100)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Build call sheet card widget similar to incharge report style
  Widget _buildCallSheetCard(
      BuildContext context, Map<String, dynamic> callSheet) {
    // Extract fields from callSheet map
    final String callSheetId = callSheet['callSheetId']?.toString() ?? "N/A";
    final String callSheetNo = callSheet['callSheetNo']?.toString() ?? "N/A";
    final String projectName = callSheet['projectName']?.toString() ?? "N/A";
    final String createdDate = callSheet['createdDate']?.toString() ??
        callSheet['date']?.toString() ??
        "N/A";
    final String shift = callSheet['shift']?.toString() ?? "N/A";
    final String status = callSheet['callsheetStatus']?.toString() ?? "N/A";
    return GestureDetector(
      onTap: () {
        // Navigate to the full callsheet detail screen (new file)
        Navigator.push(
          context,
          MaterialPageRoute(
            // builder: (_) => CallsheetDetailScreen(callsheet: callSheet),
            builder: (_) => ApprovalScreen(0,callSheet: callSheet,),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: getResponsiveSpacing(12)),
        padding: EdgeInsets.all(getResponsiveSpacing(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(getResponsiveSpacing(12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: getResponsiveSpacing(4),
              offset: Offset(0, getResponsiveSpacing(2)),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient background
            Container(
              padding: EdgeInsets.symmetric(horizontal: getResponsiveSpacing(12), vertical: getResponsiveSpacing(8)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4A6FA5).withOpacity(0.1),
                    const Color(0xFF2E4B73).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(getResponsiveSpacing(8)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Call Sheet #$callSheetNo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getResponsiveFontSize(16),
                        color: Color(0xFF2B5682),
                      ),
                    ),
                  ),
                  Container(
                    padding:
                    EdgeInsets.symmetric(horizontal: getResponsiveSpacing(8), vertical: getResponsiveSpacing(4)),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(getResponsiveSpacing(6)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(12),
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: getResponsiveSpacing(12)),
            // Project Name
            Row(
              children: [
                Icon(
                  Icons.movie,
                  size: getResponsiveFontSize(16),
                  color: Colors.grey[600],
                ),
                SizedBox(width: getResponsiveSpacing(4)),
                Text(
                  "Project: ",
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(14),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    projectName,
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(14),
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: getResponsiveSpacing(8)),
            // Call Sheet ID and Created Date
            Row(
              children: [
                Icon(
                  Icons.badge,
                  size: getResponsiveFontSize(16),
                  color: Colors.grey[600],
                ),
                SizedBox(width: getResponsiveSpacing(4)),
                Text(
                  "ID: $callSheetId",
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(14),
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today,
                  size: getResponsiveFontSize(16),
                  color: Colors.grey[600],
                ),
                SizedBox(width: getResponsiveSpacing(4)),
                Text(
                  createdDate,
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(14),
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF355E8C),
                  ),
                ),
              ],
            ),
            SizedBox(height: getResponsiveSpacing(8)),
            // Shift Information
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: getResponsiveFontSize(16),
                  color: Colors.grey[600],
                ),
                SizedBox(width: getResponsiveSpacing(4)),
                Text(
                  "Shift: ",
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(14),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    shift,
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(14),
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'closed':
        return Colors.green;
      case 'in-progress':
      case 'active':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }
}
