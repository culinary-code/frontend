import 'package:flutter/material.dart';
import 'package:frontend/screens/account_screen.dart';
import 'package:frontend/services/group_service.dart';
import 'package:frontend/services/invitation_service.dart';

class InvitationScreen extends StatelessWidget {
  final String invitationCode;
  //final _groupService = GroupService();
  final InvitationService _invitationService = InvitationService();

  InvitationScreen({super.key, required this.invitationCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Uitnodiging")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Je hebt een uitnodiging!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Uitnodigingscode: $invitationCode',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle invitation acceptance logic here
                _invitationService.acceptInvitation(invitationCode);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountScreen(),
                  ),
                );
              },
              child: const Text("Uitnodiging accepteren"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Uitnodiging weigeren"),
            ),
          ],
        ),
      ),
    );
  }
}