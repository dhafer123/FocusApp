class FocusSessionRecord {
  const FocusSessionRecord({
    required this.date,
    required this.durationMinutes,
  });

  final DateTime date;
  final int durationMinutes;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'durationMinutes': durationMinutes,
    };
  }

  factory FocusSessionRecord.fromJson(Map<String, dynamic> json) {
    return FocusSessionRecord(
      date: DateTime.parse(json['date'] as String),
      durationMinutes: json['durationMinutes'] as int,
    );
  }
}
