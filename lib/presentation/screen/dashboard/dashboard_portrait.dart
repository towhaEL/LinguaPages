import 'package:flutter/material.dart';

class DashboardPortrait extends StatelessWidget {
  final Widget child;

  const DashboardPortrait({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: child,
    );
  }
}

