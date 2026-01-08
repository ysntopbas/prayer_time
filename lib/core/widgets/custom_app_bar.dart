import 'package:flutter/material.dart';
import 'package:prayer_time/core/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textWhite,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: actions,
      leading: leading,
      backgroundColor: AppTheme.prayerBackgroundColor,
      iconTheme: const IconThemeData(color: AppTheme.textWhite),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
