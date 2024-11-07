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
    return const Column(
      children: [
        AccountSettings(),
        SizedBox(height: 16),
        //PreferencesSettings()
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

/*class PreferencesSettings extends StatefulWidget {
  const PreferencesSettings({super.key});

  @override
  State<PreferencesSettings> createState() => _PreferencesSettingsState();
}

class User {
  final String name;
  final int id;

  User({required this.name, required this.id});

  @override
  String toString() {
    return 'User(name: $name, id: $id)';
  }
}

class _PreferencesSettingsState extends State<PreferencesSettings> {
  final _formKey = GlobalKey<FormState>();

  final controller = MultiSelectController<User>();

  @override
  Widget build(BuildContext context) {
    var items = [
      DropdownItem(label: 'Nepal', value: User(name: 'Nepal', id: 1)),
      DropdownItem(label: 'Australia', value: User(name: 'Australia', id: 6)),
      DropdownItem(label: 'India', value: User(name: 'India', id: 2)),
      DropdownItem(label: 'China', value: User(name: 'China', id: 3)),
      DropdownItem(label: 'USA', value: User(name: 'USA', id: 4)),
      DropdownItem(label: 'UK', value: User(name: 'UK', id: 5)),
      DropdownItem(label: 'Germany', value: User(name: 'Germany', id: 7)),
      DropdownItem(label: 'France', value: User(name: 'France', id: 8)),
    ];
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                //width: double.infinity,
                //ht: MediaQuery.of(context).size.height,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const SizedBox(
                        height: 4,
                      ),
                      MultiDropdown<User>(
                        items: items,
                        controller: controller,
                        enabled: true,
                        searchEnabled: true,
                        chipDecoration: const ChipDecoration(
                          backgroundColor: Colors.yellow,
                          wrap: true,
                          runSpacing: 2,
                          spacing: 10,
                        ),
                        fieldDecoration: FieldDecoration(
                          hintText: 'Countries',
                          hintStyle: const TextStyle(color: Colors.black87),
                          prefixIcon: const Icon(CupertinoIcons.flag),
                          showClearIcon: false,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        dropdownDecoration: const DropdownDecoration(
                          marginTop: 2,
                          maxHeight: 500,
                          header: Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Select countries from the list',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        dropdownItemDecoration: DropdownItemDecoration(
                          selectedIcon:
                          const Icon(Icons.check_box, color: Colors.green),
                          disabledIcon:
                          Icon(Icons.lock, color: Colors.grey.shade300),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a country';
                          }
                          return null;
                        },
                        onSelectionChange: (selectedItems) {
                          debugPrint("OnSelectionChange: $selectedItems");
                        },
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
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
                              controller.addItems([
                                DropdownItem(
                                    label: 'France',
                                    value: User(name: 'France', id: 8)),
                              ]);
                            },
                            child: const Text('Add Items'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              controller.selectWhere((element) =>
                              element.value.id == 1 ||
                                  element.value.id == 2 ||
                                  element.value.id == 3);
                            },
                            child: const Text('Select Where'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              controller.selectAtIndex(0);
                            },
                            child: const Text('Select At Index'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              controller.openDropdown();
                            },
                            child: const Text('Open/Close dropdown'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
*/