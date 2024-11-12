import 'package:flutter/material.dart';
import 'package:frontend/screens/detail_screen.dart';
import 'package:frontend/services/recipe_service.dart';

class CreateRecipeScreen extends StatelessWidget {
  final String preloadedRecipeName;

  const CreateRecipeScreen({super.key, required this.preloadedRecipeName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nieuw recept aanvragen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: RecipeForm(preloadedRecipeName: preloadedRecipeName,),
      ),
    );
  }
}

class RecipeForm extends StatefulWidget {
  final String preloadedRecipeName;
  const RecipeForm({super.key, required this.preloadedRecipeName});

  @override
  State<RecipeForm> createState() => _RecipeFormState();
}

class _RecipeFormState extends State<RecipeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _recipeNameController;
  bool _isLoading = false;
  bool _isRecipeInvalid = false;
  String _recipeInvalidReason = '';

  @override
  void initState() {
    super.initState();
    _recipeNameController = TextEditingController(text: widget.preloadedRecipeName);
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text("Hier kun je de naam van het recept invullen. Je kunt ook een beschrijving toevoegen en een lijst van ingrediënten die je graag in het recept wilt hebben. Wij zullen dan proberen om een recept voor je te maken. Dit kan enkele seconden (tot 30 seconden) duren."),
          const SizedBox(height: 12),
          TextFormField(
            minLines: 1,
            maxLines: 10,
            decoration: const InputDecoration(
                labelText: 'Receptnaam',
                isDense: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                suffixIcon: Icon(Icons.food_bank_outlined)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Voer een receptnaam in';
              }
              return null;
            },
            controller: _recipeNameController,
          ),
          const SizedBox(height: 12),
          _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _isLoading = true;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Recept aangevraagd')),
                      );

                      String response = await RecipeService()
                          .createRecipe(_recipeNameController.text);

                      final uuidRegExp = RegExp(
                        r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
                      );

                      if (!uuidRegExp.hasMatch(response)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(response)),
                        );
                        setState(() {
                          _isLoading = false;
                          _isRecipeInvalid = true;
                          _recipeInvalidReason = response;
                        });
                        await Future.delayed(Duration(seconds: 7));
                        setState(() {
                          _isRecipeInvalid = false;
                          _recipeInvalidReason = '';
                        });

                        return;
                      }

                      setState(() {
                        _isLoading = false;
                      });

                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailScreen(recipeId: response),
                        ),
                      );
                    }
                  },
                  child: const Text('Aanvragen'),
                ),
          if (_isRecipeInvalid)
            Text(
              'Recept kon niet aangemaakt worden om deze reden: $_recipeInvalidReason',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}