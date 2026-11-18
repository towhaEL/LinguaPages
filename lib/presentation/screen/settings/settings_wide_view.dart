part of 'settings_portrait_view.dart';

/// Landscape and wide tablet settings: the groups listed on the start side,
/// the selected group's card on the end side, so nothing stretches across
/// the full width and a short landscape screen is not one long scroll.
class SettingsWideView extends StatefulWidget {
  const SettingsWideView({super.key, this.navWidth = 300});

  /// Narrower on phones in landscape, where width is plentiful but every
  /// pixel of the detail column counts.
  final double navWidth;

  @override
  State<SettingsWideView> createState() => _SettingsWideViewState();
}

class _SettingsWideViewState extends State<SettingsWideView> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final theme = context.colors;
    final sections = _settingsSections(context);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: CustomAppBar(
        title: context.l10n.settingsTitle,
        showBackIcon: true,
      ),
      body: SafeArea(
        top: false,
        child: TwoPane(
          startWidth: widget.navWidth,
          start: ListView(
            key: const Key('settings_nav_pane'),
            padding: EdgeInsets.symmetric(
              horizontal: AppConstant.horizontalGap8,
              vertical: AppConstant.verticalGap8,
            ),
            children: [
              for (final (index, section) in sections.indexed)
                _SectionNavTile(
                  key: Key('settings_nav_${section.id}'),
                  icon: section.icon,
                  title: section.title,
                  selected: index == _selected,
                  onTap: () => setState(() => _selected = index),
                ),
              const SizedBox(height: 16),
              const _SettingsFooter(),
            ],
          ),
          // Every group stays built, so switching groups keeps each one's
          // scroll position and any work in flight, like a backup export.
          end: IndexedStack(
            index: _selected.clamp(0, sections.length - 1),
            children: [
              for (final (index, section) in sections.indexed)
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: ListView(
                      primary: false,
                      padding: EdgeInsets.fromLTRB(
                        AppConstant.horizontalGap16,
                        AppConstant.horizontalGap16,
                        AppConstant.horizontalGap16,
                        AppConstant.verticalGap24,
                      ),
                      children: [
                        // Once, above the looks it unlocks, rather than
                        // over every group on a short landscape screen.
                        if (index == 0) const _PremiumBanner(),
                        _SettingsSection.of(section),
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

class _SectionNavTile extends StatelessWidget {
  const _SectionNavTile({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = context.accent;
    final theme = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        selected: selected,
        onTap: onTap,
        dense: true,
        shape: const StadiumBorder(),
        selectedTileColor: accent.withValues(alpha: 0.10),
        selectedColor: accent,
        iconColor: theme.onSurfaceMuted,
        leading: Icon(icon, size: 22),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
