import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:month_year_picker/month_year_picker.dart';

// import các màn hình auth + layout
import 'features/auth/login_screen.dart';
import 'layout/main_layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔔 Khởi tạo Local Notifications
  await NotificationService.initialize();

  // ✅ Xin quyền hiển thị thông báo (Android 13+)
  await Permission.notification.request();

  runApp(const BankingNotifierApp());
}

class BankingNotifierApp extends StatelessWidget {
  const BankingNotifierApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Banking Notifier',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        MonthYearPickerLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ],
      // ✅ dùng StreamBuilder để lắng nghe trạng thái đăng nhập
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            // ✅ Đã đăng nhập → vào MainLayout (có TransactionNotifierScreen + History + Stats)
            return const MainLayout();
          } else {
            // ❌ Chưa đăng nhập → vào Login
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
