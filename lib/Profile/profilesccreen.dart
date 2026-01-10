import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:production/Screens/Home/colorcode.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqflite.dart';

class Profilesccreen extends StatefulWidget {
  const Profilesccreen({super.key});

  @override
  State<Profilesccreen> createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<Profilesccreen> {
  File? _profileImage;
  Map<String, dynamic>? loginData;

  // Responsive helper methods
  double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * (percentage / 100);
  }

  double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * (percentage / 100);
  }

  double getResponsiveFontSize(BuildContext context, double baseSize) {
    double screenWidth = MediaQuery.of(context).size.width;
    return baseSize * (screenWidth / 375);
  }

  double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    double screenWidth = MediaQuery.of(context).size.width;
    return baseSpacing * (screenWidth / 375);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _fetchLoginData() async {
    final dbPath = await getDatabasesPath();
    final db = await openDatabase(path.join(dbPath, 'production_login.db'));
    final List<Map<String, dynamic>> loginMaps = await db.query('login_data');
    if (loginMaps.isNotEmpty) {
      setState(() {
        loginData = loginMaps.first;
      });
    }
    await db.close();
  }

  Widget buildProfileField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: getResponsiveSpacing(context, 16),
        vertical: getResponsiveSpacing(context, 6),
      ),
      child: Row(
        children: [
          SizedBox(
            width: getResponsiveWidth(context, 26),
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: getResponsiveFontSize(context, 14),
              ),
            ),
          ),
          SizedBox(width: getResponsiveSpacing(context, 16)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: getResponsiveFontSize(context, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchLoginData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: getResponsiveFontSize(context, 20),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Profile Info',
          style: TextStyle(
            color: Colors.white,
            fontSize: getResponsiveFontSize(context, 18),
          ),
        ),
      ),
      body: loginData == null
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: getResponsiveSpacing(context, 4),
              ),
            )
          : Column(
              children: [
                SizedBox(height: getResponsiveSpacing(context, 10)),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: getResponsiveSpacing(context, 55),
                      backgroundColor: Colors.white,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : const AssetImage('assets/cni.png') as ImageProvider,
                    ),
                    Positioned(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: getResponsiveSpacing(context, 15),
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.edit,
                            size: getResponsiveFontSize(context, 15),
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: getResponsiveSpacing(context, 8)),
                Text(
                  loginData?["manager_name"] ?? '',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: getResponsiveFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Divider(
                  color: Colors.white24,
                  height: getResponsiveSpacing(context, 30),
                  thickness: getResponsiveSpacing(context, 1),
                ),
                buildProfileField('Name', loginData?["manager_name"] ?? ''),
                buildProfileField('Mobile', loginData?["mobile_number"] ?? ''),
                buildProfileField('Designation', loginData?["subUnitName"] ?? ''),
                buildProfileField(
                    'Production House', loginData?["production_house"] ?? ''),
              ],
            ),
    );
  }
}
