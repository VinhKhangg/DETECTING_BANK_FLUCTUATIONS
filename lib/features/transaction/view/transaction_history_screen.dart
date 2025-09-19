import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 👈 thêm dòng này
import '../../../models/transaction_model.dart';
import '../../../services/database_service.dart';
import '../../auth/login_screen.dart';
import '../../../services/logout_service.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  TransactionHistoryScreenState createState() => TransactionHistoryScreenState();
}

class TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  void loadTransactions() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // 👈 lấy user hiện tại

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 2,
        backgroundColor: Colors.blue[50],
        title: Row(
          children: [
            Flexible(
              child: Image.asset(
                'assets/logo.png',
                height: 70,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Lịch sử giao dịch',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
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
      body: StreamBuilder<List<TransactionModel>>(
        stream: DatabaseService.listenTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi: ${snapshot.error}'),
            );
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                'Chưa có giao dịch nào.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final t = transactions[index];
              final amountFormatted = NumberFormat.currency(
                locale: 'vi_VN',
                symbol: '₫',
              ).format(t.amount);

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const Icon(Icons.account_balance_wallet,
                      color: Colors.indigo),
                  title: Text(
                    "+ $amountFormatted",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("👤 Người gửi: ${t.senderName}"),
                        Text("🏦 Ngân hàng: ${t.bankName}"),
                        Text("🔢 Số TK: ${t.accountNumber}"),
                        Text("🕒 Thời gian: ${DateFormat('dd/MM/yyyy HH:mm').format(t.time)}"),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
