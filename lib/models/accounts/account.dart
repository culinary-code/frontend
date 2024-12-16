import 'package:frontend/models/accounts/preference.dart';
import 'package:frontend/models/accounts/preferencedto.dart';

class Account {
  final String userId;
  final String username;
  final int familySize;
  final String? chosenGroupId;

  Account({required this.userId, required this.username, required this.familySize, required this.chosenGroupId});

  static Account fromJson(Map<String, dynamic> json) {
    return Account(
      userId: json['accountId'],
      username: json['name'],
      familySize: json['familySize'],
      chosenGroupId: json['chosenGroupId']
    );
  }
}