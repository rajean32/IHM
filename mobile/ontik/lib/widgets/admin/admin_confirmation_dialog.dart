import 'package:flutter/material.dart';
import '../../core/assets/app_colors.dart';
import '../../generated/app_localizations.dart';

class AdminConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final Color? confirmColor;
  final VoidCallback onConfirm;

  const AdminConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.confirmColor,
    required this.onConfirm,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelLabel ?? AppLocalizations.of(context)!.widgetsCrudCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel ?? AppLocalizations.of(context)!.widgetsCrudDelete,
              style: TextStyle(color: confirmColor ?? AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel ?? AppLocalizations.of(context)!.widgetsCrudCancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
            onConfirm();
          },
          child: Text(
            confirmLabel ?? AppLocalizations.of(context)!.widgetsCrudDelete,
            style: TextStyle(color: confirmColor ?? AppColors.error),
          ),
        ),
      ],
    );
  }
}
