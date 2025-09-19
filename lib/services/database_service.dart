import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class DatabaseService {
  static final _firestore = FirebaseFirestore.instance;

  /// Lấy collection transactions theo userId
  static CollectionReference<Map<String, dynamic>> _collection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("❌ User chưa đăng nhập");
    return _firestore.collection('users').doc(user.uid).collection('transactions');
  }

  /// Thêm giao dịch
  static Future<void> insertTransaction(TransactionModel transaction) async {
    await _collection().add({
      'senderName': transaction.senderName,
      'accountNumber': transaction.accountNumber,
      'bankName': transaction.bankName,
      'amount': transaction.amount,
      'time': Timestamp.fromDate(transaction.time),
    });
  }

  /// Lấy tất cả giao dịch
  static Future<List<TransactionModel>> getAllTransactions() async {
    final snapshot = await _collection().orderBy('time', descending: true).get();
    return snapshot.docs.map(TransactionModel.fromFirestore).toList();
  }

  /// Lắng nghe giao dịch realtime
  static Stream<List<TransactionModel>> listenTransactions() {
    return _collection()
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map(TransactionModel.fromFirestore).toList());
  }
}
