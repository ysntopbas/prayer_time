class PrayerTimeResponse {
  final int code;
  final PrayerTimeModel data;

  PrayerTimeResponse({required this.code, required this.data});

  factory PrayerTimeResponse.fromJson(Map<String, dynamic> json) {
    return PrayerTimeResponse(
      code: json['code'],
      data: PrayerTimeModel.fromJson(json['data']),
    );
  }
}

class PrayerTimeModel {
  Timings? timings;
  Date? date;
  Meta? meta;

  PrayerTimeModel({this.timings, this.date, this.meta});

  PrayerTimeModel.fromJson(Map<String, dynamic> json) {
    timings = json['timings'] != null
        ? Timings.fromJson(json['timings'])
        : null;
    date = json['date'] != null ? Date.fromJson(json['date']) : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (timings != null) {
      data['timings'] = timings!.toJson();
    }
    if (date != null) {
      data['date'] = date!.toJson();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class Timings {
  String? fajr;
  String? sunrise;
  String? dhuhr;
  String? asr;
  String? sunset;
  String? maghrib;
  String? isha;
  String? imsak;

  Timings({
    this.fajr,
    this.sunrise,
    this.dhuhr,
    this.asr,
    this.sunset,
    this.maghrib,
    this.isha,
    this.imsak,
  });

  Timings.fromJson(Map<String, dynamic> json) {
    fajr = json['Fajr'];
    sunrise = json['Sunrise'];
    dhuhr = json['Dhuhr'];
    asr = json['Asr'];
    sunset = json['Sunset'];
    maghrib = json['Maghrib'];
    isha = json['Isha'];
    imsak = json['Imsak'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Fajr'] = fajr;
    data['Sunrise'] = sunrise;
    data['Dhuhr'] = dhuhr;
    data['Asr'] = asr;
    data['Sunset'] = sunset;
    data['Maghrib'] = maghrib;
    data['Isha'] = isha;
    data['Imsak'] = imsak;
    return data;
  }
}

class Date {
  String? readable;
  String? timestamp;
  Hijri? hijri;
  Gregorian? gregorian;

  Date({this.readable, this.timestamp, this.hijri, this.gregorian});

  Date.fromJson(Map<String, dynamic> json) {
    readable = json['readable'];
    timestamp = json['timestamp'];
    hijri = json['hijri'] != null ? Hijri.fromJson(json['hijri']) : null;
    gregorian = json['gregorian'] != null
        ? Gregorian.fromJson(json['gregorian'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['readable'] = readable;
    data['timestamp'] = timestamp;
    if (hijri != null) {
      data['hijri'] = hijri!.toJson();
    }
    if (gregorian != null) {
      data['gregorian'] = gregorian!.toJson();
    }
    return data;
  }
}

class Hijri {
  String? hijridate;
  String? hijriformat;
  String? hijriday;
  Hijriweekday? hijriweekday;
  Hijrimonth? hijrimonth;
  String? hijriyear;
  Hijridesignation? hijridesignation;
  List<String>? holidays;
  List<String>? adjustedHolidays;
  String? method;

  Hijri({
    this.hijridate,
    this.hijriformat,
    this.hijriday,
    this.hijriweekday,
    this.hijrimonth,
    this.hijriyear,
    this.hijridesignation,
    this.holidays,
    this.adjustedHolidays,
    this.method,
  });

  Hijri.fromJson(Map<String, dynamic> json) {
    hijridate = json['date'];
    hijriformat = json['format'];
    hijriday = json['day'];
    hijriweekday = json['weekday'] != null
        ? Hijriweekday.fromJson(json['weekday'])
        : null;
    hijrimonth = json['month'] != null
        ? Hijrimonth.fromJson(json['month'])
        : null;
    hijriyear = json['year'];
    hijridesignation = json['designation'] != null
        ? Hijridesignation.fromJson(json['designation'])
        : null;
    if (json['holidays'] != null) {
      holidays = <String>[];
      json['holidays'].forEach((v) {
        holidays!.add(v);
      });
    }
    if (json['adjustedHolidays'] != null) {
      adjustedHolidays = <String>[];
      json['adjustedHolidays'].forEach((v) {
        adjustedHolidays!.add(v);
      });
    }
    method = json['method'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hijridate'] = hijridate;
    data['hijriformat'] = hijriformat;
    data['hijriday'] = hijriday;
    if (hijriweekday != null) {
      data['hijriweekday'] = hijriweekday!.toJson();
    }
    if (hijrimonth != null) {
      data['hijrimonth'] = hijrimonth!.toJson();
    }
    data['hijriyear'] = hijriyear;
    if (hijridesignation != null) {
      data['hijridesignation'] = hijridesignation!.toJson();
    }
    if (holidays != null) {
      data['holidays'] = holidays!.map((v) => v).toList();
    }
    if (adjustedHolidays != null) {
      data['adjustedHolidays'] = adjustedHolidays!.map((v) => v).toList();
    }
    data['method'] = method;
    return data;
  }
}

class Hijriweekday {
  String? en;
  String? ar;

  Hijriweekday({this.en, this.ar});

  Hijriweekday.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['en'] = en;
    data['ar'] = ar;
    return data;
  }
}

class Hijrimonth {
  int? hijrinumber;
  String? hijrien;
  String? hijriar;
  int? hijridays;

  Hijrimonth({this.hijrinumber, this.hijrien, this.hijriar, this.hijridays});

  Hijrimonth.fromJson(Map<String, dynamic> json) {
    hijrinumber = json['number'];
    hijrien = json['en'];
    hijriar = json['ar'];
    hijridays = json['days'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hijrinumber'] = hijrinumber;
    data['hijrien'] = hijrien;
    data['hijriar'] = hijriar;
    data['hijridays'] = hijridays;
    return data;
  }
}

class Hijridesignation {
  String? hijriabbreviated;
  String? hijriexpanded;

  Hijridesignation({this.hijriabbreviated, this.hijriexpanded});

  Hijridesignation.fromJson(Map<String, dynamic> json) {
    hijriabbreviated = json['abbreviated'];
    hijriexpanded = json['expanded'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hijriabbreviated'] = hijriabbreviated;
    data['hijriexpanded'] = hijriexpanded;
    return data;
  }
}

class Gregorian {
  String? date;
  String? format;
  String? day;
  Weekday? weekday;
  Month? month;
  String? year;
  Designation? designation;
  bool? lunarSighting;

  Gregorian({
    this.date,
    this.format,
    this.day,
    this.weekday,
    this.month,
    this.year,
    this.designation,
    this.lunarSighting,
  });

  Gregorian.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    format = json['format'];
    day = json['day'];
    weekday = json['weekday'] != null
        ? Weekday.fromJson(json['weekday'])
        : null;
    month = json['month'] != null ? Month.fromJson(json['month']) : null;
    year = json['year'];
    designation = json['designation'] != null
        ? Designation.fromJson(json['designation'])
        : null;
    lunarSighting = json['lunarSighting'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['format'] = format;
    data['day'] = day;
    if (weekday != null) {
      data['weekday'] = weekday!.toJson();
    }
    if (month != null) {
      data['month'] = month!.toJson();
    }
    data['year'] = year;
    if (designation != null) {
      data['designation'] = designation!.toJson();
    }
    data['lunarSighting'] = lunarSighting;
    return data;
  }
}

class Weekday {
  String? en;

  Weekday({this.en});

  Weekday.fromJson(Map<String, dynamic> json) {
    en = json['en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['en'] = en;
    return data;
  }
}

class Month {
  int? number;
  String? en;

  Month({this.number, this.en});

  Month.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    en = json['en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number'] = number;
    data['en'] = en;
    return data;
  }
}

class Designation {
  String? abbreviated;
  String? expanded;

  Designation({this.abbreviated, this.expanded});

  Designation.fromJson(Map<String, dynamic> json) {
    abbreviated = json['abbreviated'];
    expanded = json['expanded'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['abbreviated'] = abbreviated;
    data['expanded'] = expanded;
    return data;
  }
}

class Meta {
  double? latitude;
  double? longitude;
  String? timezone;
  Method? method;
  String? latitudeAdjustmentMethod;
  String? midnightMode;
  String? school;

  Meta({
    this.latitude,
    this.longitude,
    this.timezone,
    this.method,
    this.latitudeAdjustmentMethod,
    this.midnightMode,
    this.school,
  });

  Meta.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    timezone = json['timezone'];
    method = json['method'] != null ? Method.fromJson(json['method']) : null;
    latitudeAdjustmentMethod = json['latitudeAdjustmentMethod'];
    midnightMode = json['midnightMode'];
    school = json['school'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['timezone'] = timezone;
    if (method != null) {
      data['method'] = method!.toJson();
    }
    data['latitudeAdjustmentMethod'] = latitudeAdjustmentMethod;
    data['midnightMode'] = midnightMode;
    data['school'] = school;

    return data;
  }
}

class Method {
  int? id;
  String? name;
  Params? params;
  Location? location;

  Method({this.id, this.name, this.params, this.location});

  Method.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    params = json['params'] != null ? Params.fromJson(json['params']) : null;
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    if (params != null) {
      data['params'] = params!.toJson();
    }
    if (location != null) {
      data['location'] = location!.toJson();
    }
    return data;
  }
}

class Params {
  int? fajr;
  int? isha;

  Params({this.fajr, this.isha});

  Params.fromJson(Map<String, dynamic> json) {
    fajr = json['Fajr'];
    isha = json['Isha'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Fajr'] = fajr;
    data['Isha'] = isha;
    return data;
  }
}

class Location {
  double? latitude;
  double? longitude;

  Location({this.latitude, this.longitude});

  Location.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}
