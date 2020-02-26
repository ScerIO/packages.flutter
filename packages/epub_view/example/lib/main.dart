import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:epub_view/epub_view.dart';

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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _epubReaderController = EpubReaderController();

  Future<Uint8List> _loadFromAssets(String assetName) async {
    final bytes = await rootBundle.load(assetName);
    return bytes.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        body: FutureBuilder<EpubBook>(
          future: _loadFromAssets('assets/book.epub').then(EpubReader.readBook),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return EpubReaderView(
                book: snapshot.data,
                controller: _epubReaderController,
                epubCfi:
                    'epubcfi(/6/26[id4]!/4/2/2[id4]/22)', // Chapter 3 paragraph 10
                headerBuilder: (value) => AppBar(
                  title: Text(
                    'Chapter ${value?.chapter?.Title ?? ''}',
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.save_alt),
                      color: Colors.white,
                      onPressed: () =>
                          _showCurrentEpubCfi(context, snapshot.data),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      );

  void _showCurrentEpubCfi(context, EpubBook book) {
    final cfi = _epubReaderController.generateEpubCfi();

    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(cfi),
        ),
      );
  }
}
