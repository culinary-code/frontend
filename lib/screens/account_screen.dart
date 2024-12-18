import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/Services/keycloak_service.dart';
import 'package:frontend/models/accounts/account.dart';
import 'package:frontend/models/accounts/group.dart';
import 'package:frontend/models/accounts/preferencedto.dart';
import 'package:frontend/screens/keycloak/login_screen.dart';
import 'package:frontend/services/account_service.dart';
import 'package:frontend/services/group_service.dart';
import 'package:frontend/services/invitation_service.dart';
import 'package:frontend/services/preference_service.dart';
import 'package:frontend/state/recipe_filter_options_provider.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  final TextEditingController usernameController = TextEditingController();

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
          SizedBox(height: 116),
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
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String errorMessage = '';

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text('Account verwijderen'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  'Weet je zeker dat je je account wilt verwijderen?'),
                              Text('Dit kan niet ongedaan worden gemaakt.'),
                              SizedBox(height: 16),
                              TextField(
                                controller: usernameController,
                                onChanged: (value) {
                                  setState(() {
                                    errorMessage = '';
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Bevestig gebruikersnaam',
                                  border: OutlineInputBorder(),
                                  errorText: errorMessage.isNotEmpty
                                      ? errorMessage
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Annuleer'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (usernameController.text ==
                                    _accountSettingsKey
                                        .currentState?._currentUsername) {

                                  if (!mounted) return;
                                  final filterprovider =
                                  Provider.of<RecipeFilterOptionsProvider>(
                                      context,
                                      listen: false

                                  );
                                  filterprovider.clearFilters(context);

                                  await AccountService().deleteAccount(context);
                                  await KeycloakService().clearTokens();

                                  if (!mounted) return;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginPage(),
                                    ),
                                    (route) =>
                                        false, // This removes all previous routes
                                  );
                                } else {
                                  setState(() {
                                    errorMessage =
                                        'Gebruikersnaam komt niet overeen';
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFE72222),
                              ),
                              child: Text('Verwijder account',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        );
                      },
                    );
                  });
            },
            style: ElevatedButton.styleFrom(
              elevation: 5,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              backgroundColor: Color(0xFFE72222),
            ),
            child: Text(
              'Account verwijderen',
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

  final storage = FlutterSecureStorage();
  bool _usernameError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      Account? user = await _accountService.fetchUser(context);
      if (user == null) return;
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
      await _accountService.updateUsername(context, newUsername);
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
      await _accountService.updateFamilySize(context, newFamilySize);
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
      widget.onAdd(numberOfPeople);
    });
  }

  void removeFamilyMembers() {
    setState(() {
      if (numberOfPeople > 1) numberOfPeople--;
      widget.onAdd(numberOfPeople);
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
        await _accountService.getPreferencesByUserId(context);

    if (selectedPreferences.isNotEmpty) {
      for (String preference in selectedPreferences) {
        bool isExistingPreference = preferencesForDelete.any((pref) =>
            pref.preferenceName.toLowerCase() == preference.toLowerCase());

        if (!isExistingPreference) {
          // Add custom preference
          _accountService.addPreference(
            context,
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
              .deletePreference(context, preferenceToDelete.preferenceId);
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

      var pref = await _preferenceService.getStandardPreferences(context);
      tempPreferences = pref.map((preference) {
        return DropdownItem(
          label: preference.preferenceName,
          value: preference.preferenceName,
          selected: false,
        );
      }).toList();

      List<PreferenceDto> userPreferences =
          await _accountService.getPreferencesByUserId(context);

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
                        hintText: 'Kies jouw voorkeuren',
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
  bool _isLoading = true;
  final _groupService = GroupService();
  final _invitationService = InvitationService();
  final _accountService = AccountService();

  late Account? user;

  String _selectedGroup = '';

  Future<void> _initialize() async {
    try {
      _groups = await _groupService.getGroupsByUserId(context);
      user = await _accountService.fetchUser(context);

      // After fetching groups, load the group mode state from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      for (var group in _groups) {
        group.isGroupMode = prefs.getBool(group.groupId) ?? false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load groups: $e')),
      );
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _showCreateGroupDialog() {
    final TextEditingController groupNameController = TextEditingController();

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
                    _groupService.createGroup(context, groupName);
                  });
                  Future.delayed(Duration(milliseconds: 1000), () {
                    _initialize();
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
  }

  void _inviteUserToGroup(Group group) async {
    final link = await _invitationService.sendInvitation(
      context,
      group.groupId,
      group.groupName,
    );

    if (link != null && link.isNotEmpty && mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            shadowColor: Theme.of(context).canvasColor,
            title: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.group_add_sharp, color: Colors.green),
                      Expanded(
                        child: Text(
                          '  Deel ${group.groupName}',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Sluit',
                ),
              ],
            ),
            content: Text(
              'Nodig nieuwe groepsleden uit!',
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.ios_share,
                  color: Theme.of(context).iconTheme.color,
                  size: 30,
                ),
                onPressed: () async {
                  Share.share(
                      'Hey, word lid van mijn groep ${group.groupName} met deze link: $link');
                  Navigator.pop(context);
                },
                tooltip: 'Deel link',
              ),
              IconButton(
                icon: Icon(
                  Icons.copy,
                  color: Theme.of(context).iconTheme.color,
                  size: 30,
                ),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: link));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Uitnodigingslink gekopieerd naar klembord!'),
                    ),
                  );
                  Navigator.pop(context);
                },
                tooltip: 'Kopieer link',
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('De uitnodigingslink kon niet aangemaakt worden!'),
        ),
      );
    }
  }

  void _leaveGroup(Group group) async {
    try {
      await _groupService.removeUserFromGroup(context, group.groupId);

      setState(() {
        _groups.remove(group);
        if (group.isGroupMode) {
          _selectedGroup = '';
          for (var g in _groups) {
            g.isGroupMode = false;
          }

          _accountService.updateChosenGroupId(context, null);
          SharedPreferences.getInstance().then((prefs) {
            for (var key in prefs.getKeys()) {
              prefs.setBool(key, false);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Je bent teruggezet naar gebruikersmodus!')),
          );
        }
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

  // Switch toggle handler
  void _toggleGroupMode(Group group) async {
    setState(() {
      // Turn off the group mode for all other groups
      for (var g in _groups) {
        if (g.groupId != group.groupId) {
          g.isGroupMode = false;
        }
      }
      // Toggle the current group mode
      group.isGroupMode = !group.isGroupMode;
      _selectedGroup =
          group.isGroupMode ? group.groupId : ''; // Update selected group
    });

      // Update SharedPreferences to store the group mode state
      SharedPreferences prefs = await SharedPreferences.getInstance();
      for (var key in prefs.getKeys()) {
        prefs.setBool(key, false);
      }
      prefs.setBool(group.groupId, group.isGroupMode);

      await _accountService
          .updateChosenGroupId(context, group.isGroupMode ? group.groupId : null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${group.groupName} is ${group.isGroupMode ? 'in groep modus' : 'in gebruiker modus'}')),
      );
    }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: const Text(
                  'Jouw Groepen',
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton(
                  onPressed: _showCreateGroupDialog,
                  child: const Text('\u{2795} Nieuw'),
                ),
              ),
              const SizedBox(height: 8),
              ListView(
                shrinkWrap: true,
                // Ensures the ListView only takes up as much space as needed
                children: [
                  ..._groups.map((group) {
                    final isSelected = _selectedGroup == group.groupId;
                    return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey.shade200, blurRadius: 6)
                              ],
                            ),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      group.groupName,
                                      style: TextStyle(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: group.isGroupMode,
                                    onChanged: (value) =>
                                        _toggleGroupMode(group),
                                    activeColor: Colors.green,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.person_add,
                                            color: Colors.green,
                                          ),
                                          onPressed: () {
                                            _inviteUserToGroup(group);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.exit_to_app,
                                              color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'Bevestig Verlaten Groep'),
                                                  content: Text(
                                                      'Weet je zeker dat je ${group.groupName} wilt verlaten?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text(
                                                          'Annuleren'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          _leaveGroup(group);
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const Text(
                                                          'Verlaten',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.red)),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  ),
                                ])));
                  })
                ],
              ),
            ],
          );
  }
}
