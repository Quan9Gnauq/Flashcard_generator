import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../main.dart'; // Import file chứa định nghĩa AppColors
import '../../data/models.dart'; // Import model Deck
import '../../data/database_helper.dart';
import '../styles.dart';
import 'add_card_fr.dart'; // Import class xử lý Database

class CreateDeckScreen extends StatefulWidget {
  const CreateDeckScreen({Key? key}) : super(key: key);

  @override
  State<CreateDeckScreen> createState() => _CreateDeckScreenState();
}

class _CreateDeckScreenState extends State<CreateDeckScreen> {
  // 1. Khai báo các controller để quản lý nội dung nhập liệu
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    // 2. Luôn nhớ dọn dẹp controller khi màn hình bị hủy để tránh rò rỉ bộ nhớ
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // 3. Hàm xử lý logic khi bấm nút OK
  Future<void> _saveDeck() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập Chủ đề!'), backgroundColor: Colors.red));
      return;
    }

    final newDeck = Deck(title: title, description: description);

    try {
      // Lưu và nhận về ID của bộ từ vừa tạo
      int newDeckId = await DatabaseHelper.instance.insertDeck(newDeck);

      if (mounted) {
        // Thay vì Navigator.pop, ta dùng pushReplacement để chuyển thẳng sang AddVocabFrontScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AddVocabFrontScreen(deckId: newDeckId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGrey, width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Tạo bộ từ mới',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),

                // Khối nhập liệu chính
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderGrey, width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Gắn _titleController vào input Chủ đề
                        _buildInputField('Chủ đề', controller: _titleController, flex: 1),
                        const SizedBox(height: 16),
                        // Gắn _descController vào input Mô tả
                        _buildInputField('Mô tả', controller: _descController, flex: 1),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Nút OK - HỦY
                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Cập nhật hàm này để nhận thêm tham số TextEditingController
  Widget _buildInputField(String hint, {required TextEditingController controller, int flex = 1}) {
    return Expanded(
      flex: flex,
      child: TextField(
        controller: controller, // Nhận dữ liệu text từ người dùng
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.cardGrey,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.borderGrey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _saveDeck, // Gắn hàm lưu dữ liệu vào nút OK
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.borderGrey, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('OK', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context), // Hủy và đóng màn hình
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppColors.borderGrey, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('HỦY', style: TextStyle(color: AppColors.cancelRed, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}