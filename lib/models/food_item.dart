class FoodItem {
  final String id;
  final String name;
  final String imagePath;
  final int temperature;
  final int time;
  final int steam;
  final DateTime createdAt;

  FoodItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.temperature,
    required this.time,
    required this.steam,
    required this.createdAt,
  });

  // Create from JSON
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      imagePath: json['imagePath'],
      temperature: json['temperature'],
      time: json['time'],
      steam: json['steam'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imagePath': imagePath,
      'temperature': temperature,
      'time': time,
      'steam': steam,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a copy with updated values
  FoodItem copyWith({
    String? id,
    String? name,
    String? imagePath,
    int? temperature,
    int? time,
    int? steam,
    DateTime? createdAt,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      temperature: temperature ?? this.temperature,
      time: time ?? this.time,
      steam: steam ?? this.steam,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
