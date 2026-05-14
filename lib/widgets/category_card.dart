import 'package:flutter/material.dart';
import '../data/categories.dart';
import '../theme/app_theme.dart';

class CategoryCard extends StatelessWidget {
  final CategoryItem item;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFCCFBF1),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            item.icon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
        subtitle: Text(
          item.subtitle,
          style: const TextStyle(
            color: AppColors.muted,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: AppColors.muted,
        ),
      ),
    );
  }
}