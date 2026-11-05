import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

abstract final class CustomFinders {
  /// Finds widgets that use a StadiumBorder shape.
  static Finder stadiumBorderWidget() {
    return find.byWidgetPredicate((widget) {
      if (widget is Chip && widget.shape is StadiumBorder) return true;
      if (widget is RawChip && widget.shape is StadiumBorder) return true;
      if (widget is ActionChip && widget.shape is StadiumBorder) return true;
      if (widget is ChoiceChip && widget.shape is StadiumBorder) return true;
      if (widget is FilterChip && widget.shape is StadiumBorder) return true;
      if (widget is OutlinedButton) {
        final shape = widget.style?.shape?.resolve({});
        if (shape is StadiumBorder) return true;
      }
      if (widget is FilledButton) {
        final shape = widget.style?.shape?.resolve({});
        if (shape is StadiumBorder) return true;
      }
      if (widget is Material && widget.shape is StadiumBorder) return true;
      return false;
    });
  }

  /// Finds widgets with a specific background color.
  static Finder withBackgroundColor(Color color) {
    return find.byWidgetPredicate((widget) {
      if (widget is ColoredBox && widget.color == color) return true;
      if (widget is Container) {
        final decoration = widget.decoration;
        if (decoration is BoxDecoration && decoration.color == color) return true;
      }
      if (widget is Material && widget.color == color) return true;
      return false;
    });
  }

  /// Finds text that uses a specific font family.
  static Finder textWithFontFamily(String fontFamily) {
    return find.byWidgetPredicate((widget) {
      if (widget is Text) {
        final style = widget.style;
        if (style?.fontFamily == fontFamily) return true;
      }
      if (widget is RichText) {
        if (widget.text.style?.fontFamily == fontFamily) return true;
      }
      return false;
    });
  }

  /// Finds Card or Material widgets with a specific corner radius.
  static Finder cardWithRadius(double radius) {
    return find.byWidgetPredicate((widget) {
      if (widget is Card) {
        final shape = widget.shape;
        if (shape is RoundedRectangleBorder &&
            shape.borderRadius == BorderRadius.circular(radius)) {
          return true;
        }
      }
      if (widget is Material && widget.type == MaterialType.card) {
        final shape = widget.shape;
        if (shape is RoundedRectangleBorder &&
            shape.borderRadius == BorderRadius.circular(radius)) {
          return true;
        }
      }
      return false;
    });
  }
}
