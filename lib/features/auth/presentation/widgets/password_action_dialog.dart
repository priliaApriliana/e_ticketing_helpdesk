import 'package:flutter/material.dart';
import 'package:get/get.dart';

typedef PasswordSubmitCallback = Future<Map<String, dynamic>> Function(
  String email,
  String currentPassword,
  String newPassword,
);

Future<void> showPasswordActionDialog({
  required String title,
  required String description,
  required String submitLabel,
  required PasswordSubmitCallback onSubmit,
  String? email,
  bool showEmailField = true,
  bool requireCurrentPassword = false,
}) async {
  final result = await Get.dialog<Map<String, dynamic>>(
    _PasswordActionDialog(
      title: title,
      description: description,
      submitLabel: submitLabel,
      onSubmit: onSubmit,
      email: email,
      showEmailField: showEmailField,
      requireCurrentPassword: requireCurrentPassword,
    ),
    barrierDismissible: false,
  );

  if (result != null && result['success'] == true) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Berhasil',
        result['message'] as String? ?? 'Password berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
    });
  }
}

class _PasswordActionDialog extends StatefulWidget {
  final String title;
  final String description;
  final String submitLabel;
  final PasswordSubmitCallback onSubmit;
  final String? email;
  final bool showEmailField;
  final bool requireCurrentPassword;

  const _PasswordActionDialog({
    required this.title,
    required this.description,
    required this.submitLabel,
    required this.onSubmit,
    required this.email,
    required this.showEmailField,
    required this.requireCurrentPassword,
  });

  @override
  State<_PasswordActionDialog> createState() => _PasswordActionDialogState();
}

class _PasswordActionDialogState extends State<_PasswordActionDialog> {
  final _emailCtrl = TextEditingController();
  final _currentPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  var _obscureCurrentPassword = true;
  var _obscureNewPassword = true;
  var _obscureConfirmPassword = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.email ?? '';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await widget.onSubmit(
        _emailCtrl.text.trim(),
        _currentPasswordCtrl.text,
        _newPasswordCtrl.text,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        Get.back(result: result);
        return;
      }

      Get.snackbar(
        'Gagal',
        result['message'] as String? ?? 'Terjadi kesalahan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } catch (_) {
      if (!mounted) return;
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan saat reset password',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: AlertDialog(
        title: Text(widget.title),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  if (widget.showEmailField) ...[
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email wajib diisi';
                        }
                        if (!GetUtils.isEmail(value.trim())) {
                          return 'Format email tidak valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (widget.requireCurrentPassword) ...[
                    TextFormField(
                      controller: _currentPasswordCtrl,
                      obscureText: _obscureCurrentPassword,
                      decoration: InputDecoration(
                        labelText: 'Password Lama',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureCurrentPassword =
                                  !_obscureCurrentPassword;
                            });
                          },
                          icon: Icon(
                            _obscureCurrentPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password lama wajib diisi';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(
                    controller: _newPasswordCtrl,
                    obscureText: _obscureNewPassword,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      prefixIcon: const Icon(Icons.key_outlined),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureNewPassword = !_obscureNewPassword;
                          });
                        },
                        icon: Icon(
                          _obscureNewPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password baru wajib diisi';
                      }
                      if (value.length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _confirmPasswordCtrl,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      prefixIcon: const Icon(Icons.verified_user_outlined),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Konfirmasi password wajib diisi';
                      }
                      if (value != _newPasswordCtrl.text) {
                        return 'Konfirmasi password tidak cocok';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}