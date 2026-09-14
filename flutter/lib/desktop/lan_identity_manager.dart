import 'dart:convert';

import 'package:flutter/material.dart';

import '../common.dart';
import '../models/platform_model.dart';

const String lanIdentityManualValue = '__manual__';

class LanIdentityProfile {
  final String id;
  final String name;
  final String username;
  final bool isDefault;

  const LanIdentityProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.isDefault,
  });

  factory LanIdentityProfile.fromJson(Map<String, dynamic> json) {
    return LanIdentityProfile(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      isDefault: json['is_default'] == true,
    );
  }
}

List<LanIdentityProfile> loadLanIdentityProfiles() {
  try {
    final decoded = jsonDecode(bind.mainListLanIdentities());
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(LanIdentityProfile.fromJson)
        .where((identity) => identity.id.isNotEmpty)
        .toList();
  } catch (error) {
    debugPrint('Failed to load LAN identities: $error');
    return const [];
  }
}

String? defaultLanIdentityId(List<LanIdentityProfile> identities) {
  for (final identity in identities) {
    if (identity.isDefault) return identity.id;
  }
  return null;
}

String buildLanIdentityPayload(String identityId, {bool bindIdentity = false}) {
  return jsonEncode({
    'lan_version': 1,
    'identity_id': identityId,
    'bind_identity': bindIdentity,
  });
}

Future<String?> showLanIdentityEditor(
  BuildContext context, {
  LanIdentityProfile? identity,
}) async {
  final nameController = TextEditingController(text: identity?.name ?? '');
  final usernameController = TextEditingController(
    text: identity?.username ?? '',
  );
  final passwordController = TextEditingController();
  var makeDefault = identity?.isDefault ?? false;
  var saving = false;
  var errorText = '';

  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        Future<void> save() async {
          if (saving) return;
          setState(() {
            saving = true;
            errorText = '';
          });

          if (identity == null) {
            final response =
                jsonDecode(
                      bind.mainCreateLanIdentity(
                        name: nameController.text,
                        username: usernameController.text,
                        password: passwordController.text,
                        makeDefault: makeDefault,
                      ),
                    )
                    as Map<String, dynamic>;
            passwordController.clear();
            final error = response['error']?.toString() ?? '';
            final identityId = response['identity_id']?.toString() ?? '';
            if (error.isEmpty && identityId.isNotEmpty) {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(identityId);
              }
              return;
            }
            errorText = error.isEmpty ? translate('Failed') : error;
          } else {
            final error = bind.mainUpdateLanIdentity(
              identityId: identity.id,
              name: nameController.text,
              username: usernameController.text,
              password: passwordController.text,
              makeDefault: makeDefault,
            );
            passwordController.clear();
            if (error.isEmpty) {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop(identity.id);
              }
              return;
            }
            errorText = error;
          }
          if (dialogContext.mounted) {
            setState(() => saving = false);
          }
        }

        return AlertDialog(
          title: Text(
            '${translate(identity == null ? 'Add' : 'Edit')} ${translate('Account')}',
          ),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: translate('Name'),
                    prefixIcon: const Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: usernameController,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: translate('Username'),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: translate('Password'),
                    helperText: identity == null
                        ? null
                        : translate('Leave blank to keep current password'),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                  onSubmitted: (_) => save(),
                ),
                CheckboxListTile(
                  value: makeDefault,
                  onChanged: saving
                      ? null
                      : (value) => setState(() => makeDefault = value == true),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    '${translate('Default')} ${translate('Account')}',
                  ),
                ),
                if (errorText.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      errorText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving
                  ? null
                  : () => Navigator.of(dialogContext).pop(),
              child: Text(translate('Cancel')),
            ),
            ElevatedButton(
              onPressed: saving ? null : save,
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(translate('OK')),
            ),
          ],
        );
      },
    ),
  );

  nameController.dispose();
  usernameController.dispose();
  passwordController.dispose();
  return result;
}

