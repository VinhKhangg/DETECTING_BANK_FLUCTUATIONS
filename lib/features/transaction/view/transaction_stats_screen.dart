import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/transaction_model.dart';
import '../../../services/database_service.dart';
import 'export_pdf_screen.dart';
import '../../auth/login_screen.dart';
import '../../../services/logout_service.dart';

class TransactionStatsScreen extends StatefulWidget {
  const TransactionStatsScreen({Key? key}) : super(key: key);

  @override
  TransactionStatsScreenState createState() => TransactionStatsScreenState();
}

class TransactionStatsScreenState extends State<TransactionStatsScreen> {
  DateTime selectedDate = DateTime.now();

  int dailyTransactionCount = 0;
  int monthlyTransactionCount = 0;
  double dailyTotalAmount = 0;
  double monthlyTotalAmount = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final transactions = await DatabaseService.getAllTransactions();

    int dayCount = 0;
    int monthCount = 0;
    double dayTotal = 0;
    double monthTotal = 0;

    for (var tx in transactions) {
      final txDate = tx.time;
      if (txDate.year == selectedDate.year &&
          txDate.month == selectedDate.month &&
          txDate.day == selectedDate.day) {
        dayCount++;
        dayTotal += tx.amount;
      }
      if (txDate.year == selectedDate.year &&
          txDate.month == selectedDate.month) {
        monthCount++;
        monthTotal += tx.amount;
      }
    }

    if (!mounted) return;

    setState(() {
      dailyTransactionCount = dayCount;
      dailyTotalAmount = dayTotal;
      monthlyTransactionCount = monthCount;
      monthlyTotalAmount = monthTotal;
      isLoading = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('vi', 'VN'),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        isLoading = true;
      });
      await loadStats();
    }
  }

  void _navigateToExportScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExportPdfScreen(),
      ),
    );
  }

  void _simulateTransaction() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("👉 Thêm giao dịch (chưa implement)")),
    );
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String dayStr = DateFormat('dd/MM/yyyy').format(selectedDate);
    final String monthStr = DateFormat('MM/yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue[50],
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 70),
            const SizedBox(width: 10),
            const Text('Thống kê giao dịch',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle, size: 28, color: Colors.black87),
            onSelected: (value) {
              if (value == 'logout') LogoutService.logout(context); // 👈 gọi service
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.displayName ?? "Chưa có tên",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?.email ?? "Không có email",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text("Đăng xuất"),
                  ],
                ),
              ),
            ],
          )
        ],
      ),

      // 🔹 Body
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.date_range, color: Colors.blue),
                const SizedBox(width: 8),
                Text("Ngày được chọn: $dayStr",
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            StatCard(
              icon: Icons.today,
              iconColor: Colors.blueAccent,
              label: 'Số giao dịch trong ngày',
              value: '$dailyTransactionCount lần',
            ),
            StatCard(
              icon: Icons.attach_money,
              iconColor: Colors.green,
              label: 'Tổng tiền trong ngày',
              value: formatCurrency(dailyTotalAmount),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Text("Thống kê theo tháng: $monthStr",
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 10),
            StatCard(
              icon: Icons.calendar_today,
              iconColor: Colors.orange,
              label: 'Số giao dịch trong tháng',
              value: '$monthlyTransactionCount lần',
            ),
            StatCard(
              icon: Icons.account_balance_wallet,
              iconColor: Colors.purple,
              label: 'Tổng tiền trong tháng',
              value: formatCurrency(monthlyTotalAmount),
            ),
          ],
        ),
      ),

      // 🔹 3 nút hành động ở dưới
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
            label: const Text("Chọn ngày"),
            backgroundColor: Colors.orange,
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            onPressed: _navigateToExportScreen,
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text("Xuất PDF"),
            backgroundColor: Colors.red,
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(label),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
