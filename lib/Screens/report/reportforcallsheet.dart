import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:production/Screens/report/callsheetmembers.dart';
import 'package:production/sessionexpired.dart';
import '../../ApiCalls/apicall.dart' as apicalls;

class Reportforcallsheet extends StatefulWidget {
  const Reportforcallsheet({super.key});

  @override
  State<Reportforcallsheet> createState() => _ReportforcallsheeteState();
}

class _ReportforcallsheeteState extends State<Reportforcallsheet> {
  bool _isLoading = false;
  List<Map<String, dynamic>> callSheetData = [];
  String global_projectidString = "";

  // Responsive helper methods
  double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  double getResponsiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    return baseSize * (screenWidth / 375); // 375 is base width (iPhone SE)
  }

  double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    double screenWidth = MediaQuery.of(context).size.width;
    return baseSpacing * (screenWidth / 375);
  }
  
  @override
  void initState() {
    super.initState();
    _initializeAndCallAPI();
  }

  // Initialize and call API
  Future<void> _initializeAndCallAPI() async {
    setState(() => _isLoading = true);

    try {
      // First fetch login data from SQLite
      await apicalls.fetchloginDataFromSqlite();
      
      // Then call agent report API
      final result = await apicalls.agentreportapi();
      print("🚗 Agent Report API Response: ${result['body']}");
      print("🔍 API Result Success: ${result['success']}");
      print("🔍 API Result Keys: ${result.keys}");
      
      // Parse the response and extract callsheet data
      _parseCallSheetResponse(result['body']);
      
      if (callSheetData.isNotEmpty) {
        _showSuccess('Callsheet data loaded successfully!');
      }
    } catch (e) {
      print('❌ Error calling API: $e');
      _showError('Error loading callsheet data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Parse the API response and extract callsheet data
  void _parseCallSheetResponse(dynamic responseBody) {
    print('🔧 Starting to parse response...');
    print('🔧 Response body type: ${responseBody.runtimeType}');
    print('🔧 Response body: $responseBody');
    
    try {
      Map<String, dynamic> response;
      
      // Check if responseBody is already a Map or needs to be decoded
      if (responseBody is String) {
        response = jsonDecode(responseBody);
      } else if (responseBody is Map<String, dynamic>) {
        response = responseBody;
      } else {
        print('❌ Unexpected response type: ${responseBody.runtimeType}');
        setState(() {
          callSheetData = [];
        });
        return;
      }
      
      print('🔧 Decoded JSON successfully');
      print('🔧 Response keys: ${response.keys}');
      print('🔧 responseData exists: ${response.containsKey('responseData')}');
      print('🔧 responseData value: ${response['responseData']}');
      print('🔧 responseData type: ${response['responseData']?.runtimeType}');
      
      if (response['responseData'] != null && response['responseData'] is List) {
        final List<dynamic> rawData = response['responseData'] as List;
        print('🔧 responseData length: ${rawData.length}');
        
        setState(() {
          callSheetData = rawData
              .where((item) => item != null)
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        });
        
        print('📋 Parsed ${callSheetData.length} callsheet records');
        
        if (callSheetData.isNotEmpty) {
          print('📋 First record: ${callSheetData[0]}');
          global_projectidString = callSheetData[0]['projectId']?.toString() ?? "";
          print('📋 Set global projectId: $global_projectidString');
        }
      } else {
        print('⚠️ responseData is null or not a List');
        print('⚠️ responseData value: ${response['responseData']}');
        setState(() {
          callSheetData = [];
        });
      }
    } catch (e, stackTrace) {
      print('❌ Error parsing callsheet response: $e');
      print('❌ Stack trace: $stackTrace');
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

  // Format date from YYYYMMDD to DD-MM-YYYY
  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return "N/A";
    
    String dateStr = dateValue.toString();
    
    // If it's in YYYYMMDD format (8 digits)
    if (dateStr.length == 8 && int.tryParse(dateStr) != null) {
      String year = dateStr.substring(0, 4);
      String month = dateStr.substring(4, 6);
      String day = dateStr.substring(6, 8);
      return "$day-$month-$year";
    }
    
    return dateStr;
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
              "Call Sheets Report",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: getResponsiveFontSize(context, 18),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(getResponsiveSpacing(context, 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: getResponsiveSpacing(context, 30)),
                  // Call sheets list section
                  if (_isLoading)
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(getResponsiveSpacing(context, 40)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            getResponsiveSpacing(context, 15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: getResponsiveSpacing(context, 6),
                              offset: Offset(0, getResponsiveSpacing(context, 2)),
                            ),
                          ],
                        ),
                        child: CircularProgressIndicator(
                          color: Color(0xFF2B5682),
                          strokeWidth: getResponsiveSpacing(context, 4),
                        ),
                      ),
                    )
                  else if (callSheetData.isEmpty)
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(getResponsiveSpacing(context, 40)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            getResponsiveSpacing(context, 15),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: getResponsiveSpacing(context, 6),
                              offset: Offset(0, getResponsiveSpacing(context, 2)),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: getResponsiveFontSize(context, 60),
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: getResponsiveSpacing(context, 16)),
                            Text(
                              "No Call Sheets Available",
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(context, 16),
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
                            padding: EdgeInsets.only(
                              bottom: getResponsiveSpacing(context, 12),
                            ),
                            child: Text(
                              "Report List",
                              style: TextStyle(
                                fontSize: getResponsiveFontSize(context, 18),
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
                  SizedBox(height: getResponsiveSpacing(context, 100)),
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
    final String date = _formatDate(callSheet['date']);
    final String shift = callSheet['shift']?.toString() ?? "N/A";
    final String status = callSheet['callsheetStatus']?.toString() ?? "N/A";
    return GestureDetector(
      onTap: () {
        // Navigate to the full callsheet detail screen (new file)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Callsheetmembers(
              projectId: global_projectidString,
              maincallsheetid: callSheetId,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: getResponsiveSpacing(context, 12)),
        padding: EdgeInsets.all(getResponsiveSpacing(context, 16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            getResponsiveSpacing(context, 12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: getResponsiveSpacing(context, 4),
              offset: Offset(0, getResponsiveSpacing(context, 2)),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: getResponsiveSpacing(context, 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient background
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: getResponsiveSpacing(context, 12),
                vertical: getResponsiveSpacing(context, 8),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4A6FA5).withOpacity(0.1),
                    const Color(0xFF2E4B73).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(
                  getResponsiveSpacing(context, 8),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Call Sheet #$callSheetNo",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: getResponsiveFontSize(context, 16),
                        color: Color(0xFF2B5682),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: getResponsiveSpacing(context, 8),
                      vertical: getResponsiveSpacing(context, 4),
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(
                        getResponsiveSpacing(context, 6),
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 12),
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: getResponsiveSpacing(context, 12)),
            // Project Name
            Row(
              children: [
                Icon(
                  Icons.movie,
                  size: getResponsiveFontSize(context, 16),
                  color: Colors.grey[600],
                ),
                SizedBox(width: getResponsiveSpacing(context, 4)),
                Text(
                  "Project: ",
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, 14),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    projectName,
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(context, 14),
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: getResponsiveSpacing(context, 8)),
            // Call Sheet ID and Created Date
            Row(
              children: [
                Icon(
                  Icons.badge,
                  size: getResponsiveFontSize(context, 16),
                  color: Colors.grey[600],
                ),
                SizedBox(width: getResponsiveSpacing(context, 4)),
                Text(
                  "ID: $callSheetId",
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, 14),
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today,
                  size: getResponsiveFontSize(context, 16),
                  color: Colors.grey[600],
                ),
                SizedBox(width: getResponsiveSpacing(context, 4)),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF355E8C),
                  ),
                ),
              ],
            ),
            SizedBox(height: getResponsiveSpacing(context, 8)),
            // Shift Information
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: getResponsiveFontSize(context, 16),
                  color: Colors.grey[600],
                ),
                SizedBox(width: getResponsiveSpacing(context, 4)),
                Text(
                  "Shift: ",
                  style: TextStyle(
                    fontSize: getResponsiveFontSize(context, 14),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    shift,
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(context, 14),
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
    super.dispose();
  }
}
