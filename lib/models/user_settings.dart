class UserSettings {
  final String? geminiApiKey;
  final bool isDarkMode;
  final String currencySymbol;
  final String currencyCode;

  UserSettings({
    this.geminiApiKey,
    this.isDarkMode = true,
    this.currencySymbol = '₹',
    this.currencyCode = 'INR',
  });

  UserSettings copyWith({
    String? geminiApiKey,
    bool? isDarkMode,
    String? currencySymbol,
    String? currencyCode,
  }) {
    return UserSettings(
      geminiApiKey: geminiApiKey ?? this.geminiApiKey,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      currencyCode: currencyCode ?? this.currencyCode,
    );
  }

  Map<String, dynamic> toJson() => {
    'geminiApiKey': geminiApiKey,
    'isDarkMode': isDarkMode,
    'currencySymbol': currencySymbol,
    'currencyCode': currencyCode,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    geminiApiKey: json['geminiApiKey'],
    isDarkMode: json['isDarkMode'] ?? true,
    currencySymbol: json['currencySymbol'] ?? '₹',
    currencyCode: json['currencyCode'] ?? 'INR',
  );
}
