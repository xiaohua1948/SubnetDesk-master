import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_hbb/consts.dart';
import 'package:flutter_hbb/models/platform_model.dart';

const String favoriteUngroupedId = '__ungrouped__';

String normalizeFavoriteGroupName(String value) => value.trim();

class FavoriteGroup {
  const FavoriteGroup({required this.id, required this.name});

  final String id;
  final String name;

  Map<String, String> toJson() => {'id': id, 'name': name};
}

class FavoriteGroupModel extends ChangeNotifier {
  FavoriteGroupModel({
    String Function()? read,
    void Function(String value)? write,
  }) : _read =
           read ??
           (() => bind.getLocalFlutterOption(k: kOptionFavoritePeerGroups)),
       _write =
           write ??
           ((value) => bind.setLocalFlutterOption(
             k: kOptionFavoritePeerGroups,
             v: value,
           ));

  final String Function() _read;
  final void Function(String value) _write;

  final List<FavoriteGroup> _groups = [];
  final Map<String, String> _peerGroups = {};
  bool _loaded = false;
  int _nextId = 0;

  List<FavoriteGroup> get groups => List.unmodifiable(_groups);

  void load() {
    if (_loaded) return;
    _loaded = true;

    final raw = _read();
    if (raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('favorite group data is not an object');
      }

      final groupIds = <String>{};
      final groupNames = <String>{};
      final rawGroups = decoded['groups'];
      if (rawGroups is List) {
        for (final item in rawGroups) {
          if (item is! Map) continue;
          final id = item['id'];
          final name = item['name'];
          if (id is! String || name is! String) continue;
          final normalizedName = normalizeFavoriteGroupName(name);
          final normalizedKey = normalizedName.toLowerCase();
          if (id.isEmpty ||
              normalizedName.isEmpty ||
              groupIds.contains(id) ||
              groupNames.contains(normalizedKey)) {
            continue;
          }
          groupIds.add(id);
          groupNames.add(normalizedKey);
          _groups.add(FavoriteGroup(id: id, name: normalizedName));
        }
      }

      final rawPeerGroups = decoded['peer_groups'];
      if (rawPeerGroups is Map) {
        for (final entry in rawPeerGroups.entries) {
          final peerId = entry.key;
          final groupId = entry.value;
          if (peerId is String &&
              peerId.isNotEmpty &&
              groupId is String &&
              groupIds.contains(groupId)) {
            _peerGroups[peerId] = groupId;
          }
        }
      }
    } catch (error) {
      _groups.clear();
      _peerGroups.clear();
      debugPrint('failed to load favorite peer groups: $error');
    }
  }

  bool createGroup(String value) {
    load();
    final name = normalizeFavoriteGroupName(value);
    if (name.isEmpty || name.runes.length > 32 || _containsName(name)) {
      return false;
    }

    var id = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    while (_groups.any((group) => group.id == id)) {
      id = '${id}_${_nextId++}';
    }
    _groups.add(FavoriteGroup(id: id, name: name));
    _saveAndNotify();
    return true;
  }

  bool renameGroup(String id, String value) {
    load();
    final index = _groups.indexWhere((group) => group.id == id);
    final name = normalizeFavoriteGroupName(value);
    if (index < 0 ||
        name.isEmpty ||
        name.runes.length > 32 ||
        _containsName(name, exceptGroupId: id)) {
      return false;
    }
    if (_groups[index].name == name) return true;

    _groups[index] = FavoriteGroup(id: id, name: name);
    _saveAndNotify();
    return true;
  }

  bool deleteGroup(String id) {
    load();
    if (!_groups.any((group) => group.id == id)) return false;
    _groups.removeWhere((group) => group.id == id);

    _peerGroups.removeWhere((_, groupId) => groupId == id);
    _saveAndNotify();
    return true;
  }

  void setPeerGroup(String peerId, String? groupId) {
    load();
    if (peerId.isEmpty) return;

    if (groupId == null || groupId == favoriteUngroupedId) {
      if (_peerGroups.remove(peerId) != null) {
        _saveAndNotify();
      }
      return;
    }
    if (!_groups.any((group) => group.id == groupId) ||
        _peerGroups[peerId] == groupId) {
      return;
    }
    _peerGroups[peerId] = groupId;
    _saveAndNotify();
  }

  void removePeer(String peerId) {
    load();
    if (_peerGroups.remove(peerId) != null) {
      _saveAndNotify();
    }
  }

  String? groupIdForPeer(String peerId) {
    load();
    return _peerGroups[peerId];
  }

  FavoriteGroup? groupById(String id) {
    load();
    for (final group in _groups) {
      if (group.id == id) return group;
    }
    return null;
  }

  bool matches(String peerId, String? selectedGroupId) {
    load();
    if (selectedGroupId == null) return true;
    if (selectedGroupId == favoriteUngroupedId) {
      return !_peerGroups.containsKey(peerId);
    }
    return _peerGroups[peerId] == selectedGroupId;
  }

  int countForGroup(Iterable<String> favoritePeerIds, String? groupId) {
    load();
    return favoritePeerIds.where((peerId) => matches(peerId, groupId)).length;
  }

  bool _containsName(String name, {String? exceptGroupId}) {
    final normalized = name.toLowerCase();
    return _groups.any(
      (group) =>
          group.id != exceptGroupId && group.name.toLowerCase() == normalized,
    );
  }

  void _saveAndNotify() {
    _write(
      jsonEncode({
        'version': 1,
        'groups': _groups.map((group) => group.toJson()).toList(),
        'peer_groups': _peerGroups,
      }),
    );
    notifyListeners();
  }
}

final favoriteGroupModel = FavoriteGroupModel();
