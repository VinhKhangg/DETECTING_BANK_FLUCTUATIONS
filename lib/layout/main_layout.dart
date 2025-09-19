import 'package:flutter/material.dart';
import '../features/transaction/view/transaction_screen.dart';
import '../features/transaction/view/transaction_history_screen.dart';
import '../features/transaction/view/transaction_stats_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final GlobalKey<TransactionHistoryScreenState> _historyKey = GlobalKey();
  final GlobalKey<TransactionStatsScreenState> _statsKey = GlobalKey();

  late final List<Widget> _screens = [
    const TransactionNotifierScreen(), // Trang thêm giao dịch + thông báo
    TransactionHistoryScreen(key: _historyKey), // Trang lịch sử
    TransactionStatsScreen(key: _statsKey),     // Trang thống kê
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      _historyKey.currentState?.loadTransactions();
    } else if (index == 2) {
      _statsKey.currentState?.loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.blue,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.play_arrow),
            label: 'Giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Lịch sử',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Thống kê',
          ),
        ],
      ),
    );
  }
}
