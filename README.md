# pjflashcard01

Đây là ứng dụng di động hỗ trợ học tập và ghi nhớ kiến thức (từ vựng ngoại ngữ, thuật ngữ IT, kiến thức tổng hợp) thông qua phương pháp thẻ ghi nhớ (Flashcards). Ứng dụng được thiết kế tối ưu trải nghiệm người dùng từ bản vẽ Figma, xây dựng trên nền tảng Flutter và hoạt động hoàn toàn offline với cơ sở dữ liệu SQLite cục bộ.

---

Tính Năng Nổi Bật

1. Quản Lý Bộ Thẻ (Decks) & Thẻ Ghi Nhớ (Cards)
- **Tạo & Phân loại bộ thẻ**: Dễ dàng tạo các bộ từ vựng theo chủ đề (tiếng Nhật JLPT, tiếng Anh giao tiếp, Thuật ngữ CNTT,...).
- **Soạn thảo linh hoạt**: Thêm, sửa, xóa thẻ với mặt trước (câu hỏi/từ mới), mặt sau (đáp án/nghĩa/ví dụ) và gợi ý (hint).
- **Tìm kiếm & Lọc**: Tìm kiếm nhanh bộ thẻ hoặc thẻ ghi nhớ theo từ khóa.

2. Chế Độ Học & Ôn Tập Linh Hoạt
- **Hiệu ứng Flip Card 3D**: Lật mặt thẻ mượt mà giúp tăng tính tương tác khi học.
- **Đánh giá mức độ ghi nhớ**: Chọn mức độ thuộc bài (Dễ / Trung bình / Khó / Chưa thuộc) để hệ thống điều phối lượt lặp.
- **Thuật toán Ôn tập ngắt quãng (Spaced Repetition)**: Ưu tiên xuất hiện lại các thẻ chưa thuộc hoặc thẻ đến hạn ôn tập.

3. Lưu Trữ Offline & Bảo Mật Dữ Liệu
- **Lưu trữ cục bộ SQLite**: Toàn bộ bộ thẻ, lịch sử học tập được lưu trực tiếp trên thiết bị, không cần kết nối Internet, truy xuất dữ liệu cực nhanh.
- **Độc lập & Riêng tư**: Không yêu cầu đăng nhập tài khoản, đảm bảo tính riêng tư hoàn toàn cho dữ liệu học tập.

4. Giao Diện Tối Ưu (Figma-Based UI)
- Trải nghiệm người dùng thân thiện, giao diện tinh gọn chuẩn Material Design 3 dựa trên bản thiết kế Figma.
- Hỗ trợ chế độ Sáng/Tối (Light/Dark Mode).

---

⚙️ Hướng Dẫn Cài Đặt & Chạy Ứng Dụng

Yêu Cầu Cần Thiết
- **Flutter SDK**: `>= 3.0.0`
- **Dart SDK**: `>= 3.0.0`
- **IDE**: Visual Studio Code hoặc Android Studio (đã cài Flutter & Dart plugin)
- **Thiết bị chạy**: Máy ảo Android/iOS Emulator hoặc Thiết bị thực (đã bật USB Debugging)

Các Bước Thực Hiện:

1. Clone dự án về máy:
   ```bash
   git clone https://github.com/Quan9Gnauq/flashcard-app.git
   cd flashcard-app
   ```

2. Cài đặt các gói phụ thuộc (Dependencies):
   ```bash
   flutter pub get
   ```

3. Kiểm tra thiết bị kết nối:
   ```bash
   flutter devices
   ```

4. Chạy ứng dụng:
   ```bash
   flutter run
   ```

---

🗺 Kế Hoạch Phát Triển (Roadmap)

- [x] Thiết kế UI/UX hoàn chỉnh trên Figma
- [x] Xây dựng khung giao diện Flutter & chuyển màn hình
- [x] Tích hợp cơ sở dữ liệu SQLite cục bộ (`sqflite`)
- [ ] Tích hợp tính năng phát âm chuẩn (Text-to-Speech)
- [ ] Thống kê tiến độ học tập trực quan qua biểu đồ (Charts)
- [ ] Hỗ trợ AI (LLM) tự động sinh Flashcard từ file tài liệu / hình ảnh
- [ ] Đồng bộ hóa & Sao lưu đám mây (Cloud Sync & Backup)

---

📝 Tác Giả & Bản Quyền

- Tác giả: Tô Thế Quang ([@Quan9Gnauq](https://github.com/Quan9Gnauq))
- Giấy phép: Dự án được phát hành dưới giấy phép [MIT License](LICENSE).
