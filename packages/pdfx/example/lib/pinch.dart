import 'package:flutter/material.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';
import 'package:universal_platform/universal_platform.dart';

class PinchPage extends StatefulWidget {
  const PinchPage({Key? key}) : super(key: key);

  @override
  State<PinchPage> createState() => _PinchPageState();
}

enum DocShown { sample, tutorial, hello, password }

class _PinchPageState extends State<PinchPage> {
  static const int _initialPage = 1;
  DocShown _showing = DocShown.sample;
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
        title: const Text('Pdfx example'),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              switch (_showing) {
                case DocShown.sample:
                case DocShown.tutorial:
                  _pdfControllerPinch.loadDocument(
                      PdfDocument.openAsset('assets/flutter_tutorial.pdf'));
                  _showing = DocShown.hello;
                  break;
                case DocShown.hello:
                  _pdfControllerPinch
                      .loadDocument(PdfDocument.openAsset('assets/hello.pdf'));
                  _showing = UniversalPlatform.isWeb
                      ? DocShown.password
                      : DocShown.tutorial;
                  break;

                case DocShown.password:
                  _pdfControllerPinch.loadDocument(PdfDocument.openAsset(
                    'assets/password.pdf',
                    password: 'MyPassword',
                  ));
                  _showing = DocShown.tutorial;
                  break;
              }
            },
          )
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
