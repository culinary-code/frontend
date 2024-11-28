import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/accounts/account.dart';
import 'package:frontend/models/accounts/preferencedto.dart';
import 'package:frontend/services/account_service.dart';
import 'package:frontend/services/preference_service.dart';
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
  final GlobalKey<_AccountSettingsState> _accountSettingsKey = GlobalKey();
  final GlobalKey<_PreferencesSettingsState> _preferenceSettingsKey =
      GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AccountSettings(key: _accountSettingsKey),
        SizedBox(
          height: 16,
        ),
        PreferencesSettings(key: _preferenceSettingsKey),
        SizedBox(height: 16),
        ElevatedButton(
            onPressed: _saveAll,
            style: ElevatedButton.styleFrom(
              elevation: 5,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
            child: Text(
              'Opslaan',
              style: TextStyle(fontSize: 20),
            ))
      ],
    );
  }

  void _saveAll() {
    _accountSettingsKey.currentState?.saveData();
    _preferenceSettingsKey.currentState?._savePreferences();
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

  void saveData() async {
    await _saveUsername();
    await _saveFamilySize(_currentFamilySize);
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
                    /*suffixIcon: IconButton(
                          icon: Icon(Icons.save), onPressed: _saveUsername)*/
                  ),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            )),
        SizedBox(
          height: 16,
        ),
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
    return Padding(
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
              SizedBox(
                width: 25,
              ),
              /*IconButton(
                onPressed: () {
                  widget.onAdd(numberOfPeople);
                },
                icon: Icon(Icons.save),
              ),*/
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
  final TextEditingController customPreferenceController =
      TextEditingController();

  final _accountService = AccountService();
  final _preferenceService = PreferenceService();
  var userId = '';

  final Set<String> standardPreferences = {
    'Vegan',
    'Vegetarian',
    'Nut Allergy',
    'Lactose Intolerant',
  };

  String? selectedValue;

  List<DropdownItem<String>> preferences = [];

  void _addPreferenceToDropdown() {
    String newPreference = customPreferenceController.text.trim();

    // Check is preference is not empty or not already in the list
    if (newPreference.isNotEmpty &&
        !preferences.any((item) => item.value == newPreference)) {
      setState(() {
        preferences.add(DropdownItem(
            label: newPreference, value: newPreference, selected: true));
        // Select new preference when adding it to dropdown
        controller.addItems([
          DropdownItem(
              label: newPreference, value: newPreference, selected: true),
        ]);
        controller.selectedItems.add(
          DropdownItem(
              label: newPreference, value: newPreference, selected: true),
        );
        selectedValue = newPreference;
      });

      Navigator.pop(context);
    }
  }

  void _savePreferences() async {
    List<String> selectedPreferences =
        controller.selectedItems.map((item) => item.value).toList();

    List<PreferenceDto> preferencesForDelete =
        await _accountService.getPreferencesByUserId(userId);

    if (selectedPreferences.isNotEmpty) {
      for (String preference in selectedPreferences) {
        if (standardPreferences
            .map((p) => p.toLowerCase())
            .contains(preference.toLowerCase())) {
          // Add standard preference
          _accountService.addPreference(
            userId,
            PreferenceDto(
                preferenceName: preference,
                standardPreference: true,
                preferenceId: ''),
          );
        } else {
          // Add custom preference
          _accountService.addPreference(
            userId,
            PreferenceDto(
                preferenceName: preference,
                standardPreference: false,
                preferenceId: ''),
          );
        }
      }

      List<String> currentPreferences =
          preferences.map((item) => item.value).toList();
      for (String currentPreference in currentPreferences) {
        // Check if the current preference is not in the selected preferences list, meaning it's been deselected
        if (!selectedPreferences.contains(currentPreference)) {
          // Find the preference ID by matching the preference name
          final PreferenceDto? preferenceToDelete =
              preferencesForDelete.firstWhereOrNull(
            (pref) => pref.preferenceName == currentPreference,
          );

          if (preferenceToDelete != null) {
            await _accountService
                .deletePreference(preferenceToDelete.preferenceId);
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    try {
      List<DropdownItem<String>> tempPreferences = [
        DropdownItem(label: 'Vegan', value: 'Vegan'),
        DropdownItem(label: 'Vegetarisch', value: 'Vegetarisch'),
        DropdownItem(label: 'Notenallergie', value: 'Notenallergie'),
        DropdownItem(label: 'Lactose Intolerant', value: 'Lactose Intolerant'),
      ];

      userId = await _accountService.getUserId();
      List<PreferenceDto> userPreferences =
          await _accountService.getPreferencesByUserId(userId);

      setState(() {
        // Add userPreference to tempPreference if it's not already in the list
        for (var userPreference in userPreferences) {
          if (!tempPreferences.any((item) =>
              item.value.toLowerCase() ==
              userPreference.preferenceName.toLowerCase())) {
            tempPreferences.add(
              DropdownItem(
                  label: userPreference.preferenceName,
                  value: userPreference.preferenceName),
            );
          }
        }

        // Select items user already has
        for (var item in tempPreferences) {
          item.selected =
              userPreferences.any((pref) => pref.preferenceName == item.value);
        }
        preferences = tempPreferences;

        // clear controller and add items
        controller.clearAll();
        controller.addItems(preferences);
      });
    } catch (e) {
      Exception('Failed to load preferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Voorkeuren',
                  style: TextStyle(fontSize: 30),
                ),
                Row(children: [
                  Expanded(
                    child: MultiDropdown<String>(
                      items: preferences,
                      controller: controller,
                      enabled: true,
                      searchEnabled: true,
                      chipDecoration: const ChipDecoration(
                          wrap: true, runSpacing: 2, spacing: 10),
                      fieldDecoration: FieldDecoration(
                        hintText: 'Voorkeuren',
                        prefixIcon: const Icon(CupertinoIcons.flag),
                        showClearIcon: false,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      dropdownItemDecoration: const DropdownItemDecoration(
                        selectedIcon:
                            Icon(Icons.check_box, color: Colors.green),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Kies een voorkeur';
                        }
                        return null;
                      },
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'select_all') {
                        controller.selectAll();
                      } else if (value == 'unselect_all') {
                        controller.clearAll();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'select_all',
                        child: Text('Selecteer alles'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'unselect_all',
                        child: Text('Verwijder alles'),
                      )
                    ],
                  ),
                ]),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [
                  /*ElevatedButton(
                    onPressed: () {
                      _savePreferences();
                    },
                    child: const Text('Opslaan'),
                  ),*/
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
                    child: const Text('\u{2795} Nieuw'),
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
