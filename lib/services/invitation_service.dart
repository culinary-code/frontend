import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class InvitationService {

  Future<String> sendInvitation(
    String groupId,
    String groupName,
  ) async {
    final endpoint = 'api/Invitation/sendInvitation';
    final apiClient = await ApiClient.create();

    final Map<String, dynamic> body = {
      'groupId': groupId,
      'groupName': groupName,
      'inviterName': '',
    };

    final response = await apiClient.authorizedPost(endpoint, body);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final invitationLink = responseBody['link'];

      if (invitationLink != null && invitationLink.isNotEmpty) {
        return invitationLink;
      } else {
        throw Exception('Error: Invitation link is empty or invalid');
      }
    } else {
      throw Exception('Error sending invitation: ${response.body}');
    }
  }

  Future<void> acceptInvitation(String token) async {
    final endpoint = 'api/Invitation/acceptInvitation/$token';
    final apiClient = await ApiClient.create();

    final response = await apiClient.authorizedGet(endpoint);
    if (response.statusCode == 200) {

      // remove token from sharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('pending_invitation_code');
    } else {
      throw Exception('Error handling invitation');
    }
  }
}
