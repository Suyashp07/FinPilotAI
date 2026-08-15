import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/category_provider.dart';

class CategoryChip extends ConsumerWidget {
  final String title;

  const CategoryChip({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(categoryProvider);

    final isSelected = selectedCategory == title;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(title),
        selected: isSelected,

        selectedColor: Colors.blue,

        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.w600,
        ),

        onSelected: (_) {
          ref.read(categoryProvider.notifier).state = title;
        },
      ),
    );
  }
}