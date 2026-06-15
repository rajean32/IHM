import 'package:flutter/material.dart';
import '../core/assets/app_colors.dart';
import '../core/services/auth_service.dart';
import '../core/utils/error_helper.dart';

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
                  title: const Text('Désactiver la 2FA'),
                  content: const Text('Voulez-vous vraiment désactiver l\'authentification à deux facteurs ?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(dctx), child: const Text('Annuler')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dctx);
                        setSheetState(() => twoFactorEnabled = false);
                        on2faChanged(false);
                      },
                      child: const Text('Désactiver', style: TextStyle(color: Colors.red)),
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
                const Text('Mot de passe & 2FA',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Authentification à deux facteurs',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          Text(
                            twoFactorEnabled
                                ? 'Code à 6 chiffres envoyé par email'
                                : 'Activez pour sécuriser votre compte',
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
                const Text('Changer le mot de passe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextField(
                  controller: currentPwdCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mot de passe actuel',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPwdCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPwdCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmer',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (currentPwdCtrl.text.isEmpty) return;
                      if (newPwdCtrl.text.length < 6) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Le mot de passe doit contenir au moins 6 caractères'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }
                      if (newPwdCtrl.text != confirmPwdCtrl.text) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Les mots de passe ne correspondent pas'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }
                      try {
                        await AuthService().changePassword(
                            currentPwdCtrl.text, newPwdCtrl.text);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mot de passe modifié'),
                            backgroundColor: AppColors.secondary,
                          ),
                        );
                      } catch (e) {
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(apiErrorString(e)),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    child: const Text('Changer le mot de passe'),
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
            title: const Text('Activer la 2FA'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Un code à 6 chiffres sera envoyé à votre adresse email.'),
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
                        label: Text(sending ? 'Envoi...' : 'Envoyer le code'),
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
                        hintText: '000000',
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
                                  ScaffoldMessenger.of(parentCtx).showSnackBar(
                                    const SnackBar(
                                      content: Text('2FA activée'),
                                      backgroundColor: AppColors.secondary,
                                    ),
                                  );
                                } else {
                                  setDialogState(() => verifying = false);
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(
                                      content: Text('Code incorrect'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              },
                        child: verifying
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Vérifier et activer'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler'),
              ),
            ],
          );
        },
      );
    },
  );
}
