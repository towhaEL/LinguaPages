import 'package:flutter/material.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

class BackupOptions {
  const BackupOptions({
    required this.includeBookFiles,
    required this.includeDictionaryCache,
    this.passphrase,
  });

  final bool includeBookFiles;
  final bool includeDictionaryCache;
  final String? passphrase;
}

/// Asks what the backup should contain; null when cancelled.
Future<BackupOptions?> showBackupOptionsDialog(BuildContext context) {
  return showDialog<BackupOptions>(
    context: context,
    builder: (_) => const _BackupOptionsDialog(),
  );
}

/// Asks for the passphrase of an encrypted backup; null when cancelled.
Future<String?> showBackupPassphraseDialog(
  BuildContext context, {
  String? errorText,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _PassphraseDialog(errorText: errorText),
  );
}

class _BackupOptionsDialog extends StatefulWidget {
  const _BackupOptionsDialog();

  @override
  State<_BackupOptionsDialog> createState() => _BackupOptionsDialogState();
}

class _BackupOptionsDialogState extends State<_BackupOptionsDialog> {
  // shortcut: PBKDF2 in the zip AES format runs 1000 iterations, so length is
  // the main guard against guessing; raise if the format changes.
  static const _minPassphraseLength = 8;

  final _formKey = GlobalKey<FormState>();
  final _passphrase = TextEditingController();
  final _confirm = TextEditingController();
  bool _includeBookFiles = true;
  bool _includeDictionaryCache = false;

  @override
  void dispose() {
    _passphrase.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      BackupOptions(
        includeBookFiles: _includeBookFiles,
        includeDictionaryCache: _includeDictionaryCache,
        passphrase: _passphrase.text.isEmpty ? null : _passphrase.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.settingsBackupCreate),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _includeBookFiles,
                onChanged: (value) =>
                    setState(() => _includeBookFiles = value ?? false),
                title: Text(l10n.settingsBackupIncludeBooks),
                subtitle: Text(l10n.settingsBackupIncludeBooksSubtitle),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _includeDictionaryCache,
                onChanged: (value) =>
                    setState(() => _includeDictionaryCache = value ?? false),
                title: Text(l10n.settingsBackupIncludeDictionary),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passphrase,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  fillColor: context.colors.surfaceElevated,
                  labelText: l10n.settingsBackupPassphrase,
                  helperText: l10n.settingsBackupPassphraseHelper,
                  helperMaxLines: 2,
                ),
                onChanged: (_) => setState(() {}),
                validator: (value) =>
                    value != null &&
                        value.isNotEmpty &&
                        value.length < _minPassphraseLength
                    ? l10n.settingsBackupPassphraseTooShort
                    : null,
              ),
              if (_passphrase.text.isNotEmpty) ...[
                // Clears the helper text above.
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirm,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    fillColor: context.colors.surfaceElevated,
                    labelText: l10n.settingsBackupPassphraseConfirm,
                  ),
                  validator: (value) => value != _passphrase.text
                      ? l10n.settingsBackupPassphraseMismatch
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(l10n.settingsBackupExportAction),
        ),
      ],
    );
  }
}

class _PassphraseDialog extends StatefulWidget {
  const _PassphraseDialog({this.errorText});

  final String? errorText;

  @override
  State<_PassphraseDialog> createState() => _PassphraseDialogState();
}

class _PassphraseDialogState extends State<_PassphraseDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.isEmpty) return;
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.settingsBackupPassphrasePrompt),
      content: TextField(
        controller: _controller,
        autofocus: true,
        obscureText: true,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          fillColor: context.colors.surfaceElevated,
          labelText: l10n.settingsBackupPassphraseLabel,
          errorText: widget.errorText,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(l10n.settingsBackupRestoreAction),
        ),
      ],
    );
  }
}
