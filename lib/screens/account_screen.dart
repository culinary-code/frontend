import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gebruikersinstellingen')),
      body: AccountSettings(),
    );
  }
}

class AccountOverview extends StatefulWidget {
  const AccountOverview({super.key});

  @override
  State<AccountOverview> createState() => _AccountOverviewState();
}

class _AccountOverviewState extends State<AccountOverview> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 16,
            ),
            const Text(
              'Account instellingen',
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: TextInputSettingsTile(
                title: 'Gebruikersnaam',
                titleTextStyle: const TextStyle(fontSize: 20),
                settingKey: 'key-user-name',
                initialValue: 'admin',
                subtitleTextStyle: const TextStyle(fontSize: 18),
                validator: (username) {
                  if (username != null && username.isNotEmpty) {
                    return null;
                  }
                  return "Gebruikersnaam kan niet leeg zijn!";
                },
                borderColor: Colors.blueGrey,
                errorColor: Colors.red,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: TextInputSettingsTile(
                title: 'Wachtwoord',
                titleTextStyle: const TextStyle(fontSize: 20),
                settingKey: 'key-user-password',
                subtitleTextStyle: const TextStyle(fontSize: 18),
                obscureText: true,
                validator: (password) {
                  if (password != null && password.isNotEmpty) {
                    return null;
                  }
                  return "Voeg een wachtwoord in!";
                },
                borderColor: Colors.blueGrey,
                errorColor: Colors.red,
              ),
            )
          ],
        ));
  }
}