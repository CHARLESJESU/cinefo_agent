import 'package:flutter/material.dart';
import 'package:production/Screens/Login/loginscreen.dart';


class Sessionexpired extends StatefulWidget {
  const Sessionexpired({super.key});

  @override
  State<Sessionexpired> createState() => _SessionexpiredState();
}

class _SessionexpiredState extends State<Sessionexpired> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: getResponsiveWidth(context, 80),
                height: getResponsiveHeight(context, 40),
                child: Image.asset(
                  'assets/sessionexpired.jpg',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: getResponsiveSpacing(context, 30)),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Loginscreen()));
                },
                child: Container(
                  width: getResponsiveWidth(context, 55),
                  height: getResponsiveHeight(context, 7),
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: getResponsiveSpacing(context, 1.5),
                    ),
                    borderRadius: BorderRadius.circular(
                      getResponsiveSpacing(context, 8),
                    ),
                  ),
                  child: Center(
                      child: Text(
                    "please login again",
                    style: TextStyle(
                      fontSize: getResponsiveFontSize(context, 16),
                    ),
                  )),
                ),
              )
            ],
          ),
        ));
  }
}
