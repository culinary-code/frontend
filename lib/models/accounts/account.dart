class Account {
  final String userId;
  final String username;
  final int familySize;

  Account({required this.userId, required this.username, required this.familySize});

  static Account fromJson(Map<String, dynamic> json) {
    return Account(
      userId: json['accountId'],
      username: json['name'],
      familySize: json['familySize']
    );
  }
}