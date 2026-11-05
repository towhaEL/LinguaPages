import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
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
      appBar: CustomAppBar(
        title: l10n.settingsTitle,
        showBackIcon: true,
        action: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.hairline),
                ),
                child: Text(
                  'Offline',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.onSurfaceMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
              // 1. Patron Promotion Banner
              BlocBuilder<PremiumCubit, PremiumState>(
                builder: (context, premium) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Card(
                      key: const Key('settings_patron_banner'),
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0x332F4A7A)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.verified,
                                        color: WarmEditorialTokens.accentInkBlue,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'PATRON EDITION',
                                        style: GoogleFonts.inter(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                          color: WarmEditorialTokens.accentInkBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Unlock 12 themes and 8 fonts',
                                    style: GoogleFonts.newsreader(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: WarmEditorialTokens.textPrimaryInk,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Support private, DRM-free offline reading.',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: WarmEditorialTokens.subtitleSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            FilledButton(
                              key: const Key('settings_patron_unlock_cta'),
                              style: FilledButton.styleFrom(
                                backgroundColor: WarmEditorialTokens.accentInkBlue,
                                foregroundColor: Colors.white,
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () => showPremiumPaywall(context),
                              child: const Text('Unlock'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              // 2. Group: Appearance
              _SettingsSection(
                cardKey: const Key('settings_card_appearance'),
                title: 'Appearance',
                children: const [_AppearanceSettings()],
              ),
              Gap(AppConstant.verticalGap20),

              // 3. Group: Reading Defaults
              _SettingsSection(
                cardKey: const Key('settings_card_reading_defaults'),
                title: l10n.settingsReadingTitle,
                footer: l10n.settingsAppearanceHint,
                children: const [_ReadingSettings()],
              ),
              Gap(AppConstant.verticalGap20),

              // 4. Group: Read Aloud (TTS)
              _SettingsSection(
                cardKey: const Key('settings_card_read_aloud'),
                title: 'Read Aloud (TTS)',
                children: const [_ReadAloudSettings()],
              ),
              Gap(AppConstant.verticalGap20),

              // 5. Group: Library & Backup
              _SettingsSection(
                cardKey: const Key('settings_card_backup'),
                title: l10n.settingsBackupTitle,
                children: const [_BackupManager(), _DictionarySettings()],
              ),
              Gap(AppConstant.verticalGap20),

              // 6. Group: About & Licenses
              _SettingsSection(
                cardKey: const Key('settings_card_about'),
                title: l10n.settingsAccount,
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: l10n.appName,
                    subtitle: 'v1.0.0 (Build 104)',
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
              const SizedBox(height: 24),

              // Editorial quote footer
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Text(
                        'OpenPages v1.0.0 · 100% Offline & Private',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.onSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '“A serene sanctuary for personal stewardship.”',
                        style: GoogleFonts.newsreader(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: theme.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
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

  /// Which row shows the progress indicator while [_busy].
  bool _restoring = false;

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
    setState(() {
      _busy = true;
      _restoring = true;
    });
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
      if (mounted) {
        setState(() {
          _busy = false;
          _restoring = false;
        });
      }
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
          trailing: _busy && !_restoring ? progress : null,
        ),
        _SettingsTile(
          icon: Icons.download_outlined,
          title: l10n.settingsBackupRestore,
          subtitle: l10n.settingsBackupRestoreSubtitle,
          onTap: _busy ? null : _restore,
          trailing: _restoring ? progress : null,
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
    this.cardKey,
  });

  final String title;
  final List<Widget> children;

  /// A note under the card, for context that is not a setting itself.
  final String? footer;
  final Key? cardKey;

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
          child: Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: theme.onSurfaceMuted,
            ),
          ),
        ),
        Card(
          key: cardKey,
          color: WarmEditorialTokens.cardSurface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.hairline,
              width: 1.0,
            ),
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

class _AppearanceSettings extends StatefulWidget {
  const _AppearanceSettings();

  @override
  State<_AppearanceSettings> createState() => _AppearanceSettingsState();
}

class _AppearanceSettingsState extends State<_AppearanceSettings> {
  double _scale = 100;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SettingsTile(
          icon: Icons.palette_outlined,
          title: 'App Theme',
          subtitle: 'Warm Ivory palette',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.colors.hairline),
            ),
            child: Text(
              'System',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstant.horizontalGap16,
            vertical: AppConstant.verticalGap12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.bodyLarge(
                    'Interface scale',
                    fontWeight: FontWeight.w600,
                  ),
                  Text(
                    '${_scale.round()}%',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: context.colors.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text('A', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Slider(
                      value: _scale,
                      min: 80,
                      max: 130,
                      divisions: 5,
                      activeColor: WarmEditorialTokens.accentInkBlue,
                      onChanged: (val) => setState(() => _scale = val),
                    ),
                  ),
                  const Text('A', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReadAloudSettings extends StatefulWidget {
  const _ReadAloudSettings();

  @override
  State<_ReadAloudSettings> createState() => _ReadAloudSettingsState();
}

class _ReadAloudSettingsState extends State<_ReadAloudSettings> {
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
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = _settings;
    final speed = settings?.readAloudSpeed ?? 1.0;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppConstant.horizontalGap16,
            vertical: AppConstant.verticalGap12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText.bodyLarge(
                    l10n.readAloudSpeed,
                    fontWeight: FontWeight.w600,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: WarmEditorialTokens.spokenHighlight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${speed.toStringAsFixed(1)}x',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: WarmEditorialTokens.accentInkBlue,
                      ),
                    ),
                  ),
                ],
              ),
              Slider(
                value: speed,
                min: 0.5,
                max: 2.5,
                divisions: 8,
                activeColor: WarmEditorialTokens.accentInkBlue,
                onChanged: settings == null
                    ? null
                    : (val) => _update('readAloudSpeed', val),
              ),
            ],
          ),
        ),
        _SettingsSwitchTile(
          icon: Icons.subtitles_off_outlined,
          title: 'Skip page numbers & footnotes',
          subtitle: 'Enhances narrative flow during playback',
          value: settings?.readAloudSkipPageNumbers ?? true,
          onChanged: settings == null
              ? null
              : (value) => _update('readAloudSkipPageNumbers', value),
        ),
        _SettingsSwitchTile(
          icon: Icons.screen_lock_portrait_outlined,
          title: 'Keep screen awake while listening',
          value: settings?.readAloudKeepScreenOn ?? false,
          onChanged: settings == null
              ? null
              : (value) => _update('readAloudKeepScreenOn', value),
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
