import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/database_service.dart';
import '../../../models/transaction_model.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../auth/login_screen.dart';
import '../../../services/logout_service.dart';


class TransactionNotifierScreen extends StatefulWidget {
  const TransactionNotifierScreen({Key? key}) : super(key: key);

  @override
  _TransactionNotifierScreenState createState() =>
      _TransactionNotifierScreenState();
}

class _TransactionNotifierScreenState extends State<TransactionNotifierScreen> {
  final FlutterTts flutterTts = FlutterTts();
  String? lastNotification;

  @override
  void initState() {
    super.initState();
    NotificationService.initialize();
    _restoreLastNotification();
  }

  /// 🔹 Lấy thông báo gần nhất theo từng user
  Future<void> _restoreLastNotification() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid ?? "guest";

    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('last_notification_$uid');
    if (saved != null && saved.isNotEmpty) {
      setState(() => lastNotification = saved);
    }
  }


  /// 🔹 Giả lập giao dịch mới
  void _simulateTransaction() {
    String? selectedBank;
    String? selectedSender;

    final List<String> banks = [
      "Vietcombank",
      "VietinBank",
      "BIDV",
      "Agribank",
      "Techcombank",
      "MB Bank",
      "ACB",
      "Sacombank",
      "TPBank",
      "VPBank",
      "SHB",
      "Eximbank",
      "OCB",
      "SCB",
      "HDBank",
      "DongA Bank",
    ];

    final List<String> senders = [
      "khang",
      "thien",
      "huy",
      "long",
      "son",
      "nam",
      "tuan",
      "minh",
      "quang",
      "an",
    ];

    showDialog(
      context: context,
      builder: (context) {
        final accountController = TextEditingController();
        final amountController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Nhập giao dịch'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedSender,
                      decoration: const InputDecoration(labelText: "Người gửi"),
                      items: senders.map((sender) {
                        return DropdownMenuItem(
                          value: sender,
                          child: Text(sender),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedSender = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: accountController,
                      decoration:
                      const InputDecoration(labelText: 'Số tài khoản'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),

                    DropdownButtonFormField<String>(
                      value: selectedBank,
                      decoration: const InputDecoration(labelText: "Ngân hàng"),
                      items: banks.map((bank) {
                        return DropdownMenuItem(
                          value: bank,
                          child: Text(bank),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setStateDialog(() {
                          selectedBank = value;
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: amountController,
                      decoration:
                      const InputDecoration(labelText: 'Số tiền (VND)'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final sender = selectedSender ?? "";
                    final account = accountController.text.trim();
                    final bank = selectedBank ?? "";
                    final amountText = amountController.text.trim();

                    if (sender.isEmpty ||
                        account.isEmpty ||
                        bank.isEmpty ||
                        amountText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('⚠️ Vui lòng nhập đầy đủ thông tin')),
                      );
                      return;
                    }

                    final amount = double.tryParse(
                      amountText.replaceAll('.', '').replaceAll(',', ''),
                    ) ??
                        0;
                    if (amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⚠️ Số tiền không hợp lệ')),
                      );
                      return;
                    }

                    final now = DateTime.now();
                    final formattedTime =
                    DateFormat('dd/MM/yyyy HH:mm').format(now);

                    final formattedAmountForTTS =
                    NumberFormat("#,###", "vi_VN").format(amount.toInt());

                    final voiceMessage =
                        "Bạn vừa nhận được $formattedAmountForTTS đồng";

                    try {
                      final transactionModel = TransactionModel(
                        senderName: sender,
                        accountNumber: account,
                        bankName: bank,
                        amount: amount,
                        time: now,
                      );
                      await DatabaseService.insertTransaction(transactionModel);

                      setState(() {
                        lastNotification = voiceMessage;
                      });

                      // 🔹 Lưu theo UID user
                      final prefs = await SharedPreferences.getInstance();
                      final uid =
                          FirebaseAuth.instance.currentUser?.uid ?? "guest";
                      await prefs.setString(
                          'last_notification_$uid', voiceMessage);

                      // 🔊 Âm thanh + đọc giọng
                      final player = AudioPlayer();
                      await player.play(AssetSource('sounds/tingting.mp3'));

                      await Future.delayed(const Duration(milliseconds: 500));
                      await flutterTts.stop();
                      await flutterTts.setLanguage("vi-VN");
                      await flutterTts.setPitch(1.0);
                      await flutterTts.setSpeechRate(0.4);
                      await flutterTts.speak(voiceMessage);

                      // 🔔 Hiện notification local
                      final bankMessage =
                          "STK $account tại $bank: "
                          "${amount > 0 ? '+' : ''}${NumberFormat("#,###", "vi_VN").format(amount)}đ, "
                          "lúc $formattedTime";

                      await NotificationService.show(
                        "Ngân Hàng $bank",
                        bankMessage,
                      );

                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('❌ Lỗi khi lưu giao dịch: $e')),
                      );
                    }
                  },
                  child: const Text('Gửi'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
              'Thông báo biến động',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _simulateTransaction,
        icon: const Icon(Icons.add),
        label: const Text('Thêm giao dịch'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          if (lastNotification != null)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                color: Colors.yellow[100],
                child: ListTile(
                  leading:
                  const Icon(Icons.notifications, color: Colors.orange),
                  title: const Text(
                    'Thông báo gần nhất:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(lastNotification!),
                ),
              ),
            ),
          Expanded(
            child: StreamBuilder<List<TransactionModel>>(
              stream: DatabaseService.listenTransactions(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final transactions = snapshot.data!;
                if (transactions.isEmpty) {
                  return const Center(child: Text("Chưa có giao dịch nào."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final tx = transactions[index];
                    final formattedAmount = NumberFormat.currency(
                      locale: 'vi_VN',
                      symbol: '₫',
                    ).format(tx.amount);

                    final formattedTime =
                    DateFormat('dd/MM/yyyy HH:mm').format(tx.time);

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: const Icon(Icons.monetization_on,
                            color: Colors.green),
                        title: Text(
                          "+ $formattedAmount từ ${tx.senderName} | "
                              "STK: ${tx.accountNumber} - Ngân hàng: ${tx.bankName} | $formattedTime",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
