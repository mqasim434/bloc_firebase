import 'package:bloc_firebase/providers/dashboard_provider.dart';
import 'package:bloc_firebase/screens/inbox_screen.dart';
import 'package:bloc_firebase/screens/LocationScreen.dart';
import 'package:bloc_firebase/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  final List<Widget> screensList = [
    const Inbox(),
    LiveLocationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: dashboardProvider.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: screensList,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: dashboardProvider.currentPage,
          onTap: (value) {
            print(value);
            dashboardProvider.changePage(value);
          },
          items: const [
            BottomNavigationBarItem(
              label: 'Inbox',
              icon: Icon(Icons.inbox),
            ),
            BottomNavigationBarItem(
              label: 'Location',
              icon: Icon(Icons.location_city),
            ),
            BottomNavigationBarItem(
              label: 'Profile',
              icon: Icon(Icons.person),
            ),
          ],
        ),
      ),
    );
  }
}
