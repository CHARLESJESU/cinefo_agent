import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:production/ApiCalls/apicall.dart';
import 'package:production/sessionexpired.dart';
import 'package:production/variables.dart';

class Callsheetmembers extends StatefulWidget {
  final String projectId;
  final String maincallsheetid;

  const Callsheetmembers({
    super.key,
    required this.projectId,
    required this.maincallsheetid,
  });

  @override
  State<Callsheetmembers> createState() => _CallsheetmembersState();
}

class _CallsheetmembersState extends State<Callsheetmembers> {
  List<AttendanceEntry> reportData = [];
  bool isLoading = true;

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

  Future<void> reportsscreen() async {
    print(widget.maincallsheetid);
   
    print(globalloginData?['vsid'] ?? '');
    await fetchloginDataFromSqlite();
    final payload = {
      "unitid": unitid,
      "callsheetid": widget.maincallsheetid,
      "vmid": 0,
    };
    print(payload);
//api call
    try {
      final response = await http.post(
        processSessionRequest,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'VMETID':
              "VtHdAOR3ljcro4U+M9+kByyNPjr8d/b3VNhQmK9lwHYmkC5cUmqkmv6Ku5FFOHTYi9W80fZoAGhzNSB9L/7VCTAfg9S2RhDOMd5J+wkFquTCikvz38ZUWaUe6nXew/NSdV9K58wL5gDAd/7W0zSOpw7Qb+fALxSDZ8UmWdk7MxLkZDn0VIHwVAgv13JeeZVivtG7gu0DJvTyPixMJUFCQzzADzJHoIYtgXV4342izgfc4Lqca4rdjVwYV79/LLqmz1M8yAWXqfSRb+ArLo6xtPrjPInGZcIO8U6uTH1WmXvw+pk3xKD/WEEAFk69w8MI1TrntrzGgDPZ21NhqZXE/w==",
          'VSID': globalloginData?['vsid'] ?? '',
        },
        body: jsonEncode(payload),
      );

      checkSessionExpiration(response.body);

      if (response.statusCode == 200) {
        print("${response.body}✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ");
        final decoded = jsonDecode(response.body);

        // Check if there's a message to show
        if (decoded['message'] != null &&
            decoded['message'].toString().isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(decoded['message'].toString()),
              backgroundColor: decoded['responseData'] != null
                  ? Colors.green
                  : Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }

        if (decoded['responseData'] != null) {
          List<AttendanceEntry> entries = (decoded['responseData'] as List)
              .map((e) => AttendanceEntry.fromJson(e))
              .toList();
          setState(() {
            reportData = entries;
            isLoading = false;
          });
        } else {
          // No data found, stop loading
          setState(() {
            reportData = [];
            isLoading = false;
          });
        }
      } else {
        Map error = jsonDecode(response.body);
        print(error);
        if (error['errordescription'] == "Session Expired") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Sessionexpired()));
        }
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    reportsscreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: getResponsiveSpacing(context, 20)),
              Container(
                width: MediaQuery.of(context).size.width,
                height: getResponsiveHeight(context, 10),
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: getResponsiveSpacing(context, 30),
                    top: getResponsiveSpacing(context, 20),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back,
                          size: getResponsiveFontSize(context, 24),
                        ),
                      ),
                      SizedBox(width: getResponsiveSpacing(context, 20)),
                      Flexible(
                        child: Text(
                          "Callsheet Attendance Details",
                          style: TextStyle(
                            fontSize: getResponsiveFontSize(context, 14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: getResponsiveSpacing(context, 20),
                  right: getResponsiveSpacing(context, 20),
                  top: getResponsiveSpacing(context, 20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: getResponsiveHeight(context, 6.5),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(228, 215, 248, 1),
                        border: Border.all(
                          color: Color.fromRGBO(131, 77, 218, 1),
                          width: getResponsiveSpacing(context, 1),
                        ),
                        borderRadius: BorderRadius.circular(
                          getResponsiveSpacing(context, 8),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: getResponsiveSpacing(context, 10)),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Code',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: getResponsiveFontSize(context, 13),
                                color: Color.fromRGBO(131, 77, 218, 1),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: getResponsiveFontSize(context, 13),
                                color: Color.fromRGBO(131, 77, 218, 1),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'In Time',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: getResponsiveFontSize(context, 13),
                                color: Color.fromRGBO(131, 77, 218, 1),
                              ),
                            ),
                          ),
                          SizedBox(width: getResponsiveSpacing(context, 10)),
                          Expanded(
                            child: Text(
                              'Out Time',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: getResponsiveFontSize(context, 13),
                                color: Color.fromRGBO(131, 77, 218, 1),
                              ),
                            ),
                          ),
                          SizedBox(width: getResponsiveSpacing(context, 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          strokeWidth: getResponsiveSpacing(context, 4),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: getResponsiveSpacing(context, 20),
                          vertical: getResponsiveSpacing(context, 10),
                        ),
                        itemCount: reportData.length,
                        itemBuilder: (context, index) {
                          final entry = reportData[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: getResponsiveSpacing(context, 10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    entry.code ?? "--",
                                    style: TextStyle(
                                      fontSize: getResponsiveFontSize(context, 13),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    entry.memberName,
                                    style: TextStyle(
                                      fontSize: getResponsiveFontSize(context, 13),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    entry.inTime ?? "--",
                                    style: TextStyle(
                                      fontSize: getResponsiveFontSize(context, 13),
                                    ),
                                  ),
                                ),
                                SizedBox(width: getResponsiveSpacing(context, 10)),
                                Expanded(
                                  child: Text(
                                    entry.outTime ?? "--",
                                    style: TextStyle(
                                      fontSize: getResponsiveFontSize(context, 13),
                                    ),
                                  ),
                                ),
                                SizedBox(width: getResponsiveSpacing(context, 10)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AttendanceEntry {
  final String memberName;
  final String? code;
  final String? inTime;
  final String? outTime;

  AttendanceEntry({
    required this.memberName,
    this.code,
    this.inTime,
    this.outTime,
  });

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    String unitCode = json['unitcode']?.toString() ?? '';
    String memberCodeCode = json['membercodeCode']?.toString() ?? '';
    String combinedCode = unitCode.isNotEmpty && memberCodeCode.isNotEmpty
        ? '$unitCode-$memberCodeCode'
        : (unitCode.isNotEmpty ? unitCode : memberCodeCode);

    return AttendanceEntry(
      memberName: json['memberName'] ?? '',
      code: combinedCode.isNotEmpty ? combinedCode : null,
      inTime: json['intime'],
      outTime: json['outTime'],
    );
  }

  AttendanceEntry copyWith({
    String? memberName,
    String? code,
    String? inTime,
    String? outTime,
  }) {
    return AttendanceEntry(
      memberName: memberName ?? this.memberName,
      code: code ?? this.code,
      inTime: inTime ?? this.inTime,
      outTime: outTime ?? this.outTime,
    );
  }
}
