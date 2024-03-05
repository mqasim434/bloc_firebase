import 'package:bloc_firebase/providers/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: PageView(
          controller: dashboardProvider.pageController,
          allowImplicitScrolling: true,
          physics: const NeverScrollableScrollPhysics(),
          children: dashboardProvider.screensList,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: dashboardProvider.currentPage,
          onTap: (value) {
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
