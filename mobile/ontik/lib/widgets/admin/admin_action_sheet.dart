import 'package:flutter/material.dart';
import '../../core/assets/app_colors.dart';

class AdminActionItem {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  const AdminActionItem({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });
}

class AdminActionSheet extends StatelessWidget {
  final String title;
  final List<AdminActionItem> actions;

  const AdminActionSheet({
    super.key,
    required this.title,
    required this.actions,
  });

  static Future<void> show(BuildContext context, {required String title, required List<AdminActionItem> actions}) {
    return showModalBottomSheet(
      context: context,
      builder: (ctx) => AdminActionSheet(title: title, actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...actions.map((action) => ListTile(
              leading: Icon(action.icon, color: action.color ?? AppColors.textPrimary),
              title: Text(
                action.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: action.color ?? AppColors.textPrimary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                action.onTap?.call();
              },
            )),
          ],
        ),
      ),
    );
  }
}
