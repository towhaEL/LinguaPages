import 'dart:async';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:lingua_pages/domain/service/document_import_service.dart';

@LazySingleton(as: IncomingDocumentService)
class PlatformIncomingDocumentService implements IncomingDocumentService {
  PlatformIncomingDocumentService() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  static const _channel = MethodChannel('lingua_pages/incoming_documents');

  final StreamController<IncomingDocument> _documents =
      StreamController<IncomingDocument>.broadcast(sync: true);

  @override
  Stream<IncomingDocument> get documents => _documents.stream;

  @override
  Future<IncomingDocument?> takeInitialDocument() async {
    try {
      final result = await _channel.invokeMethod<Object?>('getInitialDocument');
      return _fromArguments(result);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<void> _handleMethodCall(MethodCall call) async {
    if (call.method != 'incomingDocument') return;
    final document = _fromArguments(call.arguments);
    if (document != null) _documents.add(document);
  }

  IncomingDocument? _fromArguments(Object? arguments) {
    if (arguments is! Map) return null;
    final path = arguments['path'];
    final fileName = arguments['fileName'];
    if (path is! String || path.isEmpty || fileName is! String) return null;
    return IncomingDocument(path: path, fileName: fileName);
  }
}
