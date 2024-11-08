import 'package:flutter/material.dart';
import 'package:frontend/screens/keycloak/registration_screen.dart';
import '../../Services/keycloak_service.dart';
import '../../navigation_menu.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final KeycloakService _keycloakService = KeycloakService();
  String? _errorMessage;

  // Variable to manage password visibility
  bool _obscureText = true;

  void _login() async {
    try {
      final success = await _keycloakService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        // Handle successful login (e.g., navigate to the next screen)
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationMenu()),
        );
      } else {
        setState(() {
          _errorMessage = 'Login mislukt. Kijk je gegevens na.';
        });
      }
    } on FormatException catch (e) {
      var message = e.message;
      if (message.contains("Account is not fully set up")) {
        setState(() {
          _errorMessage =
              'Email is nog niet geverifieerd of account gegevens missen. Vul deze aan via de link in de email.';
        });
      } else if (message.contains("Invalid user credentials")) {
        setState(() {
          _errorMessage = 'Login mislukt: controleer je gegevens.';
        });
      } else {
        setState(() {
          _errorMessage = 'Login mislukt: ${e.message}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // The "Log in" label at 1/3 of the screen height
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                // Responsive to screen height
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'Log in',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30), // Spacer between title and fields

              // Email or username input field
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Email or gebruikersnaam',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 20), // Spacer between email and password fields

              // Password input field
              TextField(
                controller: _passwordController,
                obscureText: _obscureText,
                // Controls the visibility of the text
                decoration: InputDecoration(
                  labelText: 'Paswoord',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Change the icon depending on the state of _obscureText
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        // Toggle the visibility of the password
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 20),
                Text(_errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red)),
              ],
              SizedBox(height: 30), // Spacer between password field and buttons

              // Buttons in a row, taking equal space
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Log in button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle login logic
                          _login();
                        },
                        child: Text(
                          'Log in',
                          style: TextStyle(
                            fontSize: 20, // Set the text size here
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Register button
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle register logic
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                          );
                        },
                        child: Text(
                          'Registreer',
                          style: TextStyle(
                            fontSize: 20, // Set the text size here
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
