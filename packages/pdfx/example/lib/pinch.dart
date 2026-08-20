import 'package:flutter/material.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';

class PinchPage extends StatefulWidget {
  const PinchPage({Key? key}) : super(key: key);

  @override
  State<PinchPage> createState() => _PinchPageState();
}

class _PinchPageState extends State<PinchPage> {
  static const int _initialPage = 1;
  String _title = 'Sample PDF';
  late PdfControllerPinch _pdfControllerPinch;

  @override
  void initState() {
    _pdfControllerPinch = PdfControllerPinch(
      // document: PdfDocument.openAsset('assets/hello.pdf'),
      document: PdfDocument.openData(
        InternetFile.get(
          "https://cdn.filestackcontent.com/wcrjf9qPTCKXV3hMXDwK",
        ),
      ),
      initialPage: _initialPage,
    );
    super.initState();
  }

  @override
  void dispose() {
    _pdfControllerPinch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        title: Text(_title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.navigate_before),
            onPressed: () {
              _pdfControllerPinch.previousPage(
                curve: Curves.ease,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
          PdfPageNumber(
            controller: _pdfControllerPinch,
            builder: (_, loadingState, page, pagesCount) => Container(
              alignment: Alignment.center,
              child: Text(
                '$page/${pagesCount ?? 0}',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            onPressed: () {
              _pdfControllerPinch.nextPage(
                curve: Curves.ease,
                duration: const Duration(milliseconds: 100),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.file_open),
            onSelected: (String asset) {
              String title;
              switch (asset) {
                case 'assets/hello.pdf':
                  title = 'Hello PDF';
                  break;
                case 'assets/flutter_tutorial.pdf':
                  title = 'Flutter Tutorial';
                  break;
                case 'assets/password.pdf':
                  title = 'Password Protected PDF';
                  break;
                default:
                  title = 'Pdfx example';
              }
              setState(() {
                _title = title;
              });
              String? password;
              if (asset == 'assets/password.pdf') {
                password = 'MyPassword';
              }
              _pdfControllerPinch.loadDocument(
                PdfDocument.openAsset(asset, password: password),
              );
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'assets/hello.pdf',
                child: Text('Hello PDF'),
              ),
              const PopupMenuItem<String>(
                value: 'assets/flutter_tutorial.pdf',
                child: Text('Flutter Tutorial'),
              ),
              const PopupMenuItem<String>(
                value: 'assets/password.pdf',
                child: Text('Password Protected'),
              ),
            ],
          ),
        ],
      ),
      body: PdfViewPinch(
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          pageLoaderBuilder: (_) =>
              const Center(child: CircularProgressIndicator()),
          errorBuilder: (_, error) => Center(child: Text(error.toString())),
        ),
        controller: _pdfControllerPinch,
      ),
    );
  }
}
