import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../styles.dart';
import '../../main.dart';
import '../../data/models.dart';
import '../../data/database_helper.dart';

class AddVocabBackScreen extends StatefulWidget {
  final int deckId;
  final String frontText;

  const AddVocabBackScreen({
    Key? key,
    required this.deckId,
    required this.frontText
  }) : super(key: key);

  @override
  State<AddVocabBackScreen> createState() => _AddVocabBackScreenState();
}

class _AddVocabBackScreenState extends State<AddVocabBackScreen> {
  final TextEditingController _meaningController = TextEditingController();
  final TextEditingController _readingController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();

  File? _selectedImage;

  @override
  void dispose() {
    _meaningController.dispose();
    _readingController.dispose();
    _exampleController.dispose();
    super.dispose();
  }

  // Hàm gọi thư viện chọn ảnh
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // Có thể đổi thành ImageSource.camera để chụp ảnh

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // Lưu đường dẫn ảnh
      });
    }
  }

  // Lưu từ vựng vào Database
  Future<void> _saveVocab() async {
    final meaning = _meaningController.text.trim();

    // Nếu bạn nâng cấp database, có thể lấy thêm data từ _readingController và _exampleController ở đây

    if (meaning.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập ý nghĩa của từ!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newVocab = Vocab(
      deckId: widget.deckId,
      frontText: widget.frontText,
      meaning: meaning,
      reading: _readingController.text.trim(),
      example: _exampleController.text.trim(),
      imagePath: _selectedImage?.path,
    );

    try {
      await DatabaseHelper.instance.insertVocab(newVocab);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thêm từ vựng thành công!'), backgroundColor: Colors.green),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
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
                  'Thêm từ vựng',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderGrey, width: 1.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text('Mặt sau', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        _buildInputField('Ý nghĩa', controller: _meaningController),
                        const SizedBox(height: 12),
                        _buildInputField('Cách đọc (Onyomi, Kunyomi...)', controller: _readingController),
                        const SizedBox(height: 12),
                        _buildInputField('Ví dụ:', controller: _exampleController),
                        const SizedBox(height: 16),

                        GestureDetector(
                          onTap: _pickImage, // Gọi hàm chọn ảnh khi bấm vào
                          child: Container(
                            width: double.infinity, // Cho khung ảnh rộng ra
                            height: 120,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              color: Colors.grey[200], // Sửa AppColors.cardGrey thành màu của bạn
                            ),
                            child: _selectedImage != null
                                ? Image.file(_selectedImage!, fit: BoxFit.contain) // Nếu đã chọn ảnh thì hiển thị ảnh
                                : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40),
                                SizedBox(height: 8),
                                Text('Tải ảnh lên', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildActionButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String hint, {required TextEditingController controller}) {
    return Expanded(
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.cardGrey,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
            onPressed: _saveVocab, // Thực thi lưu dữ liệu
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
            onPressed: () => Navigator.pop(context), // Hủy và quay lại mặt trước
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