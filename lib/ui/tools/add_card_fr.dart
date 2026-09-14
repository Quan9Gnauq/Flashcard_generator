import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../data/models.dart';
import '../styles.dart';
import 'add_card_ba.dart';
import 'ai_service.dart';

class AddVocabFrontScreen extends StatefulWidget {
  final int deckId;

  const AddVocabFrontScreen({Key? key, required this.deckId}) : super(key: key);

  @override
  State<AddVocabFrontScreen> createState() => _AddVocabFrontScreenState();
}

class _AddVocabFrontScreenState extends State<AddVocabFrontScreen> {
  final TextEditingController _frontController = TextEditingController();
  bool _isLoadingAI = false;
  String _statusText = '';

  Future<void> _generateMultipleVocabsWithAI() async {
    final rawInput = _frontController.text.trim();

    if (rawInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập từ vựng!'), backgroundColor: Colors.red),
      );
      return;
    }

    // Tách chuỗi theo dấu phẩy thường (,), dấu phẩy tiếng Nhật (、) hoặc dấu xuống dòng (\n)
    final List<String> wordList = rawInput
        .split(RegExp(r'[,、\n\r]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (wordList.isEmpty) return;

    setState(() {
      _isLoadingAI = true;
      _statusText = 'AI đang phân tích ${wordList.length} từ...';
    });
    try {
      final List<Map<String, dynamic>> aiResults = await AIService.generateBatchVocabData(wordList);
      setState(() {
        _statusText = 'Đang lưu vào danh sách...';
      });
      for (var data in aiResults) {
        final newVocab = Vocab(
          deckId: widget.deckId,
          frontText: data['word'] ?? '',
          meaning: data['meaning'] ?? '',
          reading: data['reading'] ?? '',
          example: data['example'] ?? '',
          imagePath: data['imagePath'],
          status: 0,
        );
        await DatabaseHelper.instance.insertVocab(newVocab);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tạo thành công ${aiResults.length} thẻ từ vựng!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tạo hàng loạt: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAI = false;
          _statusText = '';
        });
      }
    }
  }

  @override
  void dispose() {
    _frontController.dispose();
    super.dispose();
  }

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
                        const SizedBox(height: 20),
                        const Center(child: Text('Mặt trước', style: TextStyle(fontSize: 16))),
                        const SizedBox(height: 36),
                        _buildInputField('Từ hoặc cụm từ (VD: 漢字, Apple...)', controller: _frontController),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderGrey, width: 1.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Âm thanh', style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 24),
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
                ElevatedButton.icon(
                  icon: _isLoadingAI
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isLoadingAI ? _statusText : 'Tự động tạo bằng AI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: _isLoadingAI ? null : _generateMultipleVocabsWithAI,
                )
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
        maxLines: 10,
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
      onPressed: () {},
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
            onPressed: _goToBackScreen,
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