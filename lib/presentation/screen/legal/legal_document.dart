import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lingua_pages/l10n/l10n.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';
import 'package:lingua_pages/presentation/widgets/app_bar/widgets.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_mini_player.dart';
import 'package:lingua_pages/presentation/widgets/widgets.dart';

/// A short reading page, not a set of cards: headings and paragraphs at a
/// comfortable measure.
@RoutePage()
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sections = [
      (l10n.privacyLocalDataTitle, l10n.privacyLocalDataBody),
      (l10n.privacyDictionaryTitle, l10n.privacyDictionaryBody),
      (l10n.privacyBackupTitle, l10n.privacyBackupBody),
      (l10n.privacyPurchasesTitle, l10n.privacyPurchasesBody),
      (l10n.privacyTrackingTitle, l10n.privacyTrackingBody),
    ];
    return ReadAloudMiniPlayerHost(
      child: Scaffold(
        backgroundColor: context.colors.background,
        appBar: CustomAppBar(title: l10n.privacyTitle, showBackIcon: true),
        body: _ResponsivePrivacy(sections: sections),
      ),
    );
  }
}

class _ResponsivePrivacy extends Screen {
  const _ResponsivePrivacy({required this.sections});

  final List<(String, String)> sections;

  /// Below this the index pane would squeeze the reading column.
  static const _indexMinWidth = 720.0;

  @override
  Widget buildMobilePortraitView(BuildContext context) {
    return _PrivacyColumn(sections: sections);
  }

  @override
  Widget buildMobileLandscapeView(BuildContext context) {
    return _PrivacyWithIndex(sections: sections, indexWidth: 220);
  }

  @override
  Widget buildTabletView(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= _indexMinWidth
        ? _PrivacyWithIndex(sections: sections, indexWidth: 260)
        : _PrivacyColumn(sections: sections);
  }
}

/// The page on its own: one centred reading column.
class _PrivacyColumn extends StatelessWidget {
  const _PrivacyColumn({required this.sections});

  final List<(String, String)> sections;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: _SectionList(sections: sections),
          ),
        ),
      ],
    );
  }
}

/// Landscape and tablet: section headings as an index on the start side,
/// the reading column on the end side. Tapping a heading scrolls to it.
class _PrivacyWithIndex extends StatefulWidget {
  const _PrivacyWithIndex({required this.sections, required this.indexWidth});

  final List<(String, String)> sections;
  final double indexWidth;

  @override
  State<_PrivacyWithIndex> createState() => _PrivacyWithIndexState();
}

class _PrivacyWithIndexState extends State<_PrivacyWithIndex> {
  late final _keys = [for (final _ in widget.sections) GlobalKey()];
  final _scroll = ScrollController();
  int _selected = 0;

  /// Set while a tapped heading scrolls into view, so the scroll listener
  /// doesn't move the highlight off it; the last sections can't reach the
  /// top of the viewport.
  bool _jumping = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_followScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _jumpTo(int index) async {
    setState(() => _selected = index);
    final target = _keys[index].currentContext;
    if (target == null) return;
    _jumping = true;
    try {
      await Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _jumping = false;
    }
  }

  /// Highlights the section whose heading most recently scrolled past the
  /// top of the reading pane, or the last one once the end is reached.
  void _followScroll() {
    if (_jumping || !_scroll.hasClients) return;
    final position = _scroll.position;
    var current = 0;
    if (position.pixels >= position.maxScrollExtent - 1) {
      current = _keys.length - 1;
    } else {
      final viewport = context.findRenderObject();
      for (final (index, key) in _keys.indexed) {
        final box = key.currentContext?.findRenderObject() as RenderBox?;
        if (box == null || viewport == null) continue;
        final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
        if (top <= 48) current = index;
      }
    }
    if (current != _selected) setState(() => _selected = current);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accent = context.accent;
    final text = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: TwoPane(
        startWidth: widget.indexWidth,
        start: ListView(
          key: const Key('privacy_index_pane'),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          children: [
            for (final (index, (title, _)) in widget.sections.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: ListTile(
                  key: Key('privacy_index_$index'),
                  dense: true,
                  shape: const StadiumBorder(),
                  selected: index == _selected,
                  selectedColor: accent,
                  selectedTileColor: accent.withValues(alpha: 0.10),
                  textColor: colors.onSurfaceMuted,
                  title: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodyMedium?.copyWith(
                      color: index == _selected ? accent : null,
                      fontWeight: index == _selected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                  onTap: () => _jumpTo(index),
                ),
              ),
          ],
        ),
        end: SingleChildScrollView(
          controller: _scroll,
          padding: const EdgeInsets.fromLTRB(32, 16, 32, 48),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: _SectionList(sections: widget.sections, keys: _keys),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionList extends StatelessWidget {
  const _SectionList({required this.sections, this.keys});

  final List<(String, String)> sections;
  final List<GlobalKey>? keys;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, (title, body)) in sections.indexed) ...[
          if (index > 0) const SizedBox(height: 28),
          _Section(key: keys?[index], title: title, body: body),
        ],
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        Text(body, style: text.bodyLarge?.copyWith(height: 1.55)),
      ],
    );
  }
}
