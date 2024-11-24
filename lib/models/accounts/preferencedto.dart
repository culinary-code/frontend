class PreferenceDto {

  final String preferenceName;
  final bool standardPreference;

  PreferenceDto({
    required this.preferenceName,
    this.standardPreference = false,
  });

  // Factory method to create a Preference object from JSON
  factory PreferenceDto.fromJson(Map<String, dynamic> json) {
    return PreferenceDto(
      preferenceName: json['preferenceName'] as String,
      standardPreference: json['standardPreference'] as bool,
    );
  }

  // Method to convert a Preference object to JSON
  Map<String, dynamic> toJson() {
    return {
      'preferenceName': preferenceName,
      'standardPreference': standardPreference,
    };
  }
  /*final String preferenceName;

  PreferenceDto({
    required this.preferenceName,
  });

  factory PreferenceDto.fromJson(Map<String, dynamic> json) {
    return PreferenceDto(
      preferenceName: json['preferenceName'],
    );
  }

  // Convert PreferenceDto to JSON
  Map<String, dynamic> toJson() {
    return {
      'preferenceName': preferenceName,
    };
  }*/
}
