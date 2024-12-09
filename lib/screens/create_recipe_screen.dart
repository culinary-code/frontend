import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/models/recipes/recipe_suggestion.dart';
import 'package:frontend/screens/detail_screen.dart';
import 'package:frontend/services/recipe_service.dart';
import 'package:frontend/state/recipe_filter_options_provider.dart';
import 'package:frontend/widgets/filter/filter_button.dart';
import 'package:frontend/widgets/filter/filter_option_chip.dart';
import 'package:provider/provider.dart';

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
        child: RecipeForm(
          preloadedRecipeName: preloadedRecipeName,
        ),
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
  bool _requestButtonDisabled = false;
  bool _isRecipeInvalid = false;
  String _recipeInvalidReason = '';
  bool showAllFilterOptions = false;

  late List<RecipeSuggestion> _recipeSuggestions = [];

  void _fetchRecipeSuggestions(BuildContext context) async {
    final filterProvider =
        Provider.of<RecipeFilterOptionsProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final suggestions = await RecipeService().getRecipeSuggestions(
          _recipeNameController.text, filterProvider.filterOptions);

      if (suggestions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Geen suggesties gevonden, probeer een andere naam of specificaties')),
        );
      } else {
        setState(() {
          _recipeSuggestions = suggestions;
        });
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> createRecipe(BuildContext context, String name, String description) async {
    final filterProvider =
        Provider.of<RecipeFilterOptionsProvider>(context, listen: false);

    if (_formKey.currentState!.validate()) {
      setState(() {
        _requestButtonDisabled = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recept aangevraagd')),
      );

      String response = await RecipeService().createRecipe(
          _recipeNameController.text,
          description,
          filterProvider.filterOptions);

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

      if (!mounted) return;

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(recipeId: response),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _recipeNameController =
        TextEditingController(text: widget.preloadedRecipeName);
  }

  @override
  void dispose() {
    _recipeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterProvider =
        Provider.of<RecipeFilterOptionsProvider>(context, listen: true);

    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextFormField(
                          minLines: 1,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            labelText: 'Receptnaam',
                            isDense: true,
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            suffixIcon: Icon(Icons.food_bank_outlined),
                          ),
                          validator: (value) {
                            if ((value == null || value.isEmpty) &&
                                filterProvider.filterOptions.isEmpty) {
                              return 'Voer een receptnaam of specificaties in';
                            }
                            return null;
                          },
                          controller: _recipeNameController,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilterButton(
                        onFilterChanged: (bool value) => {},
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  FilterOptionsDisplayWidget(
                    onDelete: () {
                      filterProvider.filterOptions.clear();
                      filterProvider.onFilterChanged();
                    },
                  ),
                  const SizedBox(height: 12),
                  _isLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton(
                        onPressed: _requestButtonDisabled
                            ? null
                            : () => _fetchRecipeSuggestions(context),
                          child: const Text('Aanvragen'),
                        ),
                  if (_isRecipeInvalid)
                    Column(children: [
                      const SizedBox(height: 12),
                      Text(
                        'We kunnen dit recept niet aanmaken.',
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        _recipeInvalidReason,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ]),
                  SizedBox(height: 12),
                  if (_recipeSuggestions.isNotEmpty)
                    RecipeSuggestionList(
                      recipes: _recipeSuggestions
                          .asMap()
                          .map((index, recipeSuggestion) => MapEntry(
                              recipeSuggestion.description,
                              recipeSuggestion.recipeName))
                          .map((key, value) => MapEntry(value, key)),
                      onRecipeSelected: (recipeName, recipeDescription) async {
                        setState(() {
                          _recipeNameController.text = recipeName;

                          // clear recipesuggestion except for recipename
                          _recipeSuggestions = _recipeSuggestions
                              .where((element) => element.recipeName == recipeName)
                              .toList();

                        });
                        await createRecipe(
                            context, recipeName, recipeDescription);
                        filterProvider.onFilterChanged();
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RecipeSuggestionList extends StatefulWidget {
  final Map<String, String> recipes;
  final Function(String, String) onRecipeSelected;

  const RecipeSuggestionList(
      {super.key, required this.recipes, required this.onRecipeSelected});

  @override
  _RecipeSuggestionListState createState() => _RecipeSuggestionListState();
}

class _RecipeSuggestionListState extends State<RecipeSuggestionList> {
  String? _selectedRecipe;
  List<String> _funnyMessages = [
    "Even geduld, de AI is aan het brainstormen...",
    "Bijna klaar, de AI is nog even aan het nadenken...",
    "De AI is de ingrediënten aan het analyseren...",
    "De AI is het recept aan het perfectioneren...",
    "De AI is bezig met een meesterwerk..."
  ];
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  void _onCardTap(String recipeName, String description) {
    setState(() {
      _selectedRecipe = recipeName;
      _startMessageRotation();
    });
    widget.onRecipeSelected(recipeName, description);
  }

  void _startMessageRotation() {
    _messageTimer?.cancel();
    _messageTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_selectedRecipe == null) {
        timer.cancel();
      } else {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _funnyMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Text('Kies uit een van onze suggesties'),
        const SizedBox(height: 12),
        for (var recipe in widget.recipes.entries)
          RecipeSuggestionCard(
            recipeName: recipe.key,
            recipeDescription: recipe.value,
            isSelected: _selectedRecipe == recipe.key,
            isDisabled:
                _selectedRecipe != null && _selectedRecipe != recipe.key,
            onTap: () => _onCardTap(recipe.key, recipe.value),
            funnyMessage: _selectedRecipe == recipe.key
                ? _funnyMessages[_currentMessageIndex]
                : null,
          ),
      ],
    );
  }
}

class RecipeSuggestionCard extends StatelessWidget {
  final String recipeName;
  final String recipeDescription;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;
  final String? funnyMessage;

  const RecipeSuggestionCard({
    super.key,
    required this.recipeName,
    required this.recipeDescription,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
    this.funnyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDisabled ? Colors.grey[300] : null,
      child: InkWell(
        onTap: isDisabled || isSelected ? null : onTap,
        child: Column(
          children: [
            ListTile(
              title: Text(recipeName),
              subtitle: Text(recipeDescription),
            ),
            if (isSelected)
              Column(
                children: [
                  SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(strokeWidth: 6),
                  ),
                  const SizedBox(height: 12),
                  Text(
                      funnyMessage ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
