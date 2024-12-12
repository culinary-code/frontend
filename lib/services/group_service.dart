import 'dart:convert';

import 'package:frontend/models/accounts/group.dart';

import 'api_client.dart';

class GroupService {

  Future<void> createGroup(String groupName) async {
    final endpoint = 'api/Group/createGroup?groupName=$groupName';
    final apiClient = await ApiClient.create();

    final response = await apiClient.authorizedPost(endpoint, {});

    if (response.statusCode != 200) {
      throw Exception(
          'Error creating: ${response.statusCode}, ${response.body}');
    }
  }

  Future<List<Group>> getGroupsByUserId() async {
    final endpoint = 'api/Group/getGroups';
    final apiClient = await ApiClient.create();
    final response = await apiClient.authorizedGet(endpoint);

    if (response.statusCode == 200) {
      return (json.decode(response.body) as List)
          .map((group) => Group.fromJson(group))
          .toList();
    } else {
      return [];
    }
  }

  Future<void> removeUserFromGroup(String groupId) async {
    final endpoint = 'api/Group/$groupId/removeUser';
    final apiClient = await ApiClient.create();

    final response = await apiClient.authorizedPost(endpoint, {});

    if (response.statusCode != 200) {
      throw Exception('Error removing user from group: ${response.statusCode}, ${response.body}');
    }
  }
}