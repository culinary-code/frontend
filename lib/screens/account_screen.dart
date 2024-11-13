import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import '../models/accounts/account.dart';
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
        SizedBox(
          height: 16,
        ),
        Expanded(
          child: PreferencesSettings(),
        ),
      ],
    );
  }
}

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  @override
  State<AccountSettings> createState() => _AccountSettingsState();
}

class _AccountSettingsState extends State<AccountSettings> {
  final TextEditingController _usernameController = TextEditingController();
  final AccountService _accountService = AccountService();

  String _currentUsername = '';
  late String userId;

  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      userId = await _accountService.getUserId();
      Account user = await _accountService.fetchUser(userId);
      setState(() {
        _currentUsername = user.username;
        _usernameController.text = _currentUsername;
      });
    } catch (e) {
      print('Error initializing account settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Account instellingen konden niet geladen worden.')),
        );
      }
    }
  }

  Future<void> _saveUsername() async {
    final newUsername = _usernameController.text;
    if (newUsername.length <= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gebruikersnaam moet minstens  karakters zijn.')),
      );
      return;
    }

    try {
      await _accountService.updateUsername(userId, newUsername);
      setState(() {
        _currentUsername = newUsername;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gebruikernaam opgeslagen!')),
        );
      }
    } catch (e) {
      print('Error updating username: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gebruikersnaam kon niet opgeslagen worden.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const SizedBox(height: 16),
        const Text('Account instellingen', style: TextStyle(fontSize: 30)),
        const SizedBox(height: 16),
        Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                  labelText: 'Gebruikersnaam',
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                      icon: Icon(Icons.save), onPressed: _saveUsername)),
            )),
      ]),
    );
  }
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
    DropdownItem(label: 'Vegetarisch', value: 'Vegetarian'),
    DropdownItem(label: 'Notenallergie', value: 'Nut Allergy'),
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
                      wrap: true, runSpacing: 2, spacing: 10),
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