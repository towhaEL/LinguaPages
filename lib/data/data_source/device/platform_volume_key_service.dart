import 'dart:async';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/service/volume_key_service.dart';

/// Android `MainActivity` key hook; other platforms have no channel, so the
/// keys keep their system behaviour.
@LazySingleton(as: VolumeKeyService)
class PlatformVolumeKeyService implements VolumeKeyService {
  PlatformVolumeKeyService() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static const _channel = MethodChannel('lingua_pages/volume_keys');

  final _pageTurns = StreamController<PageTurn>.broadcast(sync: true);

  @override
  Stream<PageTurn> get pageTurns => _pageTurns.stream;

  @override
  Future<void> setEnabled({required bool enabled}) async {
    try {
      await _channel.invokeMethod<void>('setEnabled', enabled);
    } on MissingPluginException {
      // Not Android.
    } on PlatformException {
      // The keys then keep changing the volume; reading is unaffected.
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method != 'pageTurn') return;
    switch (call.arguments) {
      case 'next':
        _pageTurns.add(PageTurn.next);
      case 'previous':
        _pageTurns.add(PageTurn.previous);
    }
  }
}
