import 'package:flutter/material.dart';

import 'package:production/Screens/Home/MyHomescreen.dart';
import 'package:production/Screens/callsheet/callsheetforagent.dart';

import 'package:production/Screens/report/reportforcallsheet.dart';

import 'package:production/variables.dart';

class RoutescreenforAgent extends StatefulWidget {
  final int initialIndex;

  const RoutescreenforAgent(
      {super.key, this.initialIndex = 0}); // Default to Home tab

  @override
  State<RoutescreenforAgent> createState() => _RoutescreenforAgentState();
}

class _RoutescreenforAgentState extends State<RoutescreenforAgent> {
  int _currentIndex = 0;

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
    _currentIndex = widget.initialIndex; // Set initial tab from parameter
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF355E8C),

      body: SafeArea(
        child: _getScreenWidget(_currentIndex),
      ),

      
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF355E8C),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: getResponsiveFontSize(24)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, size: getResponsiveFontSize(24)),
            label: 'Callsheet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month, size: getResponsiveFontSize(24)),
            label: 'Reports',
          ),
   
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: getResponsiveFontSize(12),
        unselectedFontSize: getResponsiveFontSize(12),
        iconSize: getResponsiveFontSize(24),
      ),
    );
  }

  Widget _getScreenWidget(int index) {
    switch (index) {
      case 0:
        // return const MovieListScreen();
        return const MyHomescreen();

      case 1:
        if (productionTypeId == 3) {
          return (selectedProjectId != null && selectedProjectId != "0")
              ? Callsheetforagent()
              : const MyHomescreen();
        } else {
          // For productionTypeId == 2 or any other case
          return Callsheetforagent();
        }

      case 2:
        return Reportforcallsheet();
      // case 3:
      //   return TripScreen();
      default:
        return const MyHomescreen();
    }
  }
}
