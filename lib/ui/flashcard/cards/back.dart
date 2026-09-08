import 'package:flutter/material.dart';
import '../../styles.dart';

class FlashcardBack extends StatelessWidget {
  const FlashcardBack({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Ý nghĩa:', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 12),
          const Text('Cách đọc:', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderGrey, width: 1.5),
                  color: AppColors.backgroundLight
              ),
              alignment: Alignment.center,
              child: const Text('hình ảnh minh họa'),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Ví dụ:', style: TextStyle(fontSize: 14)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
