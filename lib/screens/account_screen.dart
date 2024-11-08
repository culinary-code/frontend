import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

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
          ],
        ));
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
                MultiDropdown<String>(
                  items: preferences,
                  controller: controller,
                  enabled: true,
                  searchEnabled: true,
                  chipDecoration: const ChipDecoration(
                      backgroundColor: Colors.yellow,
                      wrap: true,
                      runSpacing: 2,
                      spacing: 10),
                  fieldDecoration: FieldDecoration(
                    hintText: 'Preferences',
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
                      return 'Select a preference';
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
                    child: const Text('Submit'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.selectAll();
                    },
                    child: const Text('Select All'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.clearAll();
                    },
                    child: const Text('Unselect All'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Add Custom Preference'),
                          content: TextField(
                            controller: customPreferenceController,
                            decoration: const InputDecoration(
                                labelText: "Custom Preference"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: _addPreferenceToDropdown,
                              child: const Text('Add'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Add Preferences'),
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
