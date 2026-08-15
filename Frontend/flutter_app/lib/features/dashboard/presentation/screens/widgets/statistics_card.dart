import 'package:flutter/material.dart';
import 'package:flutter_app/core/constants/app_spacing.dart';
import 'package:flutter_app/core/constants/app_text_styles.dart';


class StatisticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const StatisticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Icon(
                icon,
                color: iconColor,
                size: 28,
              ),

              SizedBox(height: AppSpacing.md),

              Text(
                title,
                style: AppTextStyles.caption,
              ),

              SizedBox(height: AppSpacing.sm),

              Text(
                value,
                style: AppTextStyles.title,
              ),
            ],
          ),
        ),
      ),
    );
  }
}