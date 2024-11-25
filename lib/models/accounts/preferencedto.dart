class PreferenceDto {

  final String preferenceName;
  final bool standardPreference;

  PreferenceDto({
    required this.preferenceName,
    this.standardPreference = false,
  });

  factory PreferenceDto.fromJson(Map<String, dynamic> json) {
    return PreferenceDto(
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
