import 'package:frontend/models/recipes/recipe.dart';

class InstructionStep {
  final String instructionStepId;
  final int stepNumber;
  final String instruction;
  final Recipe recipe;

  InstructionStep({
    required this.instructionStepId,
    required this.stepNumber,
    required this.instruction,
    required this.recipe,
  });
}