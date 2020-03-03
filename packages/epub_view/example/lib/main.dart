import 'dart:math';
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
          future:
              _loadFromAssets('assets/book_3.epub').then(EpubReader.readBook),
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return EpubReaderView(
                book: snapshot.data,
                controller: _epubReaderController,
                excludeHeaders: true,
                // startFrom: EpubReaderLastPosition.fromString('52:0:0'),
                // epubCfi:
                //     'epubcfi(/6/26[id4]!/4/2/2[id4]/22)', // book.epub Chapter 3 paragraph 10
                // epubCfi:
                //     'epubcfi(/6/6[chapter-2]!/4/2/1612)', // book_2.epub Chapter 16 paragraph 3
                epubCfi:
                    'epubcfi(/6/6[chapter-2]!/4/2/134)', // book_3.epub Chapter 2 paragraph 6
                headerBuilder: (value) => AppBar(
                  title: Text(
                    'Chapter: ${value?.chapter?.Title ?? ''}',
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.touch_app),
                      color: Colors.white,
                      onPressed: () => _scrollToChapter(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.save_alt),
                      color: Colors.white,
                      onPressed: () => _showCurrentEpubCfi(context),
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

  void _showCurrentEpubCfi(context) {
    final cfi = _epubReaderController.generateEpubCfi();

    if (cfi != null) {
      _scaffoldKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(cfi),
          ),
        );
    }
  }

  void _scrollToChapter(context) {
    final toc = _epubReaderController.tableOfContents();
    final randomChapterIndex = Random().nextInt(toc.length);
    _epubReaderController.scrollTo(index: toc[randomChapterIndex].startIndex);

    _scaffoldKey.currentState
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(toc[randomChapterIndex].title ?? ''),
        ),
      );
  }
}
