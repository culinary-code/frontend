import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/accounts/preference.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import '../models/accounts/account.dart';
import '../models/accounts/preferencedto.dart';
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
  final TextEditingController _familySizeController = TextEditingController();
  final AccountService _accountService = AccountService();

  String _currentUsername = '';
  int _currentFamilySize = 0;
  late String userId;

  final storage = FlutterSecureStorage();
  bool _usernameError = false;

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
        _currentFamilySize = user.familySize;
        _familySizeController.text = _currentFamilySize.toString();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Account instellingen konden niet geladen worden.'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveUsername() async {
    final newUsername = _usernameController.text;
    if (newUsername.length < 3) {
      setState(() {
        _usernameError = true;
      });
      return;
    }

    try {
      await _accountService.updateUsername(userId, newUsername);
      setState(() {
        _currentUsername = newUsername;
        _usernameError = false; // Clear error on successful save
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gebruikernaam opgeslagen!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gebruikersnaam kon niet opgeslagen worden.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveFamilySize(int newFamilySize) async {
    if (newFamilySize < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mijn gezin moet minstens 1 zijn.')),
      );
      return;
    }

    try {
      await _accountService.updateFamilySize(userId, newFamilySize);
      setState(() {
        _currentFamilySize = newFamilySize;
        _familySizeController.text = newFamilySize.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mijn gezin opgeslagen!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mijn gezin kon niet opgeslagen worden.'),
            backgroundColor: Colors.red,
          ),
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
            child: Column(
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                      labelText: 'Gebruikersnaam',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      errorText: _usernameError
                          ? 'Gebruikersnaam moet minstens 3 karakters zijn.'
                          : null,
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                          icon: Icon(Icons.save), onPressed: _saveUsername)),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            )),
        SizedBox(height: 16,),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: MyFamilySelector(
            familySize: _currentFamilySize,
            onAdd: _saveFamilySize,
          ),
        )
      ]),
    );
  }
}

class MyFamilySelector extends StatefulWidget {
  final int familySize;
  final ValueChanged<int> onAdd;

  const MyFamilySelector(
      {super.key, required this.familySize, required this.onAdd});

  @override
  State<MyFamilySelector> createState() => _MyFamilySelectorState();
}

class _MyFamilySelectorState extends State<MyFamilySelector> {
  late int numberOfPeople;

  void addFamilyMembers() {
    setState(() {
      numberOfPeople++;
    });
  }

  void removeFamilyMembers() {
    setState(() {
      if (numberOfPeople > 1) numberOfPeople--;
    });
  }

  @override
  void initState() {
    super.initState();
    numberOfPeople = widget.familySize;
  }

  // update familysize
  @override
  void didUpdateWidget(covariant MyFamilySelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.familySize != oldWidget.familySize) {
      setState(() {
        numberOfPeople = widget.familySize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 6, top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.family_restroom,
                    size: 30,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Mijn gezin',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: removeFamilyMembers,
                    child: CircleAvatar(
                      radius: 15,
                      child: Icon(
                        Icons.remove,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$numberOfPeople',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: addFamilyMembers,
                    child: CircleAvatar(
                      radius: 15,
                      child: Icon(
                        Icons.add,
                        size: 18,
                      ),
                    ),
                  ),
                       Spacer(),
                       SizedBox(width: 25,),
                       IconButton(
                          onPressed: () {
                            widget.onAdd(numberOfPeople);
                          },
                          icon: Icon(Icons.save),
                        ),
                    ],
                  )
                ],
              ),
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
  final TextEditingController customPreferenceController = TextEditingController();

  final _accountService = AccountService();
  var userId = '';

  final Set<String> standardPreferences = {
    'Vegan',
    'Vegetarian',
    'Nut Allergy',
    'Lactose Intolerant',
  };

  String? selectedValue;

  List<DropdownItem<String>> preferences = [
    DropdownItem(label: 'Vegan', value: 'Vegan'),
    DropdownItem(label: 'Vegetarisch', value: 'Vegetarian'),
    DropdownItem(label: 'Notenallergie', value: 'Nut Allergy'),
    DropdownItem(label: 'Lactose Intolerant', value: 'Lactose Intolerant'),
  ];
  // Add new preference to dropdown
  void _addPreferenceToDropdown() {
    String newPreference = customPreferenceController.text.trim();
    if (newPreference.isNotEmpty && !preferences.any((item) => item.value == newPreference)) {
      setState(() {
        // Add new preference to the list
        preferences.add(DropdownItem(label: newPreference, value: newPreference, selected: true));

        // Select the new preference immediately
        controller.addItems([
          DropdownItem(label: newPreference, value: newPreference, selected: true),
        ]);
        controller.selectedItems.add(
          DropdownItem(label: newPreference, value: newPreference, selected: true),
        );

        // Update selected value to reflect in the UI
        selectedValue = newPreference;
      });

      // Close the dialog
      Navigator.pop(context);
    } else {
      debugPrint("Preference was empty or already exists.");
    }
  }


  void _savePreferences() {
    // Get the list of selected preferences
    List<String> selectedPreferences = controller.selectedItems.map((item) => item.value).toList();

    if (selectedPreferences.isNotEmpty) {
      // Iterate over the selected preferences and add them to the backend
      for (String preference in selectedPreferences) {
        if (standardPreferences.map((p) => p.toLowerCase()).contains(preference.toLowerCase())) {
          _accountService.addPreference(
            userId,
            PreferenceDto(preferenceName: preference, standardPreference: true),
          );
        } else {
          _accountService.addPreference(
            userId,
            PreferenceDto(preferenceName: preference, standardPreference: false),
          );
        }
      }
      debugPrint('Saved preferences: $selectedPreferences');
    } else {
      debugPrint('No preferences selected');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    try {
      userId = await _accountService.getUserId();
      List<PreferenceDto> userPreferences = await _accountService.getPreferencesByUserId(userId);

      setState(() {
        // Add user preferences (including custom) to the dropdown list
        for (var userPreference in userPreferences) {
          if (!preferences.any((item) => item.value == userPreference.preferenceName)) {
            preferences.add(
              DropdownItem(label: userPreference.preferenceName, value: userPreference.preferenceName),
            );
          }
        }

        // Update the selection state for all preferences
        for (var item in preferences) {
          item.selected = userPreferences.any((pref) => pref.preferenceName == item.value);
        }

        // Synchronize controller with the updated list
        controller.clearAll();
        controller.addItems(preferences.where((item) => item.selected).toList());
      });
    } catch (e) {
      debugPrint('Failed to load preferences: $e');
    }
  }


  /*Future<void> _initializePreferences() async {
    try {
      userId = await _accountService.getUserId();
      List<PreferenceDto> userPreferences = await _accountService.getPreferencesByUserId(userId);

      setState(() {
        for (var item in preferences) {
          item.selected = userPreferences.any((pref) => pref.preferenceName == item.value);
        }
      });
    } catch (e) {
      debugPrint('Failed to load preferences: $e');
    }
  }*/

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
                  chipDecoration: const ChipDecoration(wrap: true, runSpacing: 2, spacing: 10),
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
                      _savePreferences();
                      //_accountService.addPreference(userId, PreferenceDto(preferenceName: preferences[0].value,standardPreference: false));
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
                            decoration: const InputDecoration(labelText: "Eigen voorkeur"),
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
