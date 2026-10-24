class DayHours {
  final String open;
  final String close;

  const DayHours({required this.open, required this.close});

  static DayHours? fromJson(dynamic json) {
    if (json == null) return null;
    final list = json as List;
    return DayHours(open: list[0] as String, close: list[1] as String);
  }
}

class HoursInfo {
  final DayHours? weekday;
  final DayHours? sat;
  final DayHours? sun;
  final DayHours? holiday;

  const HoursInfo({this.weekday, this.sat, this.sun, this.holiday});

  static HoursInfo? fromJson(dynamic json) {
    if (json == null) return null;
    final map = json as Map<String, dynamic>;
    return HoursInfo(
      weekday: DayHours.fromJson(map['weekday']),
      sat: DayHours.fromJson(map['sat']),
      sun: DayHours.fromJson(map['sun']),
      holiday: DayHours.fromJson(map['holiday']),
    );
  }
}
