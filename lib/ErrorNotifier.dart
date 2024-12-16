import 'package:flutter/material.dart';

class ErrorNotifier with ChangeNotifier {
  String? _errorMessage;

  // Getter for the current error message
  String? get errorMessage => _errorMessage;

  // Method to show an error
  void showError(String message) {
    _errorMessage = message;
    notifyListeners(); // Notify listeners of the change
  }

  // Method to clear the error
  void clearError() {
    _errorMessage = null;
    notifyListeners(); // Notify listeners of the change
  }
}