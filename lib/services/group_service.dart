import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:frontend/ErrorNotifier.dart';
import 'package:frontend/models/accounts/group.dart';
import 'package:provider/provider.dart';

import 'api_client.dart';

class GroupService {

  Future<void> createGroup(BuildContext context, String groupName) async {
    final endpoint = 'api/Group/createGroup?groupName=$groupName';
    final apiClient = await ApiClient.create();

    final response = await apiClient.authorizedPost(context, endpoint, {});
    if (response == null) return;

    if (response.statusCode != 200) {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het aanmaken van je groep. Probeer later opnieuw.");
    }
  }

  Future<List<Group>> getGroupsByUserId(BuildContext context) async {
    final endpoint = 'api/Group/getGroups';
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet(context, endpoint);
    if (response == null) return [];

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((group) => Group.fromJson(group))
          .toList();
    } else {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het ophalen van je groepen. Probeer later opnieuw.");
      return [];
    }
  }

  Future<void> removeUserFromGroup(BuildContext context, String groupId) async {
    final endpoint = 'api/Group/$groupId/removeUser';
    final apiClient = await ApiClient.create();

    final response = await apiClient.authorizedPost(context, endpoint, {});
    if (response == null) return;

    if (response.statusCode != 200) {
        Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het verlaten van je groep. Probeer later opnieuw.");
    }
  }
}