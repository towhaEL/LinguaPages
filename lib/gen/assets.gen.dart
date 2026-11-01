// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/widgets.dart';

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// Directory path: assets/fonts/eb_garamond
  $AssetsFontsEbGaramondGen get ebGaramond => const $AssetsFontsEbGaramondGen();

  /// Directory path: assets/fonts/figtree
  $AssetsFontsFigtreeGen get figtree => const $AssetsFontsFigtreeGen();

  /// Directory path: assets/fonts/literata
  $AssetsFontsLiterataGen get literata => const $AssetsFontsLiterataGen();

  /// Directory path: assets/fonts/source_serif_4
  $AssetsFontsSourceSerif4Gen get sourceSerif4 =>
      const $AssetsFontsSourceSerif4Gen();
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/Feature Access by Flavor-selection.png
  AssetGenImage get featureAccessByFlavorSelection => const AssetGenImage(
    'assets/images/Feature Access by Flavor-selection.png',
  );

  /// File path: assets/images/explore-icon.svg
  String get exploreIcon => 'assets/images/explore-icon.svg';

  /// File path: assets/images/settings-icon.svg
  String get settingsIcon => 'assets/images/settings-icon.svg';

  /// List of all assets
  List<dynamic> get values => [
    featureAccessByFlavorSelection,
    exploreIcon,
    settingsIcon,
  ];
}

class $AssetsFontsEbGaramondGen {
  const $AssetsFontsEbGaramondGen();

  /// File path: assets/fonts/eb_garamond/OFL.txt
  String get ofl => 'assets/fonts/eb_garamond/OFL.txt';

  /// List of all assets
  List<String> get values => [ofl];
}

class $AssetsFontsFigtreeGen {
  const $AssetsFontsFigtreeGen();

  /// File path: assets/fonts/figtree/OFL.txt
  String get ofl => 'assets/fonts/figtree/OFL.txt';

  /// List of all assets
  List<String> get values => [ofl];
}

class $AssetsFontsLiterataGen {
  const $AssetsFontsLiterataGen();

  /// File path: assets/fonts/literata/OFL.txt
  String get ofl => 'assets/fonts/literata/OFL.txt';

  /// List of all assets
  List<String> get values => [ofl];
}

class $AssetsFontsSourceSerif4Gen {
  const $AssetsFontsSourceSerif4Gen();

  /// File path: assets/fonts/source_serif_4/OFL.txt
  String get ofl => 'assets/fonts/source_serif_4/OFL.txt';

  /// List of all assets
  List<String> get values => [ofl];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}
