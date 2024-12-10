import 'api_client.dart';

class InvitationService {
  Future<void> sendInvitation(String groupId, String email, String inviterName, String invitedUserName) async {
    final endpoint = 'api/Invitation/sendInvitation';
    final apiClient = await ApiClient.create();

    final Map<String, dynamic> body = {
      'groupId': groupId,
      'email': email,
      'inviterName': inviterName,
      'invitedUserName': invitedUserName
    };

    final response = await apiClient.authorizedPost(endpoint, body);
  }

  Future<void> acceptInvitation(String token) async {
    final endpoint = 'api/Invitation/acceptInvitation/$token';
    final apiClient = await ApiClient.create();

    try {
      final response = await apiClient.authorizedGet(endpoint);
      if (response.statusCode == 200) {
        print('Invitation accepted successfully');
      } else {
        print('Failed to accept the invitation: ${response.body}');
      }
    } catch (e) {
      print('Error accepting invitation: $e');
    }
  }
}