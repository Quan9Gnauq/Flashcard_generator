import 'package:flutter/material.dart';
import '../../data/database_helper.dart';
import '../../data/models.dart';
import '../styles.dart';
import '../flashcard/flscardscreen.dart';
import '../tools/add_deck.dart';
import '../tools/add_card_fr.dart';

class DecksScreen extends StatefulWidget {
  const DecksScreen({Key? key}) : super(key: key);

  @override
  State<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends State<DecksScreen> {
  List<Deck> _decks = [];

  @override
  void initState() {
    super.initState();
    _loadDecks();
  }

  void _showDeleteConfirmation(int deckId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: const Text('Bạn có chắc chắn muốn xóa bộ từ này không? Tất cả từ vựng bên trong cũng sẽ bị xóa.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Hủy
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Đóng hộp thoại
                await DatabaseHelper.instance.deleteDeck(deckId); // Xóa khỏi DB
                _loadDecks();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa bộ từ!'), backgroundColor: Colors.green),
                );
              },
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadDecks() async {
    final decks = await DatabaseHelper.instance.getAllDecks();
    setState(() {
      _decks = decks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCustomAppBar('BỘ TỪ'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Khu vực Thêm bộ từ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.cardGrey, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  const Text('Thêm bộ từ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreateDeckScreen()),
                      );
                      _loadDecks();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 1.5), borderRadius: BorderRadius.circular(12)),
                      child: const Center(child: Icon(Icons.add_circle_outline, size: 30)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('hiển thị bộ từ đã tạo:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            Expanded(
              child: _decks.isEmpty
                  ? const Center(child: Text('Chưa có bộ từ nào. Hãy tạo mới!'))
                  : ListView.builder(
                itemCount: _decks.length,
                itemBuilder: (context, index) {
                  final deck = _decks[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlashcardsScreen(deck: deck),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E2E2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 48), // Tạo khoảng trống để đẩy Title ra giữa
                            Expanded(
                              child: Text(
                                deck.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.black54),
                              onSelected: (value) async {
                                if (value == 'add_vocab') {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddVocabFrontScreen(deckId: deck.id!),
                                    ),
                                  );
                                } else if (value == 'delete_deck') {
                                  _showDeleteConfirmation(deck.id!);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem(
                                  value: 'add_vocab',
                                  child: Row(
                                    children: [
                                      Icon(Icons.add_box, color: Colors.blue),
                                      SizedBox(width: 10),
                                      Text('Thêm từ vựng'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete_deck',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 10),
                                      Text('Xóa bộ từ', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
