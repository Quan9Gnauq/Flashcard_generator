import 'package:flutter/material.dart';
import '../../styles.dart';

class FlashcardFront extends StatelessWidget {
  const FlashcardFront({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Container(
          width: 240,
          height: 120,
          decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderGrey, width: 1.5),
              color: AppColors.backgroundLight
          ),
          alignment: Alignment.center,
          child: const Text('Từ vựng/ cụm từ', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
