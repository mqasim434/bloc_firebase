import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  int _currentPage = 0;
  final PageController _pageController = PageController();

  int get currentPage => _currentPage;
  PageController get pageController => _pageController;

  void changePage(int pageIndex) {
    _currentPage = pageIndex;
    _pageController.animateToPage(_currentPage,
        duration: const Duration(seconds: 1), curve: Curves.ease);
    notifyListeners();
  }
}
