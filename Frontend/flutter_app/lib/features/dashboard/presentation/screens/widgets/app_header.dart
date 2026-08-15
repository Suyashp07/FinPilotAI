import 'package:flutter/material.dart';
import 'package:flutter_app/features/profile/presentation/screen/profile_screen.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,

      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue.shade100,
            child: const Icon(
              Icons.account_balance,
              color: Colors.blue,
            ),
          ),

          const SizedBox(width: 12),

          const Text(
            "FinPilot AI",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );// Navigate to Profile Screen
            },
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE3F2FD),
              child: Icon(
                Icons.person,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}