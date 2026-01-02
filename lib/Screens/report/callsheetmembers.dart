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

  Future<void> reportsscreen() async {
    print(widget.maincallsheetid);
    print(agentunitid);
    print(globalloginData?['vsid'] ?? '');
    await fetchloginDataFromSqlite();
    final payload={
"unitid": agentunitid,
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
    if (response.statusCode == 200) {
        print("${response.body}✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ✅ ");
        final decoded = jsonDecode(response.body);
        if (decoded['responseData'] != null) {
          List<AttendanceEntry> entries = (decoded['responseData'] as List)
              .map((e) => AttendanceEntry.fromJson(e))
              .toList();
          setState(() {
            reportData = entries;
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
              SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 80,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.only(left: 30, top: 20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back),
                      ),
                      SizedBox(width: 20),
                      Text(
                        "Callsheet Attendance Details",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(228, 215, 248, 1),
                        border: Border.all(
                          color: Color.fromRGBO(131, 77, 218, 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: Text('Code',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(131, 77, 218, 1),
                                )),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text('Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(131, 77, 218, 1),
                                )),
                          ),
                          Expanded(
                            child: Text('In Time',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(131, 77, 218, 1),
                                )),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Text('Out Time',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(131, 77, 218, 1),
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        itemCount: reportData.length,
                        itemBuilder: (context, index) {
                          final entry = reportData[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 2, child: Text(entry.code ?? "--")),
                                Expanded(
                                    flex: 3, child: Text(entry.memberName)),
                                Expanded(child: Text(entry.inTime ?? "--")),
                                SizedBox(width: 20),
                                Expanded(child: Text(entry.outTime ?? "--")),
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
