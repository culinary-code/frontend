class Group {
  final String groupId;
  final String groupName;
  bool isGroupMode;

  Group({required this.groupId, required this.groupName, this.isGroupMode = false});

  static Group fromJson(Map<String, dynamic> json) {
    return Group(groupId: json['groupId'], groupName: json['groupName']);
  }
}
