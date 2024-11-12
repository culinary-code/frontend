class Account {
  final String userId;
  final String userName;

  Account({required this.userId, required this.userName});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      userId: json['accountId'],
      userName: json['name'],
    );
  }
}
