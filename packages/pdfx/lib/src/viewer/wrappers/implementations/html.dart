// Dummy implementation for artifacts defined in dart:html.

import 'dart:typed_data';

HtmlElement? querySelector(String query) => throw UnimplementedError();

abstract class HtmlElement {
  List<HtmlElement> get children;
}

abstract class CanvasElement extends HtmlElement {
  CanvasRenderingContext2D get context2D;
  int? get width;
  set width(int? width);
  int? get height;
  set height(int? height);
}

abstract class CanvasRenderingContext2D {
  ImageData getImageData(int x, int y, int w, int h);
  String get fillStyle;
  set fillStyle(String fillStyle);
  void fillRect(int x, int y, int w, int h);
}

abstract class ImageData {
  Uint8ClampedList get data;
  int get height;
  int get width;
}

final window = {};

class HtmlDocument {
  HtmlDocument._();
  HtmlElement createElement(String name) => throw UnimplementedError();
}

final document = HtmlDocument._();

abstract class ScriptElement extends HtmlElement {
  factory ScriptElement() => throw UnimplementedError();
  set type(String s);
  set charset(String s);
  set async(bool f);
  set src(String s);
  set innerText(String s);
  Stream<dynamic> get onLoad;
}
