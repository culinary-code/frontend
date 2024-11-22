class PreferenceDto {
  final String preferenceId;
  final String preferenceName;

  PreferenceDto({
    required this.preferenceId,
    required this.preferenceName,
  });

  factory PreferenceDto.fromJson(Map<String, dynamic> json) {
    return PreferenceDto(
      preferenceId: json['preferenceId'],
      preferenceName: json['preferenceName'],
    );
  }

  // Convert PreferenceDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'preferenceId': preferenceId,
      'preferenceName': preferenceName,
    };
  }
}
