import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:frontend/ErrorNotifier.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class InvitationService {

  Future<String?> sendInvitation(BuildContext context, String groupId, String groupName) async {
    final endpoint = 'api/Invitation/sendInvitation';
    final apiClient = await ApiClient.create();

    final Map<String, dynamic> body = {
      'groupId': groupId,
      'groupName': groupName,
      'inviterName': '',
    };

    final response = await apiClient.authorizedPost(context, endpoint, body);
    if (response == null) return null;

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final invitationLink = responseBody['link'];

      if (invitationLink != null && invitationLink.isNotEmpty) {
        return 'https://culinarycode.com/accept-invitation/$invitationLink';
      } else {
        Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het aanmaken van je uitnodiging. Probeer later opnieuw.");
      }
    } else {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het aanmaken van je uitnodiging. Probeer later opnieuw.");
    }
    return null;
  }


  Future<void> acceptInvitation(BuildContext context, String token) async {
    final endpoint = 'api/Invitation/acceptInvitation/$token';
    final apiClient = await ApiClient.create();

    final response = await apiClient.authorizedGet(context, endpoint);
    if (response == null) return;
    if (response.statusCode == 200) {

      // remove token from sharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.remove('pending_invitation_code');
    } else {
      Provider.of<ErrorNotifier>(context, listen: false).showError("Er ging iets mis met het accepteren van je uitnodiging. Probeer later opnieuw.");
    }
  }
}
