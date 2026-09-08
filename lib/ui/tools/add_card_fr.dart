import 'package:flutter/material.dart';
import '../styles.dart';
import '../../main.dart'; // Import AppColors
import 'add_card_ba.dart'; // Import màn hình mặt sau

class AddVocabFrontScreen extends StatefulWidget {
  final int deckId; // Nhận ID của bộ từ để biết thêm từ vào đâu

  const AddVocabFrontScreen({Key? key, required this.deckId}) : super(key: key);

  @override
  State<AddVocabFrontScreen> createState() => _AddVocabFrontScreenState();
}

class _AddVocabFrontScreenState extends State<AddVocabFrontScreen> {
  final TextEditingController _frontController = TextEditingController();

  @override
  void dispose() {
    _frontController.dispose();
    super.dispose();
  }

  // Chuyển sang màn hình mặt sau
  void _goToBackScreen() {
    final frontText = _frontController.text.trim();

    if (frontText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập từ hoặc cụm từ!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Điều hướng sang màn hình Mặt sau và mang theo frontText
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddVocabBackScreen(
          deckId: widget.deckId,
          frontText: frontText,
        ),
      ),
    );
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(child: Text('Mặt trước', style: TextStyle(fontSize: 16))),
                        const SizedBox(height: 16),
                        _buildInputField('Từ hoặc cụm từ (VD: 漢字, Apple...)', controller: _frontController),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderGrey, width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Âm thanh', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSoundButton('Ghi âm'),
                          _buildSoundButton('Tải lên'),
                        ],
                      )
                    ],
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

  Widget _buildSoundButton(String text) {
    return OutlinedButton(
      onPressed: () {}, // Xử lý âm thanh sau
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: const BorderSide(color: Colors.black, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black)),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _goToBackScreen, // Chuyển sang màn hình sau
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
            onPressed: () => Navigator.pop(context),
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