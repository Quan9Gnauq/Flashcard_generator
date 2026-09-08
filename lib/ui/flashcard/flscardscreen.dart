import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:math';
import '../../data/database_helper.dart';
import '../../data/models.dart';
import '../styles.dart';
import 'cards/front.dart';
import 'cards/back.dart';

class FlashcardsScreen extends StatefulWidget {
  final Deck deck; // Nhận bộ từ được chọn

  const FlashcardsScreen({Key? key, required this.deck}) : super(key: key);

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  bool isFlipped = false;
  List<Vocab> _vocabs = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVocabs();
  }

  // Tải các thẻ thuộc về bộ từ này
  Future<void> _loadVocabs() async {
    final vocabs = await DatabaseHelper.instance.getVocabsByDeckId(widget.deck.id!);
    setState(() {
      _vocabs = vocabs;
      _isLoading = false;
    });
  }

  void toggleFlip() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  void _nextCard() {
    if (_currentIndex < _vocabs.length - 1) {
      setState(() {
        _currentIndex++;
        isFlipped = false; // Reset lại mặt trước khi qua thẻ mới
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(widget.deck.title, showBackButton: true), // Hiển thị tên bộ từ trên AppBar
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vocabs.isEmpty
          ? const Center(child: Text('Bộ từ này chưa có thẻ nào.'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Thống kê tiến độ học (Tạm thời là số lượng thẻ)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBadge('thẻ\n${_currentIndex + 1}/${_vocabs.length}'),
              ],
            ),
            const SizedBox(height: 20),

            // Vùng hiển thị Flashcard
            Expanded(
              child: GestureDetector(
                onTap: toggleFlip,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
                    return AnimatedBuilder(
                      animation: rotateAnim,
                      child: child,
                      builder: (context, widget) {
                        final isUnder = (ValueKey(isFlipped) != widget!.key);
                        var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                        tilt *= isUnder ? -1.0 : 1.0;
                        final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
                        return Transform(
                          transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                          alignment: Alignment.center,
                          child: widget,
                        );
                      },
                    );
                  },
                  child: isFlipped
                      ? _buildBackFace(key: const ValueKey(true), vocab: _vocabs[_currentIndex])
                      : _buildFrontFace(key: const ValueKey(false), vocab: _vocabs[_currentIndex]),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Các nút đánh giá
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(onTap: _nextCard, child: _buildActionButton('chưa nhớ')),
                GestureDetector(onTap: _nextCard, child: _buildActionButton('Quá dễ')),
                GestureDetector(onTap: _nextCard, child: _buildActionButton('đã học')),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Mặt trước
  Widget _buildFrontFace({required Key key, required Vocab vocab}) {
    return Container(
      key: key,
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.cardGrey, borderRadius: BorderRadius.circular(12)),
      child: Center(
        child: Container(
          width: 200,
          height: 120,
          decoration: BoxDecoration(border: Border.all(color: AppColors.borderGrey, width: 1.5), color: AppColors.backgroundLight),
          alignment: Alignment.center,
          // Lấy dữ liệu frontText từ DB
          child: Text(vocab.frontText, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ),
      ),
    );
  }

  // Mặt sau
  // Mặt sau của thẻ Flashcard
  Widget _buildBackFace({required Key key, required Vocab vocab}) {
    return Container(
      key: key,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hiển thị Cách đọc (nếu có)
          if (vocab.reading != null && vocab.reading!.isNotEmpty) ...[
            Text(
              'Cách đọc: ${vocab.reading}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
          ],

          // Hiển thị Ý nghĩa
          Text(
            'Ý nghĩa: ${vocab.meaning}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Hiển thị Ví dụ (nếu có)
          if (vocab.example != null && vocab.example!.isNotEmpty) ...[
            Text(
              'Ví dụ: ${vocab.example}',
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black87),
            ),
            const SizedBox(height: 12),
          ],

          // Khung hiển thị Ảnh minh họa
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderGrey, width: 1.5),
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: vocab.imagePath != null && vocab.imagePath!.isNotEmpty
                  ? Image.file(File(vocab.imagePath!), fit: BoxFit.contain)
                  : const Text('chưa có ảnh minh họa'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(color: AppColors.cardGrey, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderGrey)),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
    );
  }

  Widget _buildActionButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(color: AppColors.cardGrey, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderGrey)),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}
