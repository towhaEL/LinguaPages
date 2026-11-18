part of "widgets.dart";

/// A fixed-width side pane beside a flexible main pane, split by a hairline.
/// The shared shape of the landscape and tablet layouts: navigation, filters
/// or a summary on the start side; the content itself on the end side.
class TwoPane extends StatelessWidget {
  const TwoPane({
    super.key,
    required this.start,
    required this.end,
    this.startWidth = 320,
  });

  final Widget start;
  final Widget end;
  final double startWidth;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: startWidth, child: start),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).dividerColor,
        ),
        Expanded(child: end),
      ],
    );
  }
}
