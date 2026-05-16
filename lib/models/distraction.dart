
import 'dart:convert';

class Distraction {
  final String description;
  final DateTime timestamp;

  Distraction({required this.description, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'description': description,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Distraction.fromJson(Map<String, dynamic> json) => Distraction(
        description: json['description'],
        timestamp: DateTime.parse(json['timestamp']),
      );

  static String encode(List<Distraction> distractions) => json.encode(
        distractions
            .map<Map<String, dynamic>>((distraction) => distraction.toJson())
            .toList(),
      );

  static List<Distraction> decode(String distractions) =>
      (json.decode(distractions) as List<dynamic>)
          .map<Distraction>((item) => Distraction.fromJson(item))
          .toList();
}
