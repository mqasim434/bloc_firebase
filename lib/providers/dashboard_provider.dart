import 'package:flutter/material.dart';
import 'package:bloc_firebase/screens/inbox_screen.dart';
import 'package:bloc_firebase/screens/LocationScreen.dart';
import 'package:bloc_firebase/screens/profile.dart';

class DashboardProvider extends ChangeNotifier {
  int _currentPage = 0
  ;
  final PageController _pageController = PageController();

  final List<Widget> screensList = [
    const Inbox(),
    const LiveLocationScreen(),
    const ProfileScreen(),
  ];

  int get currentPage => _currentPage;
  PageController get pageController => _pageController;

  void changePage(int pageIndex) {
    print(pageIndex);
    _currentPage = pageIndex;
    _pageController.animateTo(_currentPage.toDouble(),
        duration: const Duration(seconds: 1), curve: Curves.easeIn);
    notifyListeners();
  }
}
