import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/Services/keycloak_service.dart';
import 'package:frontend/models/accounts/account.dart';
import 'package:frontend/models/accounts/group.dart';
import 'package:frontend/models/accounts/preferencedto.dart';
import 'package:frontend/screens/keycloak/login_screen.dart';
import 'package:frontend/services/account_service.dart';
import 'package:frontend/services/group_service.dart';
import 'package:frontend/services/preference_service.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import '../services/invitation_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profiel'), centerTitle: true),
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

  void _logout() async {
    await KeycloakService().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (route) => false, // This removes all previous routes
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
          child: Column(
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
                  )),
              SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomLeft,
                child: GroupOverview(),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _logout();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  backgroundColor: Color(0xFFE72222),
                ),
                child: Text(
                  'Uitloggen',
                  style: TextStyle(
                      fontSize: 20, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ));
  }

  void _saveAll() async {
    try {
      await _accountSettingsKey.currentState?._saveData();
      await _preferenceSettingsKey.currentState?._savePreferences();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gebruikersinstellingen zijn opgeslagen!'),
            backgroundColor: Colors.black,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Er is een fout opgetreden bij het opslaan.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

  Future<void> _saveData() async {
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
    } catch (e) {
      Exception(e);
    }
  }

  Future<void> _saveFamilySize(int newFamilySize) async {
    try {
      await _accountService.updateFamilySize(userId, newFamilySize);
      setState(() {
        _currentFamilySize = newFamilySize;
        _familySizeController.text = newFamilySize.toString();
      });
    } catch (e) {
      Exception(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
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

  Future<void> _savePreferences() async {
    List<String> selectedPreferences =
        controller.selectedItems.map((item) => item.value).toList();

    // Get current user preferences to avoid duplicates
    List<PreferenceDto> preferencesForDelete =
        await _accountService.getPreferencesByUserId(userId);

    if (selectedPreferences.isNotEmpty) {
      for (String preference in selectedPreferences) {
        bool isExistingPreference = preferencesForDelete.any((pref) =>
            pref.preferenceName.toLowerCase() == preference.toLowerCase());

        if (!isExistingPreference) {
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
    }

    // Delete deselected preferences
    List<String> currentPreferences =
        preferences.map((item) => item.value).toList();
    for (String currentPreference in currentPreferences) {
      if (!selectedPreferences.contains(currentPreference)) {
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

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    try {
      List<DropdownItem<String>> tempPreferences = [];

      var pref = await _preferenceService.getStandardPreferences();
      tempPreferences = pref.map((preference) {
        return DropdownItem(
          label: preference.preferenceName,
          value: preference.preferenceName,
          selected: false,
        );
      }).toList();

      userId = await _accountService.getUserId();
      List<PreferenceDto> userPreferences =
          await _accountService.getPreferencesByUserId(userId);

      setState(() {
        // Add userPreferences to tempPreferences if they're not already present
        for (var userPreference in userPreferences) {
          if (!tempPreferences.any((item) =>
              item.value.toLowerCase() ==
              userPreference.preferenceName.toLowerCase())) {
            tempPreferences.add(DropdownItem(
              label: userPreference.preferenceName,
              value: userPreference.preferenceName,
            ));
          }
        }

        // Select items the user already has
        for (var item in tempPreferences) {
          item.selected =
              userPreferences.any((pref) => pref.preferenceName == item.value);
        }
        preferences = tempPreferences;

        // Clear the controller and add items to it
        controller.clearAll();
        controller.addItems(preferences);
      });
    } catch (e) {
      Exception(e);
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

class GroupOverview extends StatefulWidget {
  const GroupOverview({super.key});

  @override
  State<GroupOverview> createState() => _GroupOverviewState();
}

class _GroupOverviewState extends State<GroupOverview> {
  late List<Group> _groups = [];
  final _groupService = GroupService();
  final _accountService = AccountService();
  final _invitationService = InvitationService();

  var userId = '';

  void _showCreateGroupDialog() {
    final TextEditingController groupNameController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Maak een nieuwe groep aan'),
            content: TextField(
              controller: groupNameController,
              decoration: const InputDecoration(labelText: 'Groepsnaam'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Annuleer'),
              ),
              ElevatedButton(
                onPressed: () {
                  final groupName = groupNameController.text.trim();
                  if (groupName.isNotEmpty) {
                    setState(() {
                      _groups.add(Group(groupId: '', groupName: groupName));
                      _groupService.createGroup(groupName);
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text('Maak aan'),
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> _initialize() async {
    userId = await _accountService.getUserId();
    _groups = await _groupService.getGroupsByUserId(userId);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  // Function to invite a user to a group
  void _inviteUserToGroup(Group group) {
    final TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nodig een gebruiker uit voor jouw groep!'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Voer de email van de gebruiker in'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isNotEmpty) {
                  await _invitationService.sendInvitation(
                      group.groupId, group.groupName, email, '', '');

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Invitation sent successfully!')),
                  );

                  Navigator.pop(context);
                }
              },
              child: const Text('Send Invitation'),
            ),
          ],
        );
      },
    );
  }

  void _leaveGroup(Group group) async {
    try {
      await _groupService.removeUserFromGroup(group.groupId);
      setState(() {
        _groups.remove(group);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Je hebt de groep verlaten!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Groep verlaten mislukt: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: const Text(
            'Jouw Groepen',
            style: TextStyle(fontSize: 30),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: _showCreateGroupDialog,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: const Text('\u{2795} Nieuw', style: TextStyle(fontSize: 16)),
          ),
        ),

        const SizedBox(height: 8),

        ListView(
          shrinkWrap: true,  // Ensures the ListView only takes up as much space as needed
          children: [
            ..._groups.map((group) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(group.groupName),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.person_add),
                              onPressed: () {
                                _inviteUserToGroup(group);
                              },
                            ),

                            IconButton(
                              icon: const Icon(Icons.exit_to_app),
                              onPressed: () {
                                setState(() {
                                  _leaveGroup(group);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            })
          ],
        ),
      ],
    );
  }
}
