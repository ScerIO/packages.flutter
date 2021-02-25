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

/// ignore_for_file: public_member_api_docs

@JS()
library pdf.js;

import 'dart:html';
import 'dart:math';
import 'dart:typed_data';

import 'package:js/js.dart';

@JS('pdfjsLib')
class PdfJs {
  external static PdfJsDocLoader getDocument(Settings data);
}

@anonymous
@JS()
class Settings {
  external set data(Uint8List value);
  external set scale(double value);
  external set canvasContext(CanvasRenderingContext2D value);
  external set viewport(PdfJsViewport value);
  external set cMapUrl(String value);
  external set cMapPacked(bool value);
}

@anonymous
@JS()
class PdfJsDocLoader {
  external Future<PdfJsDoc> get promise;
}

@anonymous
@JS()
class PdfJsDoc {
  external Future<PdfJsPage> getPage(int num);
  external int get numPages;
}

@anonymous
@JS()
class PdfJsPage {
  external PdfJsViewport getViewport(Settings data);
  external Future<List<PdfJsAnnotation>> getAnnotations();
  external PdfJsRender render(Settings data);
  external int get pageNumber;
  external List<num> get view;
}

@anonymous
@JS()
class PdfJsViewport {
  external num get width;
  external num get height;
}

@anonymous
@JS()
class PdfJsRender {
  external Future<void> get promise;
}

@anonymous
@JS()
class PdfJsAnnotation {
  external String get subtype;
  external List<num> get rect;
  external int get annotationFlags;
  external List<num> get color;
  external num get borderWidth;
  external bool get hasAppearance;
  external String get url;
}

extension PdfJsAnnotationEx on PdfJsAnnotation {
  List<num> normalizeRect(List<num> visibleRect) {
    num verticalFit(num rect) => visibleRect[3] - rect + visibleRect[1];
    return [
      min(rect[0], rect[2]),
      min(verticalFit(rect[1]), verticalFit(rect[3])),
      max(rect[0], rect[2]),
      max(verticalFit(rect[1]), verticalFit(rect[3])),
    ];
  }

  Map<String, dynamic> toMapWithNomalizeRect(List<num> visibleRect) => {
        'subtype': subtype,
        'rect': normalizeRect(visibleRect),
        'url': url,
      };
}
