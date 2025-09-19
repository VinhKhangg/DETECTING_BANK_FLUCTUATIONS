import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String senderName;
  final String accountNumber;
  final String bankName;
  final double amount;
  final DateTime time;

  TransactionModel({
    required this.senderName,
    required this.accountNumber,
    required this.bankName,
    required this.amount,
    required this.time,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timeField = data['time'];

    return TransactionModel(
      senderName: data['senderName'] ?? '',
      accountNumber: data['accountNumber'] ?? '',
      bankName: data['bankName'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      time: timeField is Timestamp ? timeField.toDate() : DateTime.parse(timeField),
    );
  }
}
