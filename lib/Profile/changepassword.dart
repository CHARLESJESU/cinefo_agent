import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:production/ApiCalls/apicall.dart';
import 'package:production/Screens/Login/login_dialog_helper.dart';
import 'package:production/sessionexpired.dart';
import 'package:production/variables.dart';

class Changepassword extends StatefulWidget {
  const Changepassword({super.key});

  @override
  State<Changepassword> createState() => _ChangepasswordState();
}

class _ChangepasswordState extends State<Changepassword> {
  TextEditingController reneterpassword = TextEditingController();
  TextEditingController currentpassword = TextEditingController();
  TextEditingController newpassword = TextEditingController();
  bool isloading = false;

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

  Future<void> changepassword() async {
    setState(() {
      isloading = true;
    });
    final url =
        Uri.parse('https://vgate.vframework.in/vgateapi/processSessionRequest');

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'VMETID':
            'mAgpajsKo9pVRfBicuVsGkzZG986GWPpxfGpbR9A2ysD1WGBMyqj2gL4NTftf7VABJvOG5KZ9iTW4ybk3oYbnO32oL+b08Ba9MW5pRlI6HaDbOb9pU4iH4VxGB79hQS+27ZzZuTOa9a4e8FrO3ASPC4B21zbSa19fJg1elJ/QK/PkA435B0vpMPKmp4vxfy0/tOEuO3yk5OuykSdwjBHoylNcqeZ2YeUaKeO5W9RwdfKDNMA50GTKxK80PrNQ7RlHJHuYH1NuO84hOvinlrITWc/+MPut0ePT14GyygBCVhRfWioIp3Qyxd+QENfFgqc7UwX8Q8MWERGf5uybUU1Pg==',
        'VSID': loginresponsebody!['vsid']
      },
      body: jsonEncode(<String, dynamic>{
        "vuid": loginresult!['vuid'],
        "mobileNumber": loginresult!['mobileNumber'].toString(),
        "password": currentpassword.text,
        "newpassword": newpassword.text
      }),
    );

    checkSessionExpiration(response.body);

    if (response.statusCode == 200) {
      setState(() {
        isloading = false;
      });
      LoginDialogHelper.showsuccessPopUp(context, "Password changed", () {});

      currentpassword.clear();
      newpassword.clear();
      _popScreenAfterDelay();
    } else {
      setState(() {
        isloading = false;
      });
      try {
        Map error = jsonDecode(response.body);
        if (error['errordescription'] == "Session Expired") {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const Sessionexpired()));
        } else {
          LoginDialogHelper.showSimplePopUp(
            context,
            "Failed to change the password",
          );
        }
      } catch (e) {
        LoginDialogHelper.showSimplePopUp(
          context,
          "Failed to change the password",
        );
      }
    }
  }

  void _submitData() {
    if (newpassword.text == reneterpassword.text) {
      // Validate the current password and new password
      if (currentpassword.text.isNotEmpty && newpassword.text.isNotEmpty) {
        changepassword();
      } else {
        LoginDialogHelper.showSimplePopUp(
          context,
          "Please fill in all fields",
        );
      }
    } else {
      LoginDialogHelper.showSimplePopUp(
        context,
        "Passwords don't match",
      );
    }
  }

  void _popScreenAfterDelay() {
    // Add a small delay before popping the screen to avoid context issues
    Future.delayed(Duration(seconds: 3), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close the screen
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: getResponsiveSpacing(context, 10),
                left: getResponsiveSpacing(context, 15),
                right: getResponsiveSpacing(context, 15),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(getResponsiveSpacing(context, 2)),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context); // Pop screen
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: getResponsiveFontSize(context, 20),
                        )),
                  ),
                  SizedBox(width: getResponsiveSpacing(context, 10)),
                  Text(
                    'Change Password',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: getResponsiveFontSize(context, 18),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  top: getResponsiveSpacing(context, 75),
                  left: getResponsiveSpacing(context, 20),
                  right: getResponsiveSpacing(context, 20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Password',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 18),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: getResponsiveSpacing(context, 10)),
                    Text(
                      'Your new password must be different from previous used passwords',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 15),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: getResponsiveSpacing(context, 20)),
                    Text(
                      'Enter Current Password',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: getResponsiveSpacing(context, 10)),
                    _buildPasswordField(controller: currentpassword),
                    SizedBox(height: getResponsiveSpacing(context, 20)),
                    Text(
                      'Enter New Password',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: getResponsiveSpacing(context, 10)),
                    _buildPasswordField(controller: newpassword),
                    SizedBox(height: getResponsiveSpacing(context, 20)),
                    Text(
                      'Re-enter Password',
                      style: TextStyle(
                        fontSize: getResponsiveFontSize(context, 14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: getResponsiveSpacing(context, 10)),
                    _buildPasswordField(controller: reneterpassword),
                    SizedBox(height: getResponsiveSpacing(context, 60)),
                    GestureDetector(
                      onTap: _submitData,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: getResponsiveHeight(context, 7),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(
                            getResponsiveSpacing(context, 10),
                          ),
                        ),
                        child: Center(
                          child: isloading
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: getResponsiveSpacing(context, 3),
                                )
                              : Text(
                                  'Change Password',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: getResponsiveFontSize(context, 18),
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({required TextEditingController controller}) {
    return SizedBox(
      height: getResponsiveHeight(context, 6.5),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        style: TextStyle(fontSize: getResponsiveFontSize(context, 14)),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              getResponsiveSpacing(context, 10),
            ),
            borderSide: BorderSide(
              color: Colors.grey,
              width: getResponsiveSpacing(context, 1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              getResponsiveSpacing(context, 10),
            ),
            borderSide: BorderSide(
              color: Colors.grey,
              width: getResponsiveSpacing(context, 1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              getResponsiveSpacing(context, 10),
            ),
            borderSide: BorderSide(
              color: Colors.blue,
              width: getResponsiveSpacing(context, 2),
            ),
          ),
          labelText: controller == currentpassword
              ? 'Current Password'
              : controller == newpassword
                  ? 'New Password'
                  : 'Re-enter Password',
          labelStyle: TextStyle(
            fontSize: getResponsiveFontSize(context, 14),
          ),
        ),
        onEditingComplete: () {
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}
