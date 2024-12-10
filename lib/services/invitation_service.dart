import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class InvitationService {
  Future<void> sendInvitation(String groupId, String groupName, String email,
      String inviterName, String invitedUserName) async {
    final endpoint = 'api/Invitation/sendInvitation';
    final apiClient = await ApiClient.create();

    final Map<String, dynamic> body = {
      'groupId': groupId,
      'groupName': groupName,
      'email': email,
      'inviterName': inviterName,
      'invitedUserName': invitedUserName
    };

    await apiClient.authorizedPost(endpoint, body);
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
