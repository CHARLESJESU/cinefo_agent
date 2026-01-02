import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:production/variables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:production/variables.dart';
// Function to update trip status

Future<void> fetchloginDataFromSqlite() async {
  try {
    final dbPath = path.join(await getDatabasesPath(), 'production_login.db');
    final Database db = await openDatabase(dbPath);

    final List<Map<String, dynamic>> rows = await db.query(
      'login_data',
      orderBy: 'id ASC',
      limit: 1,
    );
    final Map<String, dynamic> first = rows.first;
    if (first['production_type_id'] is int) {
      print("❌❌❌❌❌❌ int");
    } else {
      print("❌❌❌❌❌❌ String");
    }
    globalloginData = first;
    productionTypeId = first['production_type_id'] ?? 0;
    vmid = first['vmid'];
    unitid = first['unitid'];
    projectId = first['project_id'];
    vsid = first['vsid'];
  } catch (e) {
    print('❌ Error fetching productionTypeId from SQLite: $e');
  }
}

Future<Map<String, dynamic>> agentreportapi() async {
  try {
    final payload = {};
    print("agentreportapiagentreportapi ${globalloginData?['vsid']}");
    final tripstatusresponse = await http.post(
      processSessionRequest,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'VMETID':
            'Oi05x+2wDhjG1diiQLR9DV6UwTPSDdKGvjNubE+YYu/ZpQ28r5o6d3NMOcFfbkIRpQ1Wk667jx5ksuyGpm3mE3vD1KOeoxTmu4c9ZFwXst8MSA1E+3kkvc9DgEGDXCou+gB64ztDzmo46NIPGVWl+nFdCyBxDnWn0sVaDWV2EIZh9ZADizVNOGfK5WVxWPZPipiBlQ9Pc9rzTo+JqvHmY7G0MXvnVQpnIMoIov5Hr7gP02/NhijxTA7+yLEggkZ0Ko+FogRjSi32PwnzY/K/dPntPT4cdXXuQIOV2CPePsd4Hy+pjrx79v2wD1V37zb8uDx+7kQ2QtWhvtK7R6iwEw==',
        'VSID': globalloginData?['vsid'] ?? '',
      },
      body: jsonEncode(payload),
    );

    print(
        '🚗 driverreportapi Status API Response Status: ${tripstatusresponse.statusCode}');
    print('🚗 driverreportapi Status API Response Status: ${payload}');
    print(
        '🚗 driverreportapi Status API Response Body: ${tripstatusresponse.body}');

    return {
      'statusCode': tripstatusresponse.statusCode,
      'body': tripstatusresponse.body,
      'success': tripstatusresponse.statusCode == 200,
    };
  } catch (e) {
    print('❌ Error in tripstatusapi: $e');
    return {
      'statusCode': 0,
      'body': 'Error: $e',
      'success': false,
    };
  }
}

Future<Map<String, dynamic>> approvalofproductionmanagerapi({
  required int callsheetstatusid,
  required String vsid,
}) async {
  try {
    final payload = {"callsheetstatusid": callsheetstatusid};
    final approvalofproductionmanagerapiresponse = await http.post(
      processSessionRequest,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'VMETID':
            'AuTfNLu/i8GSX5lxhYSrebOJkF9rnTYZEXm43WWlv6Wg2KRtTekVOni0DtEa1OP2UwPvw+dgyxKzwMGT8AttQboO8v3yWhzO7ecXNAoyDCLOeQDtRYzfiYwY3GN4hN5npc58tr6Jdd8iWnKy1ZhSJ7Nm7+Zgh2BP15u6sQVjpdqHBJTL0nxx6rdyjVYURSCU0FvXDiqzsbx+C1lZHiX0YGJb+IXFnPzl0lgZO/3FMbo21tVUfGnh0D19DPLVyggAyic+MMUK1Ld9mBRhvijnJoI86f44Us9NrLfQ+b4klTit0LL37PWKaJmdQ348psfMwzImm0FSiudDD1N1ttZqVg==',
        'VSID': vsid,
      },
      body: jsonEncode(payload),
    );

    print(
        '🚗 approvalofproductionmanagerapiresponse Status API Response Status: ${approvalofproductionmanagerapiresponse.statusCode}');
    print(
        '🚗 approvalofproductionmanagerapiresponse Status API Response Status: ${payload}');
    print(
        '🚗 approvalofproductionmanagerapiresponse Status API Response Body: ${approvalofproductionmanagerapiresponse.body}');

    return {
      'statusCode': approvalofproductionmanagerapiresponse.statusCode,
      'body': approvalofproductionmanagerapiresponse.body,
      'success': approvalofproductionmanagerapiresponse.statusCode == 200,
    };
  } catch (e) {
    print('❌ Error in tripstatusapi: $e');
    return {
      'statusCode': 0,
      'body': 'Error: $e',
      'success': false,
    };
  }
}

Future<Map<String, dynamic>> approvalofproductionmanager2api({
  required int callsheetid,
  required String vsid,
}) async {
  try {
    final payload = {"callsheetid": callsheetid};
    final approvalofproductionmanagerapiresponse = await http.post(
      processSessionRequest,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'VMETID':
            'LE/EOR30OyNb4E+Kjz45gOazQ6yGMNGd8evS7UqbbZZ3ECwNSBhBziffuiq4Et9kJAZmOVlCIpsaVLuFLTGzaObCpvyDQNACvFTGv/+T93SLNnPZ91xpMjigvv25FmErk24nSx8Y0L3Xo9wNJVFQn58DDdMPMxMuOdrYhUR/kXAMv09yxapmyaDhzxuNA26lF/1yiyczN/eu8n17qhZ0a6uk9VJzYwwHOJBCHrTsoccP4DQBzmu3NB71KunvzmlqexGgToiRLg47h75DV3WSafVQvk9vLL9G7ZxYiBrJM1hg6fST8NazX40BwrtC6herXnEjQHpHwYOQtH+UMr4J7A==',
        'VSID': vsid,
      },
      body: jsonEncode(payload),
    );

    print(
        '🚗 approvalofproductionmanagerapiresponse Status API Response Status: ${approvalofproductionmanagerapiresponse.statusCode}');
    print(
        '🚗 approvalofproductionmanagerapiresponse Status API Response Status: ${payload}');
    print(
        '🚗 approvalofproductionmanagerapiresponse Status API Response Body: ${approvalofproductionmanagerapiresponse.body}');

    return {
      'statusCode': approvalofproductionmanagerapiresponse.statusCode,
      'body': approvalofproductionmanagerapiresponse.body,
      'success': approvalofproductionmanagerapiresponse.statusCode == 200,
    };
  } catch (e) {
    print('❌ Error in tripstatusapi: $e');
    return {
      'statusCode': 0,
      'body': 'Error: $e',
      'success': false,
    };
  }
}
