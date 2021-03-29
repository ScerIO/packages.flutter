import 'package:intl/intl.dart';

mixin StringResources {
  String get actionMenuOpen => Intl.message('Open', name: 'actionMenuOpen');
  String get actionMenuCopy => Intl.message('Copy', name: 'actionMenuCopy');
  String get actionMenuCut => Intl.message('Cut', name: 'actionMenuCut');
  String get actionMenuDelete =>
      Intl.message('Delete', name: 'actionMenuDelete');
  String get actionCopyHere =>
      Intl.message('Copy here', name: 'actionCopyHere');
  String get actionMoveHere =>
      Intl.message('Move here', name: 'actionMoveHere');

  String get folderName => Intl.message('Folder name', name: 'folderName');
  String get fileName => Intl.message('File name', name: 'fileName');
  String get newFolder => Intl.message('New folder', name: 'newFolder');
  String get newFile => Intl.message('New file', name: 'newFile');
  String get uploadFiles => Intl.message('Upload files', name: 'uploadFiles');

  String get empty => Intl.message('Empty', name: 'empty');
  String get cancel => Intl.message('Cancel', name: 'cancel');
  String get create => Intl.message('Create', name: 'create');
}
