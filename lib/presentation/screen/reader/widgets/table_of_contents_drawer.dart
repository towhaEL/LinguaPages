import 'package:flutter/material.dart';
import 'package:lingua_pages/presentation/theme/app_tokens.dart';
import 'package:lingua_pages/presentation/theme/base/theme_extension.dart';

/// Clean slide-in Table of Contents drawer.
class TableOfContentsDrawer extends StatelessWidget {
  const TableOfContentsDrawer({
    required this.tableOfContents,
    required this.activeChapterIndex,
    required this.onChapterSelected,
    super.key,
  });

  final List<String> tableOfContents;
  final int activeChapterIndex;
  final ValueChanged<int> onChapterSelected;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.82;

    return Material(
      color: WarmEditorialTokens.canvasBackground,
      child: SafeArea(
        child: SizedBox(
          width: width.clamp(280.0, 380.0),
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: WarmEditorialTokens.subtitleSecondary),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Contents',
                        style: TextStyle(
                          fontFamily: 'Newsreader',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: WarmEditorialTokens.textPrimaryInk,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: WarmEditorialTokens.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${tableOfContents.length} ${tableOfContents.length == 1 ? 'chapter' : 'chapters'}',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: WarmEditorialTokens.subtitleSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: WarmEditorialTokens.hairlineDivider),

              // Chapter List
              Expanded(
                child: tableOfContents.isEmpty
                    ? const Center(
                        child: Text(
                          'No table of contents available',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: WarmEditorialTokens.subtitleSecondary,
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: tableOfContents.length,
                        itemBuilder: (context, index) {
                          final chapter = tableOfContents[index];
                          final isActive = index == activeChapterIndex;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                onChapterSelected(index);
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isActive ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                  border: isActive
                                      ? Border.all(
                                          color: context.accent.withValues(alpha: 0.3),
                                          width: 1,
                                        )
                                      : null,
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.04),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  children: [
                                    if (isActive) ...[
                                      Container(
                                        width: 3.5,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: context.accent,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                    ],
                                    Expanded(
                                      child: Text(
                                        chapter.trim().isEmpty ? 'Chapter ${index + 1}' : chapter.trim(),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: isActive ? 'Newsreader' : 'Inter',
                                          fontSize: isActive ? 15 : 14,
                                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                                          color: isActive
                                              ? context.accent
                                              : WarmEditorialTokens.textPrimaryInk,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
