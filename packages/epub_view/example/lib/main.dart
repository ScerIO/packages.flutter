import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:epub_view/epub_view.dart';

// .replaceAll(RegExp(r'<head>.*?<\/head>'), '')
// .replaceAll(RegExp(r'<[^>]*>'), '')

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Epub demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.dark,
        ),
        home: MyHomePage(),
      );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Uint8List> _loadFromAssets(String assetName) async {
    final bytes = await rootBundle.load(assetName);
    return bytes.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: FutureBuilder<EpubBook>(
          future: _loadFromAssets('assets/book.epub').then(EpubReader.readBook),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return EpubReaderView(
                book: snapshot.data,
                headerBuilder: (value) => AppBar(
                  title: Text(
                    'Chapter ${value?.chapter?.Title ?? ''}',
                  ),
                ),
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      );
}
