# 💰 Voice Banking 

Ứng dụng Flutter giúp quản lý và thông báo giao dịch ngân hàng theo thời gian thực.  
Dự án được xây dựng trong quá trình học tập & thực hành Flutter kết hợp với SQLite và Firebase.

---

## ✨ Tính năng chính

- 📩 **Thông báo giao dịch**:  
  - Hiện thông báo khi có giao dịch mới (local notification).  
  - Đọc nội dung giao dịch bằng giọng nói (Text-to-Speech).

- 📜 **Lịch sử giao dịch**:  
  - Hiển thị danh sách các giao dịch với đầy đủ thông tin:  
    `senderName`, `accountNumber`, `bankName`, `amount`, `time`.  
  - Sắp xếp từ **mới nhất → cũ nhất**.

- 📊 **Thống kê giao dịch**:  
  - Biểu đồ cột dọc (bar chart) quản lý chi tiêu hàng tháng.  
  - StatCard gộp **số giao dịch** và **tổng tiền**.

- 📄 **Xuất báo cáo PDF**:  
  - Xuất danh sách giao dịch theo tháng.  
  - Mở trực tiếp file PDF trên điện thoại.

- 🔐 **Đăng nhập / Đăng xuất (Firebase Auth)**:  
  - Đăng nhập bằng Email/Password.  
  - Mỗi user có dữ liệu riêng trong Firestore.  
  - Trên màn hình chính hiển thị logo tài khoản, bấm vào có menu **Đăng xuất**.

---

## 🛠️ Công nghệ sử dụng

- **Flutter** (UI, State Management đơn giản với StatefulWidget).  
- **Firebase**:  
  - Authentication (đăng nhập, đăng xuất).  
  - Firestore (lưu trữ giao dịch).  
  - Cloud Messaging (chuẩn bị cho push notification).  
- **SQLite** (lưu trữ cục bộ khi offline).  
- **Packages Flutter**:  
  - `flutter_local_notifications` → thông báo cục bộ.  
  - `flutter_tts` → đọc thông báo bằng giọng nói.  
  - `sqflite`, `path_provider` → cơ sở dữ liệu cục bộ.  
  - `fl_chart` → biểu đồ thống kê.  
  - `pdf`, `open_file` → xuất & mở file PDF.  
  - `shared_preferences` → lưu cache cục bộ.

---

## 📱 Giao diện

- **TransactionNotifierScreen**: Hiện thông báo mới, đọc giọng nói.  
- **TransactionHistoryScreen**: Lịch sử giao dịch.  
- **TransactionStatsScreen**: Thống kê chi tiêu.  
- **LoginScreen / HomeScreen**: Đăng nhập & menu tài khoản.  

---

## 🚀 Cách chạy dự án

1. Clone project:
   ```bash
   git clone https://github.com/<username>/<repo_name>.git
   cd <repo_name>

