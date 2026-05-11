import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PawLogo extends StatelessWidget {
  const PawLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        children: [
          Text('🐾', style: TextStyle(fontSize: 40)),
          SizedBox(height: 8),
          Text(
            'PawConnect',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }
}