Future<void> showLanIdentityManager(BuildContext context) async {
  var identities = loadLanIdentityProfiles();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        void reload() {
          setState(() => identities = loadLanIdentityProfiles());
        }

        Future<void> addIdentity() async {
          final identityId = await showLanIdentityEditor(context);
          if (identityId != null) reload();
        }

        Future<void> editIdentity(LanIdentityProfile identity) async {
          final identityId = await showLanIdentityEditor(
            context,
            identity: identity,
          );
          if (identityId != null) reload();
        }

        Future<void> deleteIdentity(LanIdentityProfile identity) async {
          final confirmed =
              await showDialog<bool>(
                context: context,
                builder: (confirmContext) => AlertDialog(
                  title: Text(translate('Delete')),
                  content: Text('${translate('Delete')} “${identity.name}”?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(confirmContext).pop(false),
                      child: Text(translate('Cancel')),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(confirmContext).pop(true),
                      child: Text(translate('Delete')),
                    ),
                  ],
                ),
              ) ??
              false;
          if (!confirmed) return;
          final error = bind.mainDeleteLanIdentity(identityId: identity.id);
          if (error.isNotEmpty) {
            showToast(error);
            return;
          }
          reload();
        }

        Future<void> setDefault(LanIdentityProfile identity) async {
          final error = bind.mainSetDefaultLanIdentity(identityId: identity.id);
          if (error.isNotEmpty) {
            showToast(error);
            return;
          }
          reload();
        }

        return AlertDialog(
          title: Text('${translate('Account')} · ${translate('Settings')}'),
          content: SizedBox(
            width: 540,
            height: 360,
            child: identities.isEmpty
                ? Center(child: Text(translate('No existing sessions')))
                : ListView.separated(
                    itemCount: identities.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final identity = identities[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            identity.isDefault
                                ? Icons.star_rounded
                                : Icons.person_outline,
                          ),
                        ),
                        title: Text(identity.name),
                        subtitle: Text(identity.username),
                        trailing: Wrap(
                          spacing: 2,
                          children: [
                            IconButton(
                              tooltip: translate('Default'),
                              onPressed: identity.isDefault
                                  ? null
                                  : () => setDefault(identity),
                              icon: const Icon(Icons.star_outline_rounded),
                            ),
                            IconButton(
                              tooltip: translate('Edit'),
                              onPressed: () => editIdentity(identity),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: translate('Delete'),
                              onPressed: () => deleteIdentity(identity),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton.icon(
              onPressed: addIdentity,
              icon: const Icon(Icons.add),
              label: Text(translate('Add')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(translate('Close')),
            ),
          ],
        );
      },
    ),
  );
}

Future<String?> showLanIdentityPicker(
  BuildContext context, {
  String fingerprint = '',
}) async {
  var identities = loadLanIdentityProfiles();
  if (identities.isEmpty) {
    final created = await showLanIdentityEditor(context);
    return created;
  }
  final boundIdentityId = fingerprint.isEmpty
      ? ''
      : bind.mainGetBoundLanIdentityId(fingerprint: fingerprint);

  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(translate('Account')),
      content: SizedBox(
        width: 420,
        child: ListView(
          shrinkWrap: true,
          children: identities
              .map(
                (identity) => ListTile(
                  leading: Icon(
                    identity.id == boundIdentityId
                        ? Icons.link_rounded
                        : identity.isDefault
                        ? Icons.star_rounded
                        : Icons.person_outline,
                  ),
                  title: Text(identity.name),
                  subtitle: Text(identity.username),
                  onTap: () => Navigator.of(dialogContext).pop(identity.id),
                ),
              )
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await showLanIdentityManager(context);
            identities = loadLanIdentityProfiles();
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          },
          child: Text(translate('Settings')),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(translate('Cancel')),
        ),
      ],
    ),
  );
}

Future<String?> showImportLegacyLanCredentialDialog(
  BuildContext context, {
  required String fingerprint,
  required String suggestedName,
}) async {
  final nameController = TextEditingController(text: suggestedName);
  var makeDefault = false;
  var errorText = '';
  final identityId = await showDialog<String>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text('${translate('Add')} ${translate('Account')}'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(labelText: translate('Name')),
              ),
              CheckboxListTile(
                value: makeDefault,
                onChanged: (value) =>
                    setState(() => makeDefault = value == true),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text('${translate('Default')} ${translate('Account')}'),
              ),
              if (errorText.isNotEmpty)
                Text(
                  errorText,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(translate('Cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              final response =
                  jsonDecode(
                        bind.mainImportLegacyLanCredential(
                          fingerprint: fingerprint,
                          name: nameController.text,
                          makeDefault: makeDefault,
                        ),
                      )
                      as Map<String, dynamic>;
              final error = response['error']?.toString() ?? '';
              final importedId = response['identity_id']?.toString() ?? '';
              if (error.isEmpty && importedId.isNotEmpty) {
                Navigator.of(dialogContext).pop(importedId);
              } else {
                setState(() {
                  errorText = error.isEmpty ? translate('Failed') : error;
                });
              }
            },
            child: Text(translate('OK')),
          ),
        ],
      ),
    ),
  );
  nameController.dispose();
  return identityId;
}
