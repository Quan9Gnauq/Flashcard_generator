# flashcard generator

This is a mobile application designed to facilitate learning and information retention (foreign language vocabulary, IT terminology, general knowledge) using the flashcard method. The app features a user experience optimized from Figma designs, is built on the Flutter framework, and operates entirely offline using a local SQLite database.
---

Key Features

1. Deck & Card Management
- Deck Creation & Categorization: Easily create topic-based decks (e.g., JLPT Japanese, conversational English, IT terminology).
- Flexible Editing: Add, edit, and delete cards featuring a front side (question/new word), back side (answer/meaning/example), and hints.
- Search & Filter: Quickly search for decks or specific cards using keywords.

2. Flexible Study & Review Modes
- 3D Flip Card Effect: Smooth card-flipping animations enhance interactivity during study sessions.
- Retention Assessment: Rate your mastery level (Easy / Medium / Hard / Not Yet Learned) to help the system schedule future repetitions.
- Spaced Repetition Algorithm: Prioritizes the reappearance of cards that are not yet mastered or are due for review.

3. Lưu Trữ Offline & Bảo Mật Dữ Liệu
- **Lưu trữ cục bộ SQLite**: Toàn bộ bộ thẻ, lịch sử học tập được lưu trực tiếp trên thiết bị, không cần kết nối Internet, truy xuất dữ liệu cực nhanh.
- **Độc lập & Riêng tư**: Không yêu cầu đăng nhập tài khoản, đảm bảo tính riêng tư hoàn toàn cho dữ liệu học tập.
3. Offline Storage & Data Security**
- Local SQLite Storage: All decks and study history are stored directly on the device; no internet connection is required, ensuring rapid data retrieval.
- Independence & Privacy: No account login required, ensuring complete privacy for your study data.

4. Optimized Interface (Figma-Based UI)
- User-friendly experience with a streamlined interface adhering to Material Design 3 standards, based on Figma designs.
- Supports Light and Dark modes.

---

🗺 Development Roadmap

- [x] Complete UI/UX design on Figma
- [x] Build Flutter UI framework & screen navigation
- [x] Integrate local SQLite databaseộ (`sqflite`)
- [ ] Integrate Text-to-Speech (TTS) for accurate pronunciation
- [ ] Visualize learning progress via charts
- [ ] flashcard generation from documents/images
- [ ] Cloud Sync & Backup

---

📝 Author & License

- Author: Quan9Gnauq
- License: This project is released under the MIT License.
