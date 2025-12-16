// Analytics data models

class StudySummary {
  final int totalMinutesToday;
  final int totalMinutesThisWeek;
  final int totalMinutesThisMonth;
  final int totalSessions;
  final int averageSessionMinutes;
  final SubjectStudyData? mostStudiedSubject;
  final int? bestStudyHour;

  StudySummary({
    required this.totalMinutesToday,
    required this.totalMinutesThisWeek,
    required this.totalMinutesThisMonth,
    required this.totalSessions,
    required this.averageSessionMinutes,
    this.mostStudiedSubject,
    this.bestStudyHour,
  });

  factory StudySummary.fromJson(Map<String, dynamic> json) {
    return StudySummary(
      totalMinutesToday: json['totalMinutesToday'] ?? 0,
      totalMinutesThisWeek: json['totalMinutesThisWeek'] ?? 0,
      totalMinutesThisMonth: json['totalMinutesThisMonth'] ?? 0,
      totalSessions: json['totalSessions'] ?? 0,
      averageSessionMinutes: json['averageSessionMinutes'] ?? 0,
      mostStudiedSubject: json['mostStudiedSubject'] != null
          ? SubjectStudyData.fromJson(json['mostStudiedSubject'])
          : null,
      bestStudyHour: json['bestStudyHour'],
    );
  }
}

class DailyStudyData {
  final String date;
  final int minutes;
  final int sessions;

  DailyStudyData({
    required this.date,
    required this.minutes,
    required this.sessions,
  });

  factory DailyStudyData.fromJson(Map<String, dynamic> json) {
    return DailyStudyData(
      date: json['date'] ?? '',
      minutes: json['minutes'] ?? 0,
      sessions: json['sessions'] ?? 0,
    );
  }
}

class SubjectStudyData {
  final String subjectId;
  final String subjectName;
  final String subjectColor;
  final int totalMinutes;
  final int sessionCount;

  SubjectStudyData({
    required this.subjectId,
    required this.subjectName,
    required this.subjectColor,
    required this.totalMinutes,
    required this.sessionCount,
  });

  factory SubjectStudyData.fromJson(Map<String, dynamic> json) {
    return SubjectStudyData(
      subjectId: json['subjectId'] ?? '',
      subjectName: json['subjectName'] ?? '',
      subjectColor: json['subjectColor'] ?? '#6366F1',
      totalMinutes: json['totalMinutes'] ?? 0,
      sessionCount: json['sessionCount'] ?? 0,
    );
  }
}

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final String? lastStudyDate;

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastStudyDate,
  });

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastStudyDate: json['lastStudyDate'],
    );
  }
}

class AnalyticsData {
  final StudySummary summary;
  final List<DailyStudyData> dailyData;
  final List<SubjectStudyData> subjectData;
  final StreakData streaks;

  AnalyticsData({
    required this.summary,
    required this.dailyData,
    required this.subjectData,
    required this.streaks,
  });
}
