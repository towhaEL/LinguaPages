import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lingua_pages/core/constants/app_constant.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/repository/backup/backup_repository.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';
import 'package:lingua_pages/domain/repository/translation/language_pack_repository.dart';
import 'package:lingua_pages/domain/use_cases/backup/create_backup_use_case.dart';
import 'package:lingua_pages/domain/use_cases/backup/restore_backup_use_case.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/screen/settings/components/language_drop_down_button.dart';
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
          // Clear the extended-body bottom navigation bar so the last row
          // stays fully visible above it.
          MediaQuery.of(context).padding.bottom + 90,
        ),
        children: [
          _SettingsSection(
            title: l10n.settingsAppearance,
            children: [
              _SettingsTile(
                icon: Icons.language_outlined,
                title: l10n.settingsLanguage,
                trailing: const LanguageDropDownButton(),
              ),
            ],
          ),
          Gap(AppConstant.verticalGap20),
          _SettingsSection(
            title: l10n.settingsLanguagePacks,
            children: const [_LanguagePackManager()],
          ),
          Gap(AppConstant.verticalGap20),
          _SettingsSection(
            title: l10n.settingsBackupTitle,
            children: const [_BackupManager()],
          ),
          Gap(AppConstant.verticalGap20),
          _SettingsSection(
            title: l10n.settingsStudy,
            children: const [_StudySettings()],
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
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguagePackManager extends StatefulWidget {
  const _LanguagePackManager();

  @override
  State<_LanguagePackManager> createState() => _LanguagePackManagerState();
}

class _LanguagePackManagerState extends State<_LanguagePackManager> {
  late final LanguagePackRepository _repository;
  List<LanguagePackInfo> _packs = const [];
  bool _loading = true;
  String? _error;
  String? _busyPackId;

  @override
  void initState() {
    super.initState();
    _repository = injector<LanguagePackRepository>();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final packs = await _repository.getAvailablePacks();
      if (!mounted) return;
      setState(() {
        _packs = packs;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = context.l10n.settingsLanguagePackFailed;
      });
    }
  }

  Future<void> _toggle(LanguagePackInfo pack) async {
    setState(() => _busyPackId = pack.id);
    try {
      if (pack.isInstalled) {
        await _repository.delete(pack.id);
      } else {
        await _repository.install(pack.id);
      }
      await _load();
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = context.l10n.settingsLanguagePackFailed);
    } finally {
      if (mounted) setState(() => _busyPackId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.all(AppConstant.horizontalGap16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_error != null) {
      return ListTile(
        leading: const Icon(Icons.error_outline),
        title: Text(_error!),
        trailing: IconButton(
          tooltip: context.l10n.refresh,
          onPressed: _load,
          icon: const Icon(Icons.refresh),
        ),
      );
    }
    return Column(
      children: [
        for (final pack in _packs)
          ListTile(
            leading: const Icon(Icons.translate_outlined),
            title: Text(_packName(context, pack)),
            subtitle: Text(
              '${context.l10n.settingsLanguagePackVersion(pack.version)} · '
              '${_formatSize(pack.sizeBytes)}',
            ),
            trailing: _busyPackId == pack.id
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: () => _toggle(pack),
                    child: Text(
                      pack.isInstalled
                          ? context.l10n.settingsLanguagePackDelete
                          : context.l10n.settingsLanguagePackInstall,
                    ),
                  ),
          ),
        if (_packs.isEmpty)
          ListTile(title: Text(context.l10n.settingsLanguagePackEmpty)),
      ],
    );
  }

  String _packName(BuildContext context, LanguagePackInfo pack) {
    if (pack.sourceLanguage == 'en' && pack.targetLanguage == 'es') {
      return context.l10n.settingsLanguagePackEnglishSpanish;
    }
    return '${pack.sourceLanguage.toUpperCase()} → '
        '${pack.targetLanguage.toUpperCase()}';
  }

  String _formatSize(int bytes) {
    if (bytes < 1024 * 1024) return '${bytes ~/ 1024} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _BackupManager extends StatefulWidget {
  const _BackupManager();

  @override
  State<_BackupManager> createState() => _BackupManagerState();
}

class _StudySettings extends StatefulWidget {
  const _StudySettings();

  @override
  State<_StudySettings> createState() => _StudySettingsState();
}

class _StudySettingsState extends State<_StudySettings> {
  late final SettingsRepository _repository = injector<SettingsRepository>();
  SettingsEntity? _settings;
  String? _error;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final settings = await _repository.getSettings();
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = context.l10n.settingsSaveFailed);
    }
  }

  Future<void> _updateDailyLimit(int value) async {
    setState(() => _saving = true);
    try {
      final settings = await _repository.updateSetting<int>(
        key: 'dailyNewCardLimit',
        value: value,
      );
      if (!mounted) return;
      setState(() {
        _settings = settings;
        _saving = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = context.l10n.settingsSaveFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    if (settings == null) {
      return ListTile(
        leading: const Icon(Icons.school_outlined),
        title: Text(_error ?? context.l10n.settingsStudy),
        trailing: _error == null
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                tooltip: context.l10n.refresh,
              ),
      );
    }

    final limits = {5, 10, 15, 20, 30, 50, settings.dailyNewCardLimit}.toList()
      ..sort();

    return _SettingsTile(
      icon: Icons.school_outlined,
      title: context.l10n.settingsDailyNewCardLimit,
      subtitle: context.l10n.settingsDailyNewCardLimitValue(
        settings.dailyNewCardLimit,
      ),
      trailing: _saving
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : DropdownButton<int>(
              value: settings.dailyNewCardLimit,
              onChanged: (value) {
                if (value != null) _updateDailyLimit(value);
              },
              items: limits
                  .map(
                    (value) => DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value'),
                    ),
                  )
                  .toList(),
            ),
    );
  }
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
          trailing: _busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  tooltip: l10n.settingsBackupCreate,
                  onPressed: _export,
                  icon: const Icon(Icons.save_alt_outlined),
                ),
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: Text(l10n.settingsBackupRestore),
          subtitle: Text(l10n.settingsBackupRestoreSubtitle),
          trailing: IconButton(
            tooltip: l10n.settingsBackupRestore,
            onPressed: _busy ? null : _restore,
            icon: const Icon(Icons.folder_open_outlined),
          ),
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
            color: theme.onSurface.withAlpha(150),
            fontWeight: FontWeight.w700,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(AppConstant.borderRadius12),
            border: Border.all(color: theme.border.withAlpha(128)),
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
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;

    return InkWell(
      borderRadius: BorderRadius.circular(AppConstant.borderRadius12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppConstant.horizontalGap16,
          vertical: AppConstant.verticalGap12,
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.primary, size: 22),
            Gap(AppConstant.horizontalGap16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.bodyLarge(title, fontWeight: FontWeight.w600),
                  if (subtitle != null) ...[
                    Gap(AppConstant.verticalGap4),
                    AppText.bodySmall(
                      subtitle!,
                      color: theme.onSurface.withAlpha(150),
                    ),
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
