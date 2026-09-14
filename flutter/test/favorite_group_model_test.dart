import 'dart:convert';

import 'package:flutter_hbb/models/favorite_group_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('creates groups and assigns favorite peers', () {
    var stored = '';
    final model = FavoriteGroupModel(
      read: () => stored,
      write: (value) => stored = value,
    );

    expect(model.createGroup(' 办公室 '), isTrue);
    expect(model.createGroup('办公室'), isFalse);
    expect(model.createGroup('a' * 33), isFalse);
    expect(model.groups.single.name, '办公室');

    final groupId = model.groups.single.id;
    model.setPeerGroup('peer-1', groupId);

    expect(model.matches('peer-1', groupId), isTrue);
    expect(model.matches('peer-1', favoriteUngroupedId), isFalse);
    expect(model.countForGroup(['peer-1', 'peer-2'], groupId), 1);
    expect(model.countForGroup(['peer-1', 'peer-2'], favoriteUngroupedId), 1);
    expect(jsonDecode(stored)['version'], 1);
  });

  test('deleting a group keeps its peers as ungrouped favorites', () {
    var stored = '';
    final model = FavoriteGroupModel(
      read: () => stored,
      write: (value) => stored = value,
    );

    model.createGroup('服务器');
    final groupId = model.groups.single.id;
    model.setPeerGroup('peer-1', groupId);

    expect(model.deleteGroup(groupId), isTrue);
    expect(model.groups, isEmpty);
    expect(model.groupIdForPeer('peer-1'), isNull);
    expect(model.matches('peer-1', favoriteUngroupedId), isTrue);
  });

  test('loads valid data and ignores invalid group references', () {
    final stored = jsonEncode({
      'version': 1,
      'groups': [
        {'id': 'office', 'name': '办公室'},
      ],
      'peer_groups': {'peer-1': 'office', 'peer-2': 'missing'},
    });
    final model = FavoriteGroupModel(read: () => stored, write: (_) {});

    model.load();

    expect(model.groups.single.name, '办公室');
    expect(model.groupIdForPeer('peer-1'), 'office');
    expect(model.groupIdForPeer('peer-2'), isNull);
  });
}
