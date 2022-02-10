import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

const Uuid uuid = Uuid();

abstract class Repository<T> {
  final _items = <String?, T>{};

  T? get(String? id) {
    if (!_exist(id)) {
      throw RepositoryItemNotFoundException();
    }
    return _items[id];
  }

  void set(String? id, T item) {
    _items[id] = item;
  }

  bool _exist(String? id) => _items.containsKey(id);

  @protected
  void close(String? id) {
    _items.remove(id);
  }
}

class RepositoryItemNotFoundException implements Exception {}
