import 'package:explorer/src/data/models/entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

IconData iconByEntry(Entry entry) {
  if (entry is ExplorerDirectory) {
    return Icons.folder;
  }
  switch (entry.extension) {
    case 'db':
    case 'sqlite':
    case 'sqlite3':
      return Icons.image;
    case 'jpg':
    case 'jpeg':
    case 'png':
      return Icons.image;
    default:
      return Icons.description;
  }
}
