/// Ward model to store ward information including English and Malayalam names.
class Ward {
  final int id;
  final String nameEn;
  final String nameMl;
  final String wardNumber;

  Ward({
    required this.id,
    required this.nameEn,
    required this.nameMl,
    required this.wardNumber,
  });

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      id: json['id'] as int,
      nameEn: json['name_en'] as String,
      nameMl: json['name_ml'] as String,
      wardNumber: json['ward_number']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_en': nameEn,
      'name_ml': nameMl,
      'ward_number': wardNumber,
    };
  }

  @override
  String toString() => '$wardNumber - $nameEn ($nameMl)';
}
