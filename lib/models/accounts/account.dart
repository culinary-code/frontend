class Account {
  final String userId;
  final String username;

  Account({required this.userId, required this.username});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      userId: json['accountId'],
      username: json['name'],
    );
  }
}