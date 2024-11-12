class Account {
  final String accountId;
  final String username;

  Account({required this.accountId, required this.username});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      accountId: json['accountId'],
      username: json['name'],
    );
  }
}