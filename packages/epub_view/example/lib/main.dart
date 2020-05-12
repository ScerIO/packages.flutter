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
  Future<Uint8List> _loadedBook;

  @override
  void initState() {
    _epubReaderController.bookLoadedStream.listen((v) => print('isLoaded: $v'));
    _loadedBook =
        _loadFromAssets('assets/New-Findings-on-Shirdi-Sai-Baba.epub');
    super.initState();
  }

  Future<Uint8List> _loadFromAssets(String assetName) async {
    final bytes = await rootBundle.load(assetName);
    return bytes.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: EpubActualChapter(
            controller: _epubReaderController,
            builder: (chapterValue) => Text(
              'Chapter ${chapterValue?.chapter?.Title?.trim() ?? ''}'
                  .replaceAll('\n', ''),
              textAlign: TextAlign.start,
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save_alt),
              color: Colors.white,
              onPressed: () => _showCurrentEpubCfi(context),
            ),
          ],
        ),
        drawer: Drawer(
          child: EpubReaderTableOfContents(controller: _epubReaderController),
        ),
        body: FutureBuilder<Uint8List>(
          future: _loadedBook,
          builder: (_, snapshot) {
            if (snapshot.hasData) {
              return EpubReaderView.fromBytes(
                bookData: snapshot.data,
                controller: _epubReaderController,
                // epubCfi:
                //     'epubcfi(/6/26[id4]!/4/2/2[id4]/22)', // book.epub Chapter 3 paragraph 10
                // epubCfi:
                //     'epubcfi(/6/6[chapter-2]!/4/2/1612)', // book_2.epub Chapter 16 paragraph 3
                dividerBuilder: (_) => Divider(),
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
            action: SnackBarAction(
              label: 'GO',
              onPressed: () {
                _epubReaderController.gotoEpubCfi(cfi);
              },
            ),
          ),
        );
    }
  }
}
