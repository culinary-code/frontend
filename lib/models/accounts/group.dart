class Group {
  final String groupId;
  final String groupName;

  Group({required this.groupId, required this.groupName});

  static Group fromJson(Map<String, dynamic> json) {
    return Group(groupId: json['groupId'], groupName: json['groupName']);
  }
}
