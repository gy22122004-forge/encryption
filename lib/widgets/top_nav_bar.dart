import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../responsive.dart';

class TopNavBar extends StatelessWidget {
  final bool isLogin;

  const TopNavBar({
    super.key,
    this.isLogin = true,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 40,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              // 'Working logo' - returns user to the initial route
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              'Patrol',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (Responsive.isMobile(context))
            IconButton(
              icon: const Icon(Icons.menu, color: AppColors.black),
              onPressed: () {},
            )
          else
            Row(
              children: [
                _navItem('Home'),
                const SizedBox(width: 20),
                _navItem('About'),
                const SizedBox(width: 20),
                _navItem('Services'),
                const SizedBox(width: 20),
                _navItem('Contact'),
                const SizedBox(width: 20),
                OutlinedButton(
                  onPressed: () {
                    if (!isLogin) {
                      Navigator.pop(context);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.black,
                    side: const BorderSide(color: AppColors.black),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Login'),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _navItem(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
