import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  static const String _geminiApiKey = 'YOUR_API_KEY';
  static const String _pixabayApiKey = 'YOUR_API_KEY';

  static Future<List<Map<String, dynamic>>> generateBatchVocabData(List<String> words) async {
    final model = GenerativeModel(
      model: 'gemini-3.8-flash',
      apiKey: _geminiApiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.2,),
    );

    final prompt = '''
    Phân tích danh sách các từ vựng sau: ${words.join(', ')}.
    Với MỖI từ vựng, tạo một đối tượng gồm các trường:
    - "word": từ gốc
    - "meaning": ý nghĩa ngắn gọn bằng tiếng Việt
    - "reading": cách đọc (Hiragana/Romaji nếu là tiếng Nhật, IPA/phát âm nếu ngôn ngữ khác)
    - "example": 1 câu ví dụ ngắn kèm dịch nghĩa tiếng Việt
    - "search_keyword": từ khóa tiếng Anh ngắn đại diện cho từ đó để tìm ảnh

    Trả về danh sách các đối tượng dưới dạng một JSON Array.
    ''';

    final response = await model.generateContent([Content.text(prompt)]);

    if (response.text == null || response.text!.isEmpty) {
      throw Exception("AI không trả về dữ liệu.");
    }

    final List<dynamic> jsonList = jsonDecode(response.text!);
    List<Map<String, dynamic>> results = [];

    // 3. Tải ảnh từ Pixabay cho từng từ
    for (var item in jsonList) {
      Map<String, dynamic> vocabMap = Map<String, dynamic>.from(item);
      String? imagePath;

      try {
        final keyword = vocabMap['search_keyword'] ?? vocabMap['word'];
        final imageRes = await http.get(Uri.parse(
            'https://pixabay.com/api/?key=$_pixabayApiKey&q=${Uri.encodeComponent(keyword)}&image_type=photo&per_page=3'));
        final imageData = jsonDecode(imageRes.body);

        if (imageData['hits'] != null && imageData['hits'].isNotEmpty) {
          final imageUrl = imageData['hits'][0]['webformatURL'];
          final imageResponse = await http.get(Uri.parse(imageUrl));
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/ai_vocab_${DateTime.now().microsecondsSinceEpoch}.jpg');
          await file.writeAsBytes(imageResponse.bodyBytes);
          imagePath = file.path;
        }
      } catch (e) {
        print("Lỗi tải ảnh: $e");
      }

      vocabMap['imagePath'] = imagePath;
      results.add(vocabMap);
    }

    return results;
  }
}