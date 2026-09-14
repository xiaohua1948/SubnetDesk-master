import 'dart:convert';

import 'package:flutter_hbb/desktop/lan_identity_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LAN identity profiles', () {
    test('parses metadata without a password field', () {
      final identity = LanIdentityProfile.fromJson({
        'id': 'identity-id',
        'name': 'Operations',
        'username': 'operator',
        'is_default': true,
        'password': 'must-not-be-used',
      });

      expect(identity.id, 'identity-id');
      expect(identity.name, 'Operations');
      expect(identity.username, 'operator');
      expect(identity.isDefault, isTrue);
    });

    test('finds the default identity', () {
      const identities = [
        LanIdentityProfile(
          id: 'first',
          name: 'First',
          username: 'first-user',
          isDefault: false,
        ),
        LanIdentityProfile(
          id: 'default',
          name: 'Default',
          username: 'operator',
          isDefault: true,
        ),
      ];

      expect(defaultLanIdentityId(identities), 'default');
      expect(defaultLanIdentityId(const []), isNull);
    });

    test('connection payload contains only identity selection metadata', () {
      final payload =
          jsonDecode(buildLanIdentityPayload('identity-id', bindIdentity: true))
              as Map<String, dynamic>;

      expect(payload, {
        'lan_version': 1,
        'identity_id': 'identity-id',
        'bind_identity': true,
      });
      expect(payload.containsKey('username'), isFalse);
      expect(payload.containsKey('password'), isFalse);
    });
  });
}
