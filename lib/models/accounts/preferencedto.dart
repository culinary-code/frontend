class PreferenceDto {

  final String preferenceId;
  final String preferenceName;
  final bool standardPreference;

  PreferenceDto({
    required this.preferenceId,
    required this.preferenceName,
    this.standardPreference = false,
  });

  factory PreferenceDto.fromJson(Map<String, dynamic> json) {
    return PreferenceDto(
      preferenceId: json['preferenceId'] as String,
      preferenceName: json['preferenceName'] as String,
      standardPreference: json['standardPreference'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preferenceName': preferenceName,
      'standardPreference': standardPreference,
    };
  }
}
