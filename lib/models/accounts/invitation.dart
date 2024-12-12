class Invitation {
  final String groupId;
  final String email;
  final String inviterId;
  final String inviterName;
  final String invitedUserName;

  Invitation({required this.groupId, required this.email, required this.inviterId, required this.inviterName, required this.invitedUserName});

  static Invitation fromJson(Map<String, dynamic> json) {
    return Invitation(inviterId: json['inviterId'], groupId: json['groupId'], email: json['email'], inviterName: json['inviterName'], invitedUserName: json['invitedUserName']);
  }
}