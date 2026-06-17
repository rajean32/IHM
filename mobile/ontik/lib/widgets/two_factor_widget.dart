import 'package:flutter/material.dart';
import '../core/assets/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/utils/error_helper.dart';
import '../generated/app_localizations.dart';
import 'admin/admin_toast.dart';

void showPasswordAnd2FABottomSheet(
  BuildContext context,
  bool is2faEnabled,
  ValueChanged<bool> on2faChanged,
) {
  final currentPwdCtrl = TextEditingController();
  final newPwdCtrl = TextEditingController();
  final confirmPwdCtrl = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          var twoFactorEnabled = is2faEnabled;

          void handleToggle(bool val) {
            if (val) {
              show2faSetupDialog(ctx, () {
                setSheetState(() => twoFactorEnabled = true);
                on2faChanged(true);
              });
            } else {
              showDialog(
                context: ctx,
                builder: (dctx) => AlertDialog(
                  title: Text(AppLocalizations.of(dctx)!.widgetsTwoFactorDisable2fa),
                  content: Text(AppLocalizations.of(dctx)!.widgetsTwoFactorDisable2faConfirm),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dctx), child: Text(AppLocalizations.of(dctx)!.widgetsTwoFactorCancel)),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dctx);
                        setSheetState(() => twoFactorEnabled = false);
                        on2faChanged(false);
                      },
                      child: Text(AppLocalizations.of(dctx)!.widgetsTwoFactorDisable, style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(ctx)!.widgetsTwoFactorPassword2fa,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(ctx)!.widgetsTwoFactor2faLabel,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          Text(
                            twoFactorEnabled
                                ? AppLocalizations.of(ctx)!.widgetsTwoFactor2faEnabledDesc
                                : AppLocalizations.of(ctx)!.widgetsTwoFactor2faDisabledDesc,
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: twoFactorEnabled,
                      activeColor: AppColors.primary,
                      onChanged: handleToggle,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(AppLocalizations.of(ctx)!.widgetsTwoFactorChangePasswordTitle,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(
                  controller: currentPwdCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(ctx)!.widgetsTwoFactorCurrentPassword,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPwdCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(ctx)!.widgetsTwoFactorNewPassword,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPwdCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(ctx)!.widgetsTwoFactorConfirmPassword,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (currentPwdCtrl.text.isEmpty) return;
                      if (newPwdCtrl.text.length < 6) {
                        AdminToast.show(ctx, message: AppLocalizations.of(ctx)!.widgetsTwoFactorPasswordLengthError, isSuccess: false);
                        return;
                      }
                      if (newPwdCtrl.text != confirmPwdCtrl.text) {
                        AdminToast.show(ctx, message: AppLocalizations.of(ctx)!.widgetsTwoFactorPasswordMismatchError, isSuccess: false);
                        return;
                      }
                      try {
                        await AuthService().changePassword(
                            currentPwdCtrl.text, newPwdCtrl.text);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        AdminToast.show(context, message: AppLocalizations.of(ctx)!.widgetsTwoFactorPasswordChanged, isSuccess: true);
                      } catch (e) {
                        if (!ctx.mounted) return;
                        AdminToast.show(ctx, message: apiErrorString(e), isSuccess: false);
                      }
                    },
                    child: Text(AppLocalizations.of(ctx)!.widgetsTwoFactorChangePassword),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      );
    },
  );
}

void show2faSetupDialog(
  BuildContext parentCtx,
  VoidCallback onActivated,
) {
  final codeCtrl = TextEditingController();
  bool sending = false;
  bool verifying = false;
  bool codeSent = false;
  String? sentCode;

  showDialog(
    context: parentCtx,
    barrierDismissible: false,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(AppLocalizations.of(ctx)!.widgetsTwoFactorActivate2fa),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(ctx)!.widgetsTwoFactor2faEmailDesc),
                  const SizedBox(height: 16),
                  if (!codeSent) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: sending
                            ? null
                            : () async {
                                setDialogState(() => sending = true);
                                await Future.delayed(const Duration(seconds: 1));
                                sentCode = '123456';
                                setDialogState(() {
                                  sending = false;
                                  codeSent = true;
                                });
                              },
                        icon: sending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.email_outlined),
                        label: Text(sending ? AppLocalizations.of(ctx)!.widgetsTwoFactorSending : AppLocalizations.of(ctx)!.widgetsTwoFactorSendCode),
                      ),
                    ),
                  ],
                  if (codeSent) ...[
                    TextField(
                      controller: codeCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24,
                          letterSpacing: 8,
                          fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(ctx)!.widgetsTwoFactorCodeHint,
                        border: const OutlineInputBorder(),
                        counterText: '',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () async {
                            setDialogState(() => sending = true);
                            await Future.delayed(const Duration(seconds: 1));
                            sentCode = '123456';
                            setDialogState(() => sending = false);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: verifying
                            ? null
                            : () async {
                                if (codeCtrl.text.length != 6) return;
                                setDialogState(() => verifying = true);
                                await Future.delayed(const Duration(seconds: 1));
                                if (codeCtrl.text == sentCode) {
                                  if (!ctx.mounted) return;
                                  Navigator.pop(ctx);
                                  onActivated();
                                  AdminToast.show(parentCtx, message: AppLocalizations.of(ctx)!.widgetsTwoFactor2faActivated, isSuccess: true);
                                } else {
                                  setDialogState(() => verifying = false);
                                  AdminToast.show(ctx, message: AppLocalizations.of(ctx)!.widgetsTwoFactorIncorrectCode, isSuccess: false);
                                }
                              },
                        child: verifying
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(AppLocalizations.of(ctx)!.widgetsTwoFactorVerifyActivate),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(AppLocalizations.of(ctx)!.widgetsTwoFactorCancel),
              ),
            ],
          );
        },
      );
    },
  );
}
