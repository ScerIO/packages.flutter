import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/src/renderer/rgba_data.dart';
import 'package:pdfx/src/renderer/web/rgba_data.dart';
import 'package:web/web.dart' as web;

class PdfTexture extends StatefulWidget {
  const PdfTexture({
    super.key,
    required this.textureId,
  });

  final int textureId;

  @override
  State<PdfTexture> createState() => _PdfTextureState();

  RgbaData? get data =>
      (web.window.getProperty('pdfx_texture_$textureId'.toJS) as JSRgbaData?)
          ?.toDart;
}

class _PdfTextureState extends State<PdfTexture> {
  ui.Image? _image;
  bool _firstBuild = true;

  @override
  void initState() {
    super.initState();
    _WebTextureManager.instance.register(widget.textureId, this);
  }

  @override
  void dispose() {
    _WebTextureManager.instance.unregister(widget.textureId, this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PdfTexture oldWidget) {
    if (oldWidget.textureId != widget.textureId) {
      _WebTextureManager.instance.unregister(oldWidget.textureId, this);
      _WebTextureManager.instance.register(widget.textureId, this);
      _image = null;
      _requestUpdate();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    if (_firstBuild) {
      _firstBuild = false;
      Future.delayed(Duration.zero, _requestUpdate);
    }
    return RawImage(
      image: _image,
      alignment: Alignment.topLeft,
      fit: BoxFit.fill,
    );
  }

  Future<void> _requestUpdate() async {
    final data = widget.data;
    if (data != null) {
      final codec = await ui.instantiateImageCodec(data.data);
      final frame = await codec.getNextFrame();

      _image = frame.image;
    } else {
      _image = null;
    }
    if (mounted) {
      setState(() {});
    }
  }
}

class RawImageStreamCompleter extends ImageStreamCompleter {
  RawImageStreamCompleter(ui.Image image) {
    setImage(ImageInfo(image: image));
  }
}

/// Receiving WebTexture update event from JS side.
class _WebTextureManager {
  _WebTextureManager._() {
    _events.receiveBroadcastStream().listen((event) {
      if (event is int) {
        notify(event);
      }
    });
  }

  static final instance = _WebTextureManager._();

  final _id2states = <int, List<_PdfTextureState>>{};
  final _events = const EventChannel('io.scer.pdf_renderer/web_events');

  void register(int id, _PdfTextureState state) =>
      _id2states.putIfAbsent(id, () => []).add(state);

  void unregister(int id, _PdfTextureState state) {
    final states = _id2states[id];
    if (states != null) {
      if (states.remove(state)) {
        if (states.isEmpty) {
          _id2states.remove(id);
        }
      }
    }
  }

  void notify(int id) {
    final list = _id2states[id];
    if (list != null) {
      for (final s in list) {
        s._requestUpdate();
      }
    }
  }
}
