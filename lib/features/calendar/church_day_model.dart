enum FastingType { none, strict, fishAllowed, oilAllowed }

class ChurchDay {
  final DateTime date;
  final String title;
  final String? description;
  final FastingType fastingType;
  final bool isGreatFeast; // Дванадесяті свята (виділяються червоним/золотим)
  final List<String>? prayers;

  const ChurchDay({
    required this.date,
    required this.title,
    this.description,
    this.fastingType = FastingType.none,
    this.isGreatFeast = false,
    this.prayers,
  });

  factory ChurchDay.fromJson(Map<String, dynamic> json) {
    return ChurchDay(
      date: DateTime.parse(json['date']),
      title: json['title'],
      description: json['description'],
      isGreatFeast: json['isGreatFeast'] ?? false,
      fastingType: _parseFastingType(json['fastingType']),
      prayers: json['prayers'] != null ? List<String>.from(json['prayers']) : null,
    );
  }

  static FastingType _parseFastingType(String? type) {
    switch (type) {
      case 'strict':
        return FastingType.strict;
      case 'fishAllowed':
        return FastingType.fishAllowed;
      case 'oilAllowed':
        return FastingType.oilAllowed;
      default:
        return FastingType.none;
    }
  }

  // Допоміжний метод для отримання тексту про піст
  String get fastingText {
    switch (fastingType) {
      case FastingType.strict:
        return 'Суворий піст';
      case FastingType.fishAllowed:
        return 'Піст (дозволяється риба)';
      case FastingType.oilAllowed:
        return 'Піст (дозволяється олія)';
      case FastingType.none:
      default:
        return 'Немає посту';
    }
  }
}
