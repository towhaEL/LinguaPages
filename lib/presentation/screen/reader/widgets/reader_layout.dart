import 'package:flutter/widgets.dart';

/// Below this height (a phone on its side) the reader's chrome and sheets
/// trade decoration for page: no drag handles, icon-only tools, sheets that
/// may take nearly the whole height.
const _compactHeight = 480.0;

/// Widest the bottom bar's controls grow on a tablet, so the progress bar
/// and tools stay within a thumb's reach instead of spanning the screen.
const readerControlsMaxWidth = 720.0;

bool isReaderCompact(BuildContext context) =>
    MediaQuery.sizeOf(context).height < _compactHeight;

/// Height for a sheet that takes [fraction] of a portrait screen. On a short
/// landscape screen a fraction would leave too little room, so the sheet may
/// take almost all of it.
double readerSheetHeight(BuildContext context, double fraction) {
  final height = MediaQuery.sizeOf(context).height;
  return height < _compactHeight ? height * 0.92 : height * fraction;
}
