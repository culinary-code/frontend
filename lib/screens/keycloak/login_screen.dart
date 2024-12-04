import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/api_checker_service.dart';
import 'package:frontend/services/keycloak_service.dart';
import 'package:frontend/navigation_menu.dart';
import 'package:frontend/state/api_selection_provider.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final KeycloakService _keycloakService = KeycloakService();
  String? _errorMessage;

  final TextEditingController _apiUrlController = TextEditingController();
  final TextEditingController _apiUrlPrefixController =
      TextEditingController(text: 'http://');
  bool _useOwnAPI = false;
  bool _isCheckingApi = false;
  String _apiErrorMessage = '';
  bool _ownApiSet = false;

  bool get developmentMode =>
      dotenv.env['DEVELOPMENT_MODE'] == 'true' ? true : false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    if (developmentMode) {
      _loginDevelopment();
    } else {
      _loginSecured();
    }
  }

  void _loginSecured() async {
    try {
      final success = await _keycloakService.loginSecured();

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigationMenu()),
        );
      } else {
        setState(() {
          _errorMessage = 'Login mislukt.';
        });
      }
    } on FlutterAppAuthUserCancelledException catch (e) {
      // ignore exception to stay on the login page if user cancels the login
    } on FormatException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Er is een fout opgetreden: $e';
      });
    }
  }

  void _loginDevelopment() async {
    try {
      final success = await _keycloakService.loginDevelopment(
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
          _errorMessage = 'Login mislukt.';
        });
      }
    } on FormatException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Er is een fout opgetreden: $e';
      });
    }
  }

  // strip last '/' off url if it's there
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
        _apiErrorMessage = 'Vul een URL in.';
      });
      return;
    }

    final apiSelectionProvider =
        Provider.of<ApiSelectionProvider>(context, listen: false);

    String apiUrl = _apiUrlPrefixController.text + _apiUrlController.text;
    apiUrl = stripTrailingSlash(apiUrl);

    setState(() {
      _isCheckingApi = true;
    });

    // check if the url is reachable
    ApiCheckerService().checkApi(apiUrl).then((value) async {
      setState(() {
        _isCheckingApi = false;
      });

      if (value.keys.first) {
        var keycloakUrl = value.values.first;
        await apiSelectionProvider.setSelectedApi(apiUrl);
        await apiSelectionProvider.setSelectedKeycloak(keycloakUrl);
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
                  height: MediaQuery.of(context).size.height * 0.15,
                  // Responsive to screen height
                ),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    'assets/images/culinarycode_logo.png',
                    height: 200,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Culinary Code',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Spacer between title and fields

                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  Text(_errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red)),
                ],

                // Spacer between password field and buttons
                SizedBox(height: 30),

                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    (developmentMode)
                        ? Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: TextField(
                                  controller: _usernameController,
                                  decoration: InputDecoration(
                                    labelText: 'Gebruikersnaam',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.person),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: TextField(
                                  controller: _passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'Wachtwoord',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.lock),
                                  ),
                                  obscureText: true,
                                ),
                              ),
                              SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: Size(double.infinity, 40),
                                  ),
                                  onPressed: () {
                                    _keycloakService.createUserDevelopment(
                                      username: _usernameController.text,
                                      password: _passwordController.text,
                                    );
                                  },
                                  child: Text(
                                    'Account aanmaken',
                                    style: TextStyle(
                                      fontSize: 20, // Set the text size here
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                            ],
                          )
                        : Container(),

                    // Log in button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 40),
                        ),
                        onPressed: () {
                          // Handle login logic
                          _login();
                        },
                        child: Text(
                          'Aanmelden',
                          style: TextStyle(
                            fontSize: 20, // Set the text size here
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    (!_useOwnAPI)
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 40),
                              ),
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
                            SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  // dropdown menu to swap between http:// and https://
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 2, 0),
                                    child: DropdownButton<String>(
                                      value: _apiUrlPrefixController.text,
                                      isDense: false,
                                      alignment: Alignment.centerRight,
                                      borderRadius: BorderRadius.circular(5),
                                      items: <String>['http://', 'https://']
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? value) {
                                        setState(() {
                                          _apiUrlPrefixController.text = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  // input field for a url or IP address
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: TextField(
                                        controller: _apiUrlController,
                                        decoration: InputDecoration(
                                          labelText: 'API URL',
                                          border: OutlineInputBorder(),
                                          suffixIcon: Icon(Icons.link),
                                        ),
                                        keyboardType: TextInputType.url,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor:
                                          _ownApiSet ? Colors.grey : null,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _useOwnAPI = false;
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor:
                                            _ownApiSet ? Colors.green : null,
                                      ),
                                      onPressed: () {
                                        setApiUrl();
                                      },
                                      child: _isCheckingApi
                                          ? SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Icon(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
