import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import '../../data/database_helper.dart';
import '../../data/models.dart';
import '../styles.dart';

class FlashcardsScreen extends StatefulWidget {
  final Deck deck;

  const FlashcardsScreen({Key? key, required this.deck}) : super(key: key);

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  final FlutterTts flutterTts = FlutterTts();
  bool isFlipped = false;
  List<Vocab> _activeVocabs = [];
  List<Vocab> _memorizedVocabs = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  Future<void> _loadVocabs() async {
    final vocabs = await DatabaseHelper.instance.getVocabsByDeckId(widget.deck.id!);
    setState(() {
      // Tách làm 2 danh sách dựa vào status
      _activeVocabs = vocabs.where((v) => v.status != 3).toList();
      _memorizedVocabs = vocabs.where((v) => v.status == 3).toList();

      if (_currentIndex >= _activeVocabs.length) {
        _currentIndex = 0;
      }
      _isLoading = false;
    });
  }

  void toggleFlip() {
    setState(() {
      isFlipped = !isFlipped;
    });
  }

  // Hàm xử lý khi nhấn các nút đánh giá
  Future<void> _markCard(int status) async {
    if (_activeVocabs.isEmpty) return;

    final currentVocab = _activeVocabs[_currentIndex];

    // Lưu vào database
    await DatabaseHelper.instance.updateVocabStatus(currentVocab.id!, status);

    setState(() {
      isFlipped = false; // Lật lại mặt trước cho thẻ tiếp theo

      if (status == 3) {
        // Nếu chọn "Quá dễ" (Đã nhớ) -> Xóa khỏi danh sách học, chuyển sang Đã nhớ
        currentVocab.status = 3;
        _memorizedVocabs.add(currentVocab);
        _activeVocabs.removeAt(_currentIndex);

        if (_currentIndex >= _activeVocabs.length) {
          _currentIndex = 0;
        }
      } else {
        // Nếu "Chưa nhớ" hoặc "Đã học" -> Đổi status, qua thẻ tiếp theo
        currentVocab.status = status;
        if (_currentIndex < _activeVocabs.length - 1) {
          _currentIndex++;
        } else {
          _currentIndex = 0; // Quay vòng lại từ đầu nếu đến thẻ cuối
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadVocabs();
    _initTts();
  }

  // Hàm cấu hình giọng đọc
  Future<void> _initTts() async {
    await flutterTts.setLanguage("ja-JP");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
  }

  // Hàm phát âm
  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  // Tắt máy đọc khi thoát màn hình để giải phóng bộ nhớ
  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar(widget.deck.title, showBackButton: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(36.0),
        child: Column(
          children: [
            // Thanh thống kê tiến độ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatBadge(
                    'Đang học\n${_activeVocabs.isEmpty ? 0 : _currentIndex + 1}/${_activeVocabs.length}',
                    color: Colors.white
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MemorizedScreen(memorizedVocabs: _memorizedVocabs),
                      ),
                    ).then((_) => _loadVocabs());
                  },
                  child: _buildStatBadge(
                      'Đã nhớ\n${_memorizedVocabs.length}',
                      color: Colors.green[100]
                  ),
                ),
              ],
            ),
            const SizedBox(height: 72),

            Expanded(
              child: _activeVocabs.isEmpty
                  ? const Center(child: Text('Chúc mừng! Bạn đã hoàn thành bộ thẻ này.', style: TextStyle(fontSize: 18)))
                  : GestureDetector(
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
                      ? _buildFace(isFront: false, vocab: _activeVocabs[_currentIndex])
                      : _buildFace(isFront: true, vocab: _activeVocabs[_currentIndex]),
                ),
              ),
            ),
            const SizedBox(height: 72),

            // Các nút đánh giá
            if (_activeVocabs.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(onTap: () => _markCard(2), child: _buildActionButton('Chưa nhớ', Colors.red[100])),
                  GestureDetector(onTap: () => _markCard(3), child: _buildActionButton('Quá dễ', Colors.amber[100])),
                  GestureDetector(onTap: () => _markCard(1), child: _buildActionButton('Đã học', Colors.green[100])),
                ],
              ),
            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }

  Widget _buildFace({required bool isFront, required Vocab vocab}) {
    return Stack(
      key: ValueKey(isFront),
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: const Color(0xFFE2E2E2), borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(20),
          child: isFront
              ? Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                  //border: Border.all(color: Colors.grey, width: 1.5),
                  color: const Color(0xFFE2E2E2)
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                        vocab.frontText,
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.blue, size: 28),
                      onPressed: () {
                        // Chặn sự kiện lật thẻ, chỉ gọi hàm đọc
                        _speak(vocab.frontText);
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vocab.reading != null && vocab.reading!.isNotEmpty) ...[
                Text('Cách đọc: ${vocab.reading}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
              ],
              Text('Ý nghĩa: ${vocab.meaning}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (vocab.example != null && vocab.example!.isNotEmpty) ...[
                Text('Ví dụ: ${vocab.example}', style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration:
                  BoxDecoration(
                      //border: Border.all(color: Colors.grey, width: 1.5),
                      color: const Color(0xFFE2E2E2)),
                  alignment: Alignment.center,
                  child: vocab.imagePath != null && vocab.imagePath!.isNotEmpty
                      ? Image.file(File(vocab.imagePath!), fit: BoxFit.contain)
                      : const Text('chưa có ảnh minh họa'),
                ),
              ),
            ],
          ),
        ),

        Positioned(
          top: 10,
          right: 10,
          child: _buildStatusIcon(vocab.status),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(int status) {
    if (status == 1) return const Icon(Icons.check_circle, color: Colors.green, size: 32);
    if (status == 2) return const Icon(Icons.cancel, color: Colors.red, size: 32);
    return const SizedBox.shrink(); // status = 0 (Chưa học) thì không hiện gì
  }

  Widget _buildStatBadge(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
          color: color ?? const Color(0xFFE2E2E2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey)
      ),
      child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionButton(String text, Color? bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
          color: bgColor ?? const Color(0xFFE2E2E2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey)
      ),
      child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }
}

class MemorizedScreen extends StatelessWidget {
  final List<Vocab> memorizedVocabs;

  const MemorizedScreen({Key? key, required this.memorizedVocabs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar('TỪ ĐÃ NHỚ', showBackButton: true),
      body: memorizedVocabs.isEmpty
          ? const Center(child: Text('Bạn chưa có từ nào trong danh sách Đã nhớ.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: memorizedVocabs.length,
        itemBuilder: (context, index) {
          final vocab = memorizedVocabs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.star, color: Colors.amber, size: 32),
              title: Text(vocab.frontText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(vocab.meaning),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          );
        },
      ),
    );
  }
}