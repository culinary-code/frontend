import 'package:flutter/material.dart';
import 'package:frontend/Services/keycloak_service.dart';

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

  final Map<String, String> errorMessages = {
    "password": "Error: Paswoord is verplicht in te vullen.",
    "invalid-email": "Error: Geen geldig email formaat gegeven.",
    "email": "Error: Email is verplicht in te vullen.",
    "User exists": "Error: Gebruikersnaam is al in gebruik.",
    "User": "Error: Gebruikersnaam is verplicht in te vullen.",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                            MaterialPageRoute(builder: (context) => const LoginPage()),
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
            ],
          ),
        ),
      ),
    );
  }
}
