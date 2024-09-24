/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// ignore_for_file: public_member_api_docs

@JS()
library pdf.js;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:pdfx/src/renderer/web/constants.dart';
import 'package:web/web.dart' as web;

bool checkPdfjsLibInstallation() => _pdfjsLib != null;

@JS('pdfjsLib')
external PdfjsLib? get _pdfjsLib;

@JS("pdfRenderOptions")
external PdfjsRenderOptions? get _pdfRenderOptionsFromContext;

// Safe check
PdfjsRenderOptions get _pdfRenderOptions => _pdfRenderOptionsFromContext ?? Constants.defaultPdfjsRenderOptions;

extension type PdfjsLib(JSObject _) implements JSObject {
  external PdfjsDocumentTask getDocument(PdfjsRenderOptions options);
}

extension type PdfjsDocumentTask(JSObject _) implements JSObject {
  external JSPromise<PdfjsDocument> get promise;
}

extension type PdfjsRenderOptions._(JSObject _) implements JSObject {
  external factory PdfjsRenderOptions.url({
    String cMapUrl,
    bool cMapPacked,
    String url,
    String? password,
  });

  external factory PdfjsRenderOptions.data({
    String cMapUrl,
    bool cMapPacked,
    JSArrayBuffer data,
    String? password,
  });

  external factory PdfjsRenderOptions.constant({
    String cMapUrl,
    bool cMapPacked,
  });

  external String get cMapUrl;
  external bool get cMapPacked;
}

Future<PdfjsDocument> pdfjsGetDocument(
  String url, {
  String? password,
}) async {
  final lib = _pdfjsLib;
  if (lib == null) {
    throw Exception('Pdfjs library not loaded');
  }

  return await lib
      .getDocument(
        PdfjsRenderOptions.url(
          cMapUrl: _pdfRenderOptions.cMapUrl,
          cMapPacked: _pdfRenderOptions.cMapPacked,
          url: url,
          password: password,
        ),
      )
      .promise
      .toDart;
}

Future<PdfjsDocument> pdfjsGetDocumentFromData(
  ByteBuffer data, {
  String? password,
}) async {
  final lib = _pdfjsLib;
  if (lib == null) {
    throw Exception('Pdfjs library not loaded');
  }

  return await lib
      .getDocument(
        PdfjsRenderOptions.data(
          cMapUrl: _pdfRenderOptions.cMapUrl,
          cMapPacked: _pdfRenderOptions.cMapPacked,
          data: data.toJS,
          password: password,
        ),
      )
      .promise
      .toDart;
}

extension type PdfjsDocument(JSObject _) implements JSObject {
  external JSPromise<PdfjsPage> getPage(int pageNumber);

  external int get numPages;

  external void destroy();
}

extension type PdfjsPage(JSObject _) implements JSObject {
  external PdfjsViewport getViewport(PdfjsViewportParams params);

  /// `viewport` for [PdfjsViewport] and `transform` for
  external PdfjsRender render(PdfjsRenderContext params);

  external int get pageNumber;

  external JSArray<JSNumber> get view;
}

extension type PdfjsViewportParams._(JSObject _) implements JSObject {
  external factory PdfjsViewportParams({
    double scale,
    int rotation, // 0, 90, 180, 270
    double offsetX = 0,
    double offsetY = 0,
    bool dontFlip = false,
  });

  external double get scale;

  external set scale(double scale);

  external int get rotation;

  external set rotation(int rotation);

  external double get offsetX;

  external set offsetX(double offsetX);

  external double get offsetY;

  external set offsetY(double offsetY);

  external bool get dontFlip;

  external set dontFlip(bool dontFlip);
}

extension type PdfjsViewport(JSObject _) implements JSObject {
  external JSArray<JSNumber> get viewBox;

  external set viewBox(JSArray<JSNumber> viewBox);

  external double get scale;

  external set scale(double scale);

  /// 0, 90, 180, 270
  external int get rotation;

  external set rotation(int rotation);

  external double get offsetX;

  external set offsetX(double offsetX);

  external double get offsetY;

  external set offsetY(double offsetY);

  external bool get dontFlip;

  external set dontFlip(bool dontFlip);

  external double get width;

  external set width(double w);

  external double get height;

  external set height(double h);

  external JSArray<JSNumber>? get transform;

  external set transform(JSArray<JSNumber>? m);
}

extension type PdfjsRenderContext._(JSObject _) implements JSObject {
  external factory PdfjsRenderContext({
    required web.CanvasRenderingContext2D canvasContext,
    required PdfjsViewport viewport,
    String intent = 'display',
    bool enableWebGL = false,
    bool renderInteractiveForms = false,
    JSArray<JSNumber>? transform,
    JSAny imageLayer,
    JSAny canvasFactory,
    JSAny background,
  });

  external web.CanvasRenderingContext2D get canvasContext;

  external set canvasContext(web.CanvasRenderingContext2D ctx);

  external PdfjsViewport get viewport;

  external set viewport(PdfjsViewport viewport);

  external String get intent;

  /// `display` or `print`
  external set intent(String intent);

  external bool get enableWebGL;

  external set enableWebGL(bool enableWebGL);

  external bool get renderInteractiveForms;

  external set renderInteractiveForms(bool renderInteractiveForms);

  external JSArray<JSNumber>? get transform;

  external set transform(JSArray<JSNumber>? transform);

  external JSAny get imageLayer;

  external set imageLayer(JSAny imageLayer);

  external JSAny get canvasFactory;

  external set canvasFactory(JSAny canvasFactory);

  external JSAny get background;

  external set background(JSAny background);
}

extension type PdfjsRender(JSObject _) implements JSObject {
  external JSPromise get promise;
}
