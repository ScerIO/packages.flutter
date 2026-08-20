import 'dart:io';

import 'package:explorer/explorer_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Directory appDocDir = await getApplicationDocumentsDirectory();
  runApp(MyApp(appDocDir: appDocDir));
}

class MyApp extends StatefulWidget {
  const MyApp({
    required this.appDocDir,
    Key? key,
  }) : super(key: key);

  final Directory appDocDir;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ExplorerController _controller;

  @override
  void initState() {
    _controller = ExplorerController(
      provider: IoExplorerProvider(
        entryPath: widget.appDocDir.path,
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void filePressed(ExplorerFile file) {
    if ((file.size ?? 0) > 200000) {
      const snackBar =
          SnackBar(content: Text('Can\'t open files with size > 200kb'));

      // Find the Scaffold in the widget tree and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        localizationsDelegates: const [
          ExplorerLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('ru', ''),
          Locale('fr', ''),
        ],
        home: Scaffold(
          body: Explorer(
            controller: _controller,
            builder: (_) => [
              const ExplorerToolbar(),
              const ExplorerActionView(),
              const ExplorerFilesGridView(),
            ],
            filePressed: filePressed,
          ),
        ),
      );
}
