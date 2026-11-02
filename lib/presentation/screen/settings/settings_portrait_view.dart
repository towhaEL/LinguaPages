import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:lingua_pages/core/constants/app_constant.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/domain/entity/settings/settings_entity.dart';
import 'package:lingua_pages/domain/exceptions/backup_exception.dart';
import 'package:lingua_pages/domain/repository/backup/backup_repository.dart';
import 'package:lingua_pages/domain/repository/settings/settings_repository.dart';
import 'package:lingua_pages/domain/use_cases/backup/create_backup_use_case.dart';
import 'package:lingua_pages/domain/use_cases/backup/restore_backup_use_case.dart';
import 'package:lingua_pages/domain/use_cases/dictionary/clear_dictionary_cache_use_case.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_cubit.dart';
import 'package:lingua_pages/presentation/screen/premium/cubit/premium_state.dart';
import 'package:lingua_pages/presentation/screen/premium/widgets/premium_paywall_sheet.dart';
import 'package:lingua_pages/presentation/screen/settings/widgets/backup_dialogs.dart';
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
      // A readable column on tablets and in landscape.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppConstant.horizontalGap16,
              AppConstant.horizontalGap16,
              AppConstant.horizontalGap16,
              AppConstant.verticalGap24,
            ),
            children: [
              _SettingsSection(
                title: l10n.settingsReadingTitle,
                footer: l10n.settingsAppearanceHint,
                children: const [_ReadingSettings()],
              ),
              Gap(AppConstant.verticalGap20),
              _SettingsSection(
                title: l10n.settingsDictionaryTitle,
                children: const [_DictionarySettings()],
              ),
              Gap(AppConstant.verticalGap20),
              _SettingsSection(
                title: l10n.settingsBackupTitle,
                children: const [_BackupManager()],
              ),
              Gap(AppConstant.verticalGap20),
              _SettingsSection(
                title: l10n.settingsPurchasesTitle,
                children: [
                  BlocBuilder<PremiumCubit, PremiumState>(
                    builder: (context, premium) => _SettingsTile(
                      icon: Icons.palette_outlined,
                      title: l10n.premiumTitle,
                      subtitle: premium.unlocked
                          ? l10n.settingsPremiumUnlocked
                          : l10n.settingsPremiumLocked,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => showPremiumPaywall(context),
                    ),
                  ),
                ],
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
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: l10n.settingsLicenses,
                    subtitle: l10n.settingsLicensesSubtitle,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: l10n.appName,
                      applicationVersion: '1.0.0',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reading behaviour that is not about how the page looks. Appearance stays
/// in the reader, where the page is visible while it changes.
class _ReadingSettings extends StatefulWidget {
  const _ReadingSettings();

  @override
  State<_ReadingSettings> createState() => _ReadingSettingsState();
}

class _ReadingSettingsState extends State<_ReadingSettings> {
  final SettingsRepository _settingsRepository = injector<SettingsRepository>();
  SettingsEntity? _settings;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final settings = await _settingsRepository.getSettings();
      if (mounted) setState(() => _settings = settings);
    } catch (_) {
      if (mounted) setState(() => _settings = const SettingsEntity());
    }
  }

  Future<void> _update(String key, Object value) async {
    try {
      final settings = await _settingsRepository.updateSetting(
        key: key,
        value: value,
      );
      if (mounted) setState(() => _settings = settings);
    } catch (_) {
      // The switch shows the stored value again on failure.
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = _settings;
    return Column(
      children: [
        _SettingsSwitchTile(
          icon: Icons.light_mode_outlined,
          title: l10n.settingsKeepScreenOn,
          value: settings?.keepScreenAwake ?? false,
          onChanged: settings == null
              ? null
              : (value) => _update('keepScreenAwake', value),
        ),
        _SettingsSwitchTile(
          icon: Icons.swap_vert_rounded,
          title: l10n.settingsScrollMode,
          value: settings?.readerMode == ReaderMode.continuous,
          onChanged: settings == null
              ? null
              : (value) => _update(
                  'readerMode',
                  (value ? ReaderMode.continuous : ReaderMode.paginated).name,
                ),
        ),
        _SettingsChoiceTile<ReaderTapZones>(
          icon: Icons.touch_app_outlined,
          title: l10n.settingsTapZones,
          subtitle: l10n.settingsTapZonesSubtitle,
          values: ReaderTapZones.values,
          value: settings?.readerTapZones,
          label: (value) => switch (value) {
            ReaderTapZones.sides => l10n.settingsTapZonesSides,
            ReaderTapZones.topBottom => l10n.settingsTapZonesTopBottom,
            ReaderTapZones.off => l10n.settingsTapZonesOff,
          },
          onChanged: (value) => _update('readerTapZones', value.name),
        ),
        _SettingsSwitchTile(
          icon: Icons.volume_down_outlined,
          title: l10n.settingsVolumeKeys,
          subtitle: l10n.settingsVolumeKeysSubtitle,
          value: settings?.volumeKeyPaging ?? false,
          onChanged: settings == null
              ? null
              : (value) => _update('volumeKeyPaging', value),
        ),
        _SettingsSwitchTile(
          icon: Icons.fullscreen_rounded,
          title: l10n.settingsFullScreen,
          value: settings?.fullScreenReading ?? false,
          onChanged: settings == null
              ? null
              : (value) => _update('fullScreenReading', value),
        ),
        _SettingsChoiceTile<ReaderOrientation>(
          icon: Icons.screen_rotation_outlined,
          title: l10n.settingsOrientation,
          values: ReaderOrientation.values,
          value: settings?.readerOrientation,
          label: (value) => switch (value) {
            ReaderOrientation.auto => l10n.settingsOrientationAuto,
            ReaderOrientation.portrait => l10n.settingsOrientationPortrait,
            ReaderOrientation.landscape => l10n.settingsOrientationLandscape,
          },
          onChanged: (value) => _update('readerOrientation', value.name),
        ),
        _SettingsSwitchTile(
          icon: Icons.brightness_6_outlined,
          title: l10n.settingsEdgeBrightness,
          subtitle: l10n.settingsEdgeBrightnessSubtitle,
          value: settings?.edgeBrightness ?? false,
          onChanged: settings == null
              ? null
              : (value) => _update('edgeBrightness', value),
        ),
        _SettingsChoiceTile<ReaderProgressDisplay>(
          icon: Icons.linear_scale_rounded,
          title: l10n.settingsProgressDisplay,
          values: ReaderProgressDisplay.values,
          value: settings?.readerProgressDisplay,
          label: (value) => switch (value) {
            ReaderProgressDisplay.none => l10n.settingsProgressNone,
            ReaderProgressDisplay.page => l10n.settingsProgressPage,
            ReaderProgressDisplay.percent => l10n.settingsProgressPercent,
          },
          onChanged: (value) => _update('readerProgressDisplay', value.name),
        ),
        _SettingsSwitchTile(
          icon: Icons.crop_free_rounded,
          title: l10n.settingsCornerShortcuts,
          subtitle: l10n.settingsCornerShortcutsSubtitle,
          value: settings?.cornerShortcuts ?? false,
          onChanged: settings == null
              ? null
              : (value) => _update('cornerShortcuts', value),
        ),
        _SettingsSwitchTile(
          icon: Icons.headphones_outlined,
          title: l10n.settingsReadAloudKeepScreenOn,
          value: settings?.readAloudKeepScreenOn ?? false,
          onChanged: settings == null
              ? null
              : (value) => _update('readAloudKeepScreenOn', value),
        ),
        _SettingsSwitchTile(
          icon: Icons.format_list_numbered_rounded,
          title: l10n.settingsReadAloudSkipPageNumbers,
          subtitle: l10n.settingsReadAloudSkipPageNumbersSubtitle,
          value: settings?.readAloudSkipPageNumbers ?? true,
          onChanged: settings == null
              ? null
              : (value) => _update('readAloudSkipPageNumbers', value),
        ),
      ],
    );
  }
}

class _DictionarySettings extends StatefulWidget {
  const _DictionarySettings();

  @override
  State<_DictionarySettings> createState() => _DictionarySettingsState();
}

class _DictionarySettingsState extends State<_DictionarySettings> {
  final SettingsRepository _settingsRepository = injector<SettingsRepository>();
  final ClearDictionaryCacheUseCase _clearCache =
      injector<ClearDictionaryCacheUseCase>();
  bool? _online;
  bool _clearing = false;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final settings = await _settingsRepository.getSettings();
      if (mounted) setState(() => _online = settings.onlineDictionary);
    } catch (_) {
      if (mounted) setState(() => _online = true);
    }
  }

  Future<void> _setOnline(bool value) async {
    final previous = _online;
    setState(() => _online = value);
    try {
      await _settingsRepository.updateSetting(
        key: 'onlineDictionary',
        value: value,
      );
    } catch (_) {
      if (mounted) setState(() => _online = previous);
    }
  }

  Future<void> _clear() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _clearing = true);
    try {
      await _clearCache.execute();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsDictionaryCacheCleared)),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsDictionaryCacheFailed)),
      );
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        _SettingsSwitchTile(
          icon: Icons.travel_explore_outlined,
          title: l10n.settingsOnlineDictionary,
          subtitle: l10n.settingsOnlineDictionarySubtitle,
          value: _online ?? true,
          onChanged: _online == null ? null : _setOnline,
        ),
        _SettingsTile(
          icon: Icons.delete_sweep_outlined,
          title: l10n.settingsClearDictionaryCache,
          subtitle: l10n.settingsClearDictionaryCacheSubtitle,
          onTap: _clearing ? null : _clear,
        ),
      ],
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
    final options = await showBackupOptionsDialog(context);
    if (options == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final sourcePath = await _createBackup.execute(
        includeBookFiles: options.includeBookFiles,
        includeDictionaryCache: options.includeDictionaryCache,
        passphrase: options.passphrase,
      );
      if (!mounted) return;
      // shortcut: the save dialog takes bytes, so the whole zip is held in
      // memory; move to a streamed share/save if libraries reach ~1 GB.
      final destinationUri = await FilePicker.saveFile(
        dialogTitle: l10n.settingsBackupCreate,
        fileName: 'linguapages-backup.zip',
        bytes: await File(sourcePath).readAsBytes(),
        mimeType: 'application/zip',
        type: FileType.custom,
        allowedExtensions: ['zip'],
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
        allowedExtensions: ['zip', 'json'],
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
      final BackupRestoreResult? summary;
      try {
        summary = await _restoreWithPassphrase(filePath);
      } finally {
        await temporaryFile?.delete();
      }
      if (summary != null && mounted) {
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

  /// Restores [filePath], asking for the passphrase while an encrypted backup
  /// needs one. Returns null when the user cancels.
  Future<BackupRestoreResult?> _restoreWithPassphrase(String filePath) async {
    String? passphrase;
    while (true) {
      try {
        return await _restoreBackup.execute(filePath, passphrase: passphrase);
      } on BackupException catch (error) {
        if (!mounted) return null;
        passphrase = await showBackupPassphraseDialog(
          context,
          errorText: error.kind == BackupFailureKind.passphraseIncorrect
              ? context.l10n.settingsBackupPassphraseIncorrect
              : null,
        );
        if (passphrase == null) return null;
      }
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
    const progress = SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
    return Column(
      children: [
        _SettingsTile(
          icon: Icons.upload_file_outlined,
          title: l10n.settingsBackupCreate,
          subtitle: l10n.settingsBackupCreateSubtitle,
          onTap: _busy ? null : _export,
          trailing: _busy ? progress : null,
        ),
        _SettingsTile(
          icon: Icons.download_outlined,
          title: l10n.settingsBackupRestore,
          subtitle: l10n.settingsBackupRestoreSubtitle,
          onTap: _busy ? null : _restore,
        ),
      ],
    );
  }
}

/// A titled group of setting rows wrapped in a bordered card.
class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.children,
    this.footer,
  });

  final String title;
  final List<Widget> children;

  /// A note under the card, for context that is not a setting itself.
  final String? footer;

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
        if (footer != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppConstant.horizontalGap4,
              AppConstant.verticalGap8,
              AppConstant.horizontalGap4,
              0,
            ),
            child: AppText.bodySmall(footer!, color: theme.onSurfaceMuted),
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

/// A settings row with a switch; the whole row toggles it.
/// A setting with a few named values; tapping lists them in a dialog.
class _SettingsChoiceTile<T> extends StatelessWidget {
  const _SettingsChoiceTile({
    required this.icon,
    required this.title,
    required this.values,
    required this.value,
    required this.label,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final List<T> values;

  /// Null while settings load; the row is then disabled.
  final T? value;
  final String Function(T value) label;
  final ValueChanged<T> onChanged;

  Future<void> _choose(BuildContext context) async {
    final chosen = await showDialog<T>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(title),
        children: [
          for (final option in values)
            SimpleDialogOption(
              onPressed: () => Navigator.of(dialogContext).pop(option),
              child: Row(
                children: [
                  Expanded(child: Text(label(option))),
                  if (option == value) const Icon(Icons.check_rounded),
                ],
              ),
            ),
        ],
      ),
    );
    if (chosen != null && chosen != value) onChanged(chosen);
  }

  @override
  Widget build(BuildContext context) {
    final current = value;
    return _SettingsTile(
      icon: icon,
      title: title,
      subtitle: current == null
          ? subtitle
          : [label(current), ?subtitle].join(' · '),
      onTap: current == null ? null : () => _choose(context),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return MergeSemantics(
      child: _SettingsTile(
        icon: icon,
        title: title,
        subtitle: subtitle,
        onTap: onChanged == null ? null : () => onChanged(!value),
        trailing: Padding(
          padding: EdgeInsets.only(left: AppConstant.horizontalGap12),
          child: Switch(value: value, onChanged: onChanged),
        ),
      ),
    );
  }
}
