import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lingua_pages/core/constants/app_constant.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/repository/backup/backup_repository.dart';
import 'package:lingua_pages/domain/use_cases/backup/create_backup_use_case.dart';
import 'package:lingua_pages/domain/use_cases/backup/restore_backup_use_case.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/theme/text/app_text.dart';
import 'package:lingua_pages/presentation/widgets/app_bar/widgets.dart';

class SettingsPortraitView extends StatelessWidget {
  const SettingsPortraitView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: CustomAppBar(title: l10n.settingsTitle),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          AppConstant.horizontalGap16,
          AppConstant.horizontalGap16,
          AppConstant.horizontalGap16,
          AppConstant.verticalGap24,
        ),
        children: [
          _SettingsSection(
            title: l10n.settingsBackupTitle,
            children: const [_BackupManager()],
          ),
          Gap(AppConstant.verticalGap20),
          _SettingsSection(
            title: l10n.settingsAccount,
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                title: l10n.appName,
                subtitle: 'v1.0.0',
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: l10n.settingsPrivacy,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.router.root.push(const PrivacyRoute()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackupManager extends StatefulWidget {
  const _BackupManager();

  @override
  State<_BackupManager> createState() => _BackupManagerState();
}

class _BackupManagerState extends State<_BackupManager> {
  late final CreateBackupUseCase _createBackup;
  late final RestoreBackupUseCase _restoreBackup;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _createBackup = injector<CreateBackupUseCase>();
    _restoreBackup = injector<RestoreBackupUseCase>();
  }

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final sourcePath = await _createBackup.execute();
      if (!mounted) return;
      final destinationUri = await FilePicker.saveFile(
        dialogTitle: l10n.settingsBackupCreate,
        fileName: 'linguapages-backup.json',
        bytes: await File(sourcePath).readAsBytes(),
        mimeType: 'application/json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (destinationUri == null) return;
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsBackupCreated)),
        );
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsBackupFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final result = await FilePicker.pickFiles(
        dialogTitle: l10n.settingsBackupRestore,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result.isEmpty) return;
      final pickedFile = result.single;
      File? temporaryFile;
      var filePath = pickedFile.path;
      if (filePath == null) {
        temporaryFile = File(
          '${Directory.systemTemp.path}/linguapages-restore-'
          '${DateTime.now().microsecondsSinceEpoch}.json',
        );
        await temporaryFile.writeAsBytes(await pickedFile.readAsBytes());
        filePath = temporaryFile.path;
      }
      final summary = await _restoreBackup.execute(filePath);
      await temporaryFile?.delete();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(_restoreMessage(l10n, summary))),
        );
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.settingsBackupFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _restoreMessage(AppLocalizations l10n, BackupRestoreResult result) {
    return l10n.settingsBackupRestored(
      result.totalRestored,
      result.duplicatesSkipped,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.upload_file_outlined),
          title: Text(l10n.settingsBackupCreate),
          subtitle: Text(l10n.settingsBackupCreateSubtitle),
          enabled: !_busy,
          onTap: _export,
          trailing: _busy
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : null,
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: Text(l10n.settingsBackupRestore),
          subtitle: Text(l10n.settingsBackupRestoreSubtitle),
          enabled: !_busy,
          onTap: _restore,
        ),
      ],
    );
  }
}

/// A titled group of setting rows wrapped in a bordered card.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: AppConstant.horizontalGap4,
            bottom: AppConstant.verticalGap8,
          ),
          child: AppText.titleSmall(
            title,
            color: theme.onSurfaceMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.surface,
            // Cards are told apart by tone, not borders (DESIGN.md).
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

/// A single settings row with a leading icon, title/subtitle and optional
/// trailing widget.
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstant.borderRadius12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstant.horizontalGap16,
          vertical: AppConstant.verticalGap12,
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.onSurfaceMuted, size: 22),
            Gap(AppConstant.horizontalGap16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodyLarge(title, fontWeight: FontWeight.w600),
                  if (subtitle != null) ...[
                    Gap(AppConstant.verticalGap4),
                    AppText.bodySmall(subtitle!, color: theme.onSurfaceMuted),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
