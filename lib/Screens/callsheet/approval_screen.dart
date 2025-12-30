import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:production/Screens/callsheet/callsheet_detail.dart';
import 'package:production/sessionexpired.dart';
import 'package:sqflite/sqflite.dart';

import '../../ApiCalls/apicall.dart';

class ApprovalScreen extends StatefulWidget {
  final Map<String, dynamic> callSheet;
  final int approvalid; // initial value: 0 = waiting, 1 = approved
  const ApprovalScreen(this.approvalid, {Key? key, required this.callSheet})
      : super(key: key);
  @override
  State<ApprovalScreen> createState() => _ApprovalScreenState();
}

class _ApprovalScreenState extends State<ApprovalScreen> {
  Map<String, dynamic>? logindata;
  int approvalid = 0; // runtime state
  Database? _database;
  bool _isLoading = false; // new: show spinner while refreshing

  @override
  void initState() {
    super.initState();
    // initialize state from widget properties
    approvalid = widget.approvalid;
    // print callsheet as requested
    print('Callsheet: charles ${widget.callSheet}');
    // call API initializer
    _initializeAndCallAPI();
  }

  Future<void> _initializeAndCallAPI() async {
    try {
      // First fetch the login_data table values
      logindata = await _getLoginData();

      if (logindata != null) {
        // Ensure callsheetStatusId is an int (handle string values)


        // Normalize response body to a Map so we can safely inspect responseData
          try {
            // Parse callsheet id from the widget.callSheet (handle different key casings)
            final dynamic rawId = widget.callSheet['callSheetId'] ??
                widget.callSheet['callsheetid'] ??
                widget.callSheet['callsheetId'] ??
                widget.callSheet['callsheetID'] ??
                widget.callSheet['CallSheetId'];
            final int callsheetId = rawId is int
                ? rawId
                : (rawId is String ? int.tryParse(rawId) ?? 0 : 0);

            // Call the second approval API and log the response (safe await with try/catch)
            final result2 = await approvalofproductionmanager2api(
              callsheetid: callsheetId,
              vsid: logindata!['vsid'] ?? '',
            );
            print('approvalofproductionmanager2api result: $result2');

            // Check for session expiration
            if (!result2['success']) {
              try {
                Map error = jsonDecode(result2['body']);
                if (error['errordescription'] == "Session Expired") {
                  if (mounted) {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => const Sessionexpired()));
                  }
                  return;
                }
              } catch (e) {
                print('Error parsing error response: $e');
              }
            }

            // Parse result2 body safely to inspect responseData.Statusid
            dynamic body2 = result2['body'];
            Map<String, dynamic>? responseBody2;
            if (body2 == null) {
              responseBody2 = null;
            } else if (body2 is String) {
              try {
                final parsed2 = jsonDecode(body2);
                if (parsed2 is Map<String, dynamic>) {
                  responseBody2 = parsed2;
                }
              } catch (e) {
                responseBody2 = null;
              }
            } else if (body2 is Map<String, dynamic>) {
              responseBody2 = body2;
            }

            // Extract Statusid robustly (different possible key casings) and check for value 2
            int statusId = 0;
            if (responseBody2 != null && responseBody2['responseData'] != null) {
              final dynamic respData = responseBody2['responseData'];
              final dynamic rawStatusId = respData['Statusid'] ??
                  respData['StatusId'] ??
                  respData['statusid'] ??
                  respData['statusId'] ??
                  respData['Status'] ??
                  respData['status'];

              if (rawStatusId is int) {
                statusId = rawStatusId;
              } else if (rawStatusId is String) {
                statusId = int.tryParse(rawStatusId) ?? 0;
              }
            }

            if (statusId == 2) {
              setState(() {
                print("success charles");
                approvalid = 1;
              });
            } else {
              print('Approval not final (Statusid=$statusId), keeping approvalid=0');
            }

          } catch (e) {
            print('Error calling approvalofproductionmanager2api: $e');
          }

          // Do not change approvalid here; it is set only when statusId == 2 above.

      }
    } catch (e) {
      print('Error initializing: $e');
    }
  }

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

  // Handler for the refresh button. Shows a spinner while refreshing.
  Future<void> _onRefreshPressed() async {
    if (_isLoading) return; // prevent double taps
    setState(() {
      _isLoading = true;
    });
    try {
      await _initializeAndCallAPI();
      // Optional: give user feedback
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Refreshed')),
      );
    } catch (e) {
      print('Error during manual refresh: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Refresh failed')),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (approvalid == 0) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Approval was sent to the Production so pls wait till the Production manager confirm your approval',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                // Show loading spinner while refreshing, otherwise show refresh button
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    onPressed: _onRefreshPressed,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    // If approved, navigate to CallsheetDetailScreen immediately
    // Use a post-frame callback so navigation happens after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => CallsheetDetailScreen(callsheet: widget.callSheet),
        ),
      );
    });

    // While navigation happens, render an empty scaffold to avoid build issues
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
