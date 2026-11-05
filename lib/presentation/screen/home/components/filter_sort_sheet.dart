import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lingua_pages/domain/entity/document/document_models.dart';
import 'package:lingua_pages/domain/entity/library/book_entity.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_cubit.dart';
import 'package:lingua_pages/presentation/screen/home/cubits/library_state.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';

Future<void> showFilterSortSheet(BuildContext context) {
  final cubit = context.read<LibraryCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: const FilterSortSheet(),
    ),
  );
}

class FilterSortSheet extends StatefulWidget {
  const FilterSortSheet({super.key});

  @override
  State<FilterSortSheet> createState() => _FilterSortSheetState();
}

class _FilterSortSheetState extends State<FilterSortSheet> {
  late LibrarySort _sort;
  late LibraryViewMode _viewMode;
  final Set<DocumentFormat> _selectedFormats = {};

  @override
  void initState() {
    super.initState();
    final state = context.read<LibraryCubit>().state;
    _sort = state.sort;
    _viewMode = state.viewMode;
  }

  void _reset() {
    setState(() {
      _sort = LibrarySort.recent;
      _selectedFormats.clear();
    });
  }

  void _apply() {
    final cubit = context.read<LibraryCubit>();
    if (_sort != cubit.state.sort) {
      cubit.changeSort(_sort);
    }
    if (_viewMode != cubit.state.viewMode) {
      cubit.toggleViewMode();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<LibraryCubit>().state;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: WarmEditorialTokens.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(WarmEditorialTokens.bottomSheetRadiusLarge)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 6),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: WarmEditorialTokens.hairlineDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Sheet Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter & Sort',
                  style: GoogleFonts.newsreader(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: WarmEditorialTokens.textPrimaryInk,
                  ),
                ),
                TextButton(
                  onPressed: _reset,
                  child: Text(
                    'Reset',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: WarmEditorialTokens.subtitleSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
          // Scrollable Options Canvas
          Flexible(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // VIEW MODE TOGGLE
                Text(
                  'VIEW LAYOUT',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: WarmEditorialTokens.subtitleSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: WarmEditorialTokens.canvasBackground,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: () => setState(() => _viewMode = LibraryViewMode.grid),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _viewMode == LibraryViewMode.grid
                                  ? WarmEditorialTokens.cardSurface
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: _viewMode == LibraryViewMode.grid
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.grid_view_rounded,
                                  size: 18,
                                  color: _viewMode == LibraryViewMode.grid
                                      ? WarmEditorialTokens.accentInkBlue
                                      : WarmEditorialTokens.subtitleSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Grid',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _viewMode == LibraryViewMode.grid
                                        ? WarmEditorialTokens.accentInkBlue
                                        : WarmEditorialTokens.subtitleSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: () => setState(() => _viewMode = LibraryViewMode.list),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: _viewMode == LibraryViewMode.list
                                  ? WarmEditorialTokens.cardSurface
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: _viewMode == LibraryViewMode.list
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.view_list_rounded,
                                  size: 18,
                                  color: _viewMode == LibraryViewMode.list
                                      ? WarmEditorialTokens.accentInkBlue
                                      : WarmEditorialTokens.subtitleSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'List',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _viewMode == LibraryViewMode.list
                                        ? WarmEditorialTokens.accentInkBlue
                                        : WarmEditorialTokens.subtitleSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // SORT BY SECTION
                Text(
                  'SORT BY',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: WarmEditorialTokens.subtitleSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: WarmEditorialTokens.cardSurface,
                    borderRadius: BorderRadius.circular(WarmEditorialTokens.cardRadius),
                    border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                  ),
                  child: Column(
                    children: [
                      _sortOption(
                        title: 'Recently read',
                        icon: Icons.history_rounded,
                        value: LibrarySort.recent,
                      ),
                      const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                      _sortOption(
                        title: 'Title',
                        icon: Icons.sort_by_alpha_rounded,
                        value: LibrarySort.title,
                      ),
                      const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                      _sortOption(
                        title: 'Author',
                        icon: Icons.person_outline_rounded,
                        value: LibrarySort.author,
                      ),
                      const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                      _sortOption(
                        title: 'Progress',
                        icon: Icons.donut_large_rounded,
                        value: LibrarySort.progress,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // FORMAT FILTER SECTION
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FORMAT',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: WarmEditorialTokens.subtitleSecondary,
                      ),
                    ),
                    if (_selectedFormats.isNotEmpty)
                      Text(
                        '${_selectedFormats.length} selected',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: WarmEditorialTokens.subtitleSecondary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final (format, label) in [
                      (DocumentFormat.epub, 'EPUB'),
                      (DocumentFormat.pdf, 'PDF'),
                      (DocumentFormat.txt, 'TXT'),
                      (DocumentFormat.markdown, 'Markdown'),
                      (DocumentFormat.html, 'HTML'),
                      (DocumentFormat.fb2, 'FB2'),
                    ])
                      FilterChip(
                        label: Text(label),
                        selected: _selectedFormats.contains(format),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedFormats.add(format);
                            } else {
                              _selectedFormats.remove(format);
                            }
                          });
                        },
                        selectedColor: WarmEditorialTokens.accentInkBlue,
                        checkmarkColor: Colors.white,
                        labelStyle: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _selectedFormats.contains(format)
                              ? Colors.white
                              : WarmEditorialTokens.textPrimaryInk,
                        ),
                        backgroundColor: WarmEditorialTokens.cardSurface,
                        shape: const StadiumBorder(
                          side: BorderSide(color: WarmEditorialTokens.hairlineDivider),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                // BROWSE BY SECTION
                Text(
                  'BROWSE BY',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                    color: WarmEditorialTokens.subtitleSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: WarmEditorialTokens.cardSurface,
                    borderRadius: BorderRadius.circular(WarmEditorialTokens.cardRadius),
                    border: Border.all(color: WarmEditorialTokens.hairlineDivider),
                  ),
                  child: Column(
                    children: [
                      _browseItem(
                        icon: Icons.person_outline_rounded,
                        title: 'Authors',
                        count: state.authorGroups.length,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.read<LibraryCubit>().selectView(LibraryView.authors);
                        },
                      ),
                      const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                      _browseItem(
                        icon: Icons.collections_bookmark_outlined,
                        title: 'Series',
                        count: state.seriesGroups.length,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.read<LibraryCubit>().selectView(LibraryView.series);
                        },
                      ),
                      const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                      _browseItem(
                        icon: Icons.folder_open_outlined,
                        title: 'Collections',
                        count: state.collections.length,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.read<LibraryCubit>().selectView(LibraryView.collection);
                        },
                      ),
                      const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                      _browseItem(
                        icon: Icons.edit_note_rounded,
                        title: 'All annotations',
                        count: null,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.router.push(const AnnotationsRoute());
                        },
                      ),
                      const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),
                      _browseItem(
                        icon: Icons.delete_outline_rounded,
                        title: 'Trash',
                        count: state.trash.length,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.read<LibraryCubit>().selectView(LibraryView.trash);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Sticky Bottom Apply Button
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.paddingOf(context).bottom + 16,
            ),
            decoration: const BoxDecoration(
              color: WarmEditorialTokens.cardSurface,
              border: Border(top: BorderSide(color: WarmEditorialTokens.hairlineDivider)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                key: const Key('apply_filter_sort_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: WarmEditorialTokens.accentInkBlue,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                ),
                onPressed: _apply,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Apply Filters',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sortOption({
    required String title,
    required IconData icon,
    required LibrarySort value,
  }) {
    final isSelected = _sort == value;
    return InkWell(
      onTap: () => setState(() => _sort = value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? WarmEditorialTokens.accentInkBlue : WarmEditorialTokens.subtitleSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: WarmEditorialTokens.textPrimaryInk,
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? WarmEditorialTokens.accentInkBlue : WarmEditorialTokens.hairlineDivider,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _browseItem({
    required IconData icon,
    required String title,
    required int? count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: WarmEditorialTokens.subtitleSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: WarmEditorialTokens.textPrimaryInk,
                ),
              ),
            ),
            if (count != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: WarmEditorialTokens.canvasBackground,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  count.toString(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: WarmEditorialTokens.subtitleSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: WarmEditorialTokens.subtitleSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
