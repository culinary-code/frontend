import 'package:flutter/material.dart';
import 'package:frontend/Services/keycloak_service.dart';
import 'package:frontend/services/api_checker_service.dart';
import 'package:frontend/state/api_selection_provider.dart';
import 'package:provider/provider.dart';

import 'login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _statusMessage = '';
  bool _obscureText = true;

  final TextEditingController _apiUrlController = TextEditingController();
  bool _useOwnAPI = false;
  String _apiErrorMessage = '';
  bool _ownApiSet = false;

  final Map<String, String> errorMessages = {
    "password": "Error: Paswoord is verplicht in te vullen.",
    "invalid-email": "Error: Geen geldig email formaat gegeven.",
    "email": "Error: Email is verplicht in te vullen.",
    "User exists": "Error: Gebruikersnaam is al in gebruik.",
    "User": "Error: Gebruikersnaam is verplicht in te vullen.",
    "Api":
        "Error: Als je je eigen API wilt gebruiken, vul dan de URL in, alvorens een account aan te maken.",
  };

  void updateStatusMessage(String message) {
    String statusMessage = "Error: Onbekende fout."; // Default error message
    for (var entry in errorMessages.entries) {
      if (message.contains(entry.key)) {
        statusMessage = entry.value;
        break;
      }
    }
    setState(() {
      _statusMessage = statusMessage;
    });
  }

  // Method to register user
  void _registerUser() async {
    // prevent register if setting up url is set to true and the url hasn't been set yet
    if (_useOwnAPI && !_ownApiSet) {
      updateStatusMessage("Api");
      return;
    }

    try {
      final keycloakService = KeycloakService();

      await keycloakService.createUser(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _statusMessage = 'User created successfully!';
      });

      // Show a popup dialog to inform user
      _showRegistrationSuccessDialog();
    } on FormatException catch (e) {
      var message = e.message;
      updateStatusMessage(message);
    }
  }

  // Method to show success popup dialog
  void _showRegistrationSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Registratie Succesvol"),
          content: Text("Er is een e-mail verstuurd voor accountverificatie."),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // strip last / off url if it's there
  String stripTrailingSlash(String url) {
    if (url.endsWith('/')) {
      return url.substring(0, url.length - 1);
    }
    return url;
  }

  // Method to set the API URL
  void setApiUrl() {
    if (_apiUrlController.text.isEmpty) {
      setState(() {
        _apiErrorMessage = 'Error: API URL is verplicht in te vullen.';
      });
      return;
    }

    final apiSelectionProvider =
        Provider.of<ApiSelectionProvider>(context, listen: false);

    String apiUrl = _apiUrlController.text;
    apiUrl = stripTrailingSlash(apiUrl);

    // check if the url is reachable
    ApiCheckerService().checkApi(apiUrl).then((value) {
      if (value.keys.first) {
        var keycloakUrl = value.values.first;
        apiSelectionProvider.setSelectedApi(apiUrl);
        apiSelectionProvider.setSelectedKeycloak(keycloakUrl);
        setState(() {
          _ownApiSet = true;
          _apiErrorMessage = '';
        });
      } else {
        setState(() {
          _apiErrorMessage = value.values.first;
        });
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Registreer',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Gebruikersnaam',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: 'Paswoord',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                ),
                Text(
                  _statusMessage,
                  style: TextStyle(
                    color: _statusMessage.startsWith('Error')
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: _registerUser,
                          child: Text(
                            'Registreer',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            );
                          },
                          child: Text(
                            'Log in',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                (!_useOwnAPI)
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _useOwnAPI = true;
                            });
                          },
                          child: Text(
                            'Ik gebruik mijn eigen API',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                      )
                    : Column(children: [
                        // input field for a url or IP address
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: TextField(
                            controller: _apiUrlController,
                            decoration: InputDecoration(
                              labelText: 'API URL',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.link),
                              hintText: 'http://',
                            ),
                            keyboardType: TextInputType.url,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Vul de URL of IP-adres in van je lokaal draaiende API.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: _ownApiSet ? Colors.grey : null,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _useOwnAPI = false;
                                    _statusMessage = '';
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 30,
                                ),
                              ),
                            ),

                            //button to confirm the API URL
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor:
                                        _ownApiSet ? Colors.green : null,
                                  ),
                                  onPressed: () {
                                    setApiUrl();
                                  },
                                  child: Icon(
                                    Icons.check,
                                    size: 30,
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          _apiErrorMessage,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
