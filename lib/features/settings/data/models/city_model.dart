class CountryModel {
  final String name;
  final String code;
  final bool isLocked;

  const CountryModel({
    required this.name,
    required this.code,
    this.isLocked = true,
  });

  static const CountryModel turkey = CountryModel(
    name: 'Türkiye',
    code: 'TR',
    isLocked: true,
  );
}

class CityModel {
  final String name;
  final String plate;
  final double latitude;
  final double longitude;
  final List<String> counties;

  const CityModel({
    required this.name,
    required this.plate,
    required this.latitude,
    required this.longitude,
    required this.counties,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      name: json['name'] as String,
      plate: json['plate'] as String,
      latitude: double.parse(json['latitude'] as String),
      longitude: double.parse(json['longitude'] as String),
      counties: List<String>.from(json['counties'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'plate': plate,
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'counties': counties,
    };
  }

  String get displayName {
    if (name.isEmpty) return name;

    final Map<String, String> turkishUpperCase = {
      'i': 'İ',
      'ı': 'I',
      'ğ': 'Ğ',
      'ü': 'Ü',
      'ş': 'Ş',
      'ö': 'Ö',
      'ç': 'Ç',
    };

    String firstChar = name[0];
    String upperFirst = turkishUpperCase[firstChar] ?? firstChar.toUpperCase();

    return upperFirst + name.substring(1);
  }

  static String capitalizeCounty(String county) {
    if (county.isEmpty) return county;

    final Map<String, String> turkishUpperCase = {
      'i': 'İ',
      'ı': 'I',
      'ğ': 'Ğ',
      'ü': 'Ü',
      'ş': 'Ş',
      'ö': 'Ö',
      'ç': 'Ç',
    };

    List<String> words = county.split(' ');
    List<String> capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      String firstChar = word[0];
      String upperFirst =
          turkishUpperCase[firstChar] ?? firstChar.toUpperCase();
      return upperFirst + word.substring(1);
    }).toList();

    return capitalizedWords.join(' ');
  }
}
