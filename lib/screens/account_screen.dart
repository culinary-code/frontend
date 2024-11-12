import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../services/account_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gebruikersinstellingen')),
      body: const AccountOverview(),
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
    return Column(
      children: [
        AccountSettings(),
        SizedBox(height: 16,),
        Expanded(
          child: PreferencesSettings(),
        ),
      ],
    );
  }
}


class TextInputSettingsTile extends StatelessWidget {
  final String title;
  final String? initialValue;
  final TextStyle titleTextStyle;
  final String? Function(String?)? validator;
  final TextStyle subtitleTextStyle;
  final Color borderColor;
  final Color errorColor;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? settingKey;

  const TextInputSettingsTile({
    Key? key,
    required this.title,
    this.initialValue,
    required this.titleTextStyle,
    this.validator,
    required this.subtitleTextStyle,
    required this.borderColor,
    required this.errorColor,
    this.controller,
    this.onChanged,
    this.settingKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: title,
        labelStyle: titleTextStyle,
        errorText: validator != null ? validator!(controller?.text) : null,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
      ),
    );
  }
}



class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  String _currentUsername = 'nisrine';
  final TextEditingController _usernameController = TextEditingController();
  late String userId;
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadUserId().then((_) {
      if (userId.isNotEmpty) {
        _loadCurrentUsername();
      } else {
        print('userId could not be loaded.');
      }
    });
  }

  Future<void> _loadUserId() async {
    try {
      String? accessToken = await storage.read(key: 'access_token');
      if (accessToken != null) {
        Map<String, dynamic> payload = _decodeJwt(accessToken);
        setState(() {
          userId = payload['sub']; // Ensure 'sub' matches your JWT structure
        });
        print('Loaded userId: $userId');
      } else {
        throw Exception('Access token not found');
      }
    } catch (e) {
      print('Error loading user ID: $e');
    }
  }



  Map<String, dynamic> _decodeJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }

    // Decode the payload (second part of the JWT)
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return jsonDecode(payload);
  }

  Future<void> _loadCurrentUsername() async {
    if (userId.isEmpty) {
      print('Error: userId is null or empty.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to fetch account details.')),
      );
      return;
    }
    try {
      Account user = await AccountService().fetchUser(userId);
      setState(() {
        _currentUsername = user.userName;
        _usernameController.text = _currentUsername;
      });
    } catch (e) {
      print('Error fetching current username: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load username.')),
      );
    }
  }




  Future<void> _updateUsername() async {
    try {
      //final userId = 'a75e963c-6943-4a9c-8f79-4a4c6f954427';
      final newUserName = _usernameController.text;

      final url = Uri.parse('https://localhost:7098/updateAccount/$userId');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'AccountId': userId,
          'Name': newUserName,
        }),
      );

      if (response.statusCode == 200) {
        Account updatedUser = await AccountService().fetchUser(userId);
        setState(() {
          _currentUsername = updatedUser.userName;
          _usernameController.text = _currentUsername;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Username updated successfully!')));
      } else {
        print('Error updating username: ${response.statusCode}, ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update username.')));
      }
    } catch (e) {
      print('Error updating username: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating username')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text('Account instellingen', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: TextInputSettingsTile(
                title: 'Gebruikersnaam',
                titleTextStyle: const TextStyle(fontSize: 20),
                settingKey: 'key-user-name',
                initialValue: _currentUsername,
                subtitleTextStyle: const TextStyle(fontSize: 18),
                validator: (username) {
                  if (username != null && username.isNotEmpty) {
                    return null;
                  }
                  return "Gebruikersnaam kan niet leeg zijn!";
                },
                borderColor: Colors.blueGrey,
                errorColor: Colors.red,
                controller: _usernameController,
                onChanged: (value) {
                  setState(() {
                    _currentUsername = value;
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: _updateUsername,
              child: Text('Update Username'),
            ),
          ],
        ));
  }

  /*@override
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
          ],
        ));
  } */
}

class PreferencesSettings extends StatefulWidget {
  const PreferencesSettings({super.key});

  @override
  State<PreferencesSettings> createState() => _PreferencesSettingsState();
}

class _PreferencesSettingsState extends State<PreferencesSettings> {
  final _formKey = GlobalKey<FormState>();
  final controller = MultiSelectController<String>();
  final TextEditingController customPreferenceController =
  TextEditingController();
  String? selectedValue;

  List<DropdownItem<String>> preferences = [
    DropdownItem(label: 'Vegan', value: 'Vegan'),
    DropdownItem(label: 'Vegetarian', value: 'Vegetarian'),
    DropdownItem(label: 'Nut Allergy', value: 'Nut Allergy'),
    DropdownItem(label: 'Lactose Intolerant', value: 'Lactose Intolerant'),
  ];

  void _addPreferenceToDropdown() {
    String newPreference = customPreferenceController.text.trim();
    if (newPreference.isNotEmpty &&
        !preferences.any((item) => item.value == newPreference)) {
      setState(() {
        selectedValue = newPreference;
        preferences
            .add(DropdownItem(label: newPreference, value: newPreference));
        controller.addItems(
            [DropdownItem(label: newPreference, value: newPreference)]);
        controller.selectedItems
            .add(DropdownItem(label: newPreference, value: newPreference));
      });
      Navigator.pop(context);
    } else {
      debugPrint("Preference was empty or already exists.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white24,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  'Voorkeuren',
                  style: TextStyle(fontSize: 30),
                ),
                MultiDropdown<String>(
                  items: preferences,
                  controller: controller,
                  enabled: true,
                  searchEnabled: true,
                  chipDecoration: const ChipDecoration(
                      wrap: true,
                      runSpacing: 2,
                      spacing: 10),
                  fieldDecoration: FieldDecoration(
                    hintText: 'Voorkeuren',
                    hintStyle: const TextStyle(color: Colors.black),
                    prefixIcon: const Icon(CupertinoIcons.flag),
                    showClearIcon: false,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  dropdownItemDecoration: const DropdownItemDecoration(
                    selectedIcon: Icon(Icons.check_box, color: Colors.green),
                    disabledIcon: Icon(Icons.lock, color: Colors.grey),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kies een voorkeur';
                    }
                    return null;
                  },
                  onSelectionChange: (selectedPreferences) {
                    debugPrint('OnSelectionChange: $selectedPreferences');
                  },
                ),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        final selectedItems = controller.selectedItems;
                        debugPrint(selectedItems.toString());
                      }
                    },
                    child: const Text('Opslaan'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.selectAll();
                    },
                    child: const Text('Selecteer alles'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.clearAll();
                    },
                    child: const Text('Verwijder alles'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Voeg een eigen voorkeur toe'),
                          content: TextField(
                            controller: customPreferenceController,
                            maxLength: 25,
                            decoration: const InputDecoration(
                                labelText: "Eigen voorkeur"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Annuleer'),
                            ),
                            ElevatedButton(
                              onPressed: _addPreferenceToDropdown,
                              child: const Text('Voeg toe'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Andere..'),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}