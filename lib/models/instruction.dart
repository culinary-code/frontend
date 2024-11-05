class Instruction {
  final String step;

  Instruction({
    required this.step
  });

  static List<Instruction> instructionList() {
    return [
      Instruction(step: "Schil de aardappelen"),
      Instruction(step: "Snij de aardappelen in frietvorm"),
    ];
  }
}

