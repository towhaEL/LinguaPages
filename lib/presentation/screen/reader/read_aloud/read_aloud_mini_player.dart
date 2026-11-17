import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lingua_pages/core/injector/injector.dart';
import 'package:lingua_pages/presentation/route/app_router.gr.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_player.dart';
import 'package:lingua_pages/presentation/screen/reader/read_aloud/read_aloud_session.dart';

/// Docks the read-aloud player under [child] while a book is being read
/// aloud, on screens other than the reader. Tapping it opens the book.
class ReadAloudMiniPlayerHost extends StatelessWidget {
  const ReadAloudMiniPlayerHost({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final session = injector<ReadAloudSession>();
    return ListenableBuilder(
      listenable: session,
      child: child,
      builder: (context, child) {
        final book = session.book;
        final cubit = session.cubit;
        if (!session.active || book == null || cubit == null) return child!;
        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            children: [
              // The player takes the bottom inset, so the page above does
              // not pad for it twice.
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  child: child!,
                ),
              ),
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                child: BlocProvider.value(
                  value: cubit,
                  child: ValueListenableBuilder<double>(
                    valueListenable: session.progressListenable,
                    builder: (context, progress, _) => ReadAloudPlayer(
                      key: const Key('read_aloud_mini_player'),
                      book: book,
                      progress: progress,
                      onTap: () => openReadAloudBook(context),
                      onOpenVoiceSettings: () =>
                          session.service?.openVoiceSettings(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Shows the book being read aloud: back to its reader if one is open
/// further down, in place of another book's reader, or newly opened.
Future<void> openReadAloudBook(BuildContext context) async {
  final book = injector<ReadAloudSession>().book;
  if (book == null) return;
  final router = context.router.root;
  final stack = router.stackData;
  bool readsBook(RouteData data) =>
      data.name == ReaderRoute.name &&
      data.argsAs<ReaderRouteArgs>().book.id == book.id;
  final index = stack.lastIndexWhere(readsBook);
  if (index >= 0) {
    var pops = stack.length - 1 - index;
    router.popUntil((_) => pops-- <= 0);
    return;
  }
  if (stack.isNotEmpty && stack.last.name == ReaderRoute.name) {
    await router.replace(ReaderRoute(book: book));
  } else {
    await router.push(ReaderRoute(book: book));
  }
}
