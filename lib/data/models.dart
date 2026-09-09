class Deck {
  final int? id;
  final String title;
  final String description;

  Deck({this.id, required this.title, required this.description});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'description': description};
  }
}

class Vocab {
  final int? id;
  final int deckId;
  final String frontText;
  final String meaning;
  final String? reading;
  final String? example;
  final String? imagePath;
  int status; // Thêm trường trạng thái: 0 (Mặc định), 1 (Đã học), 2 (Chưa nhớ), 3 (Đã nhớ)

  Vocab({
    this.id,
    required this.deckId,
    required this.frontText,
    required this.meaning,
    this.reading,
    this.example,
    this.imagePath,
    this.status = 0, // Mặc định là 0 khi vừa tạo
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deckId': deckId,
      'frontText': frontText,
      'meaning': meaning,
      'reading': reading,
      'example': example,
      'imagePath': imagePath,
      'status': status, // Lưu vào Map
    };
  }
}