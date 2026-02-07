class Statistics {
  final String period;
  final String startDate;
  final String endDate;
  final StatsOverview overview;
  final StatsPerformance performance;
  final List<DailyStats> dailyBreakdown;
  final List<PeakHour> peakHours;
  final RevenueBreakdown? revenueBreakdown;
  final StatsGoals? goals;

  Statistics({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.overview,
    required this.performance,
    required this.dailyBreakdown,
    required this.peakHours,
    this.revenueBreakdown,
    this.goals,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      period: json['period'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      overview: StatsOverview.fromJson(json['overview']),
      performance: StatsPerformance.fromJson(json['performance']),
      dailyBreakdown: (json['daily_breakdown'] as List?)
              ?.map((e) => DailyStats.fromJson(e))
              .toList() ??
          [],
      peakHours: (json['peak_hours'] as List?)
              ?.map((e) => PeakHour.fromJson(e))
              .toList() ??
          [],
      revenueBreakdown: json['revenue_breakdown'] != null
          ? RevenueBreakdown.fromJson(json['revenue_breakdown'])
          : null,
      goals: json['goals'] != null ? StatsGoals.fromJson(json['goals']) : null,
    );
  }
}

class StatsOverview {
  final int totalDeliveries;
  final double totalEarnings;
  final double totalDistanceKm;
  final int totalDurationMinutes;
  final double averageRating;
  final double deliveryTrend;
  final double earningsTrend;
  final String currency;

  StatsOverview({
    required this.totalDeliveries,
    required this.totalEarnings,
    required this.totalDistanceKm,
    required this.totalDurationMinutes,
    required this.averageRating,
    required this.deliveryTrend,
    required this.earningsTrend,
    required this.currency,
  });

  factory StatsOverview.fromJson(Map<String, dynamic> json) {
    return StatsOverview(
      totalDeliveries: (json['total_deliveries'] as num?)?.toInt() ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0.0,
      totalDistanceKm: (json['total_distance_km'] as num?)?.toDouble() ?? 0.0,
      totalDurationMinutes: (json['total_duration_minutes'] as num?)?.toInt() ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      deliveryTrend: (json['delivery_trend'] as num?)?.toDouble() ?? 0.0,
      earningsTrend: (json['earnings_trend'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? 'FCFA',
    );
  }
}

class StatsPerformance {
  final int totalAssigned;
  final int totalAccepted;
  final int totalDelivered;
  final int totalCancelled;
  final double acceptanceRate;
  final double completionRate;
  final double cancellationRate;
  final double onTimeRate;
  final double satisfactionRate;

  StatsPerformance({
    required this.totalAssigned,
    required this.totalAccepted,
    required this.totalDelivered,
    required this.totalCancelled,
    required this.acceptanceRate,
    required this.completionRate,
    required this.cancellationRate,
    required this.onTimeRate,
    required this.satisfactionRate,
  });

  factory StatsPerformance.fromJson(Map<String, dynamic> json) {
    return StatsPerformance(
      totalAssigned: (json['total_assigned'] as num?)?.toInt() ?? 0,
      totalAccepted: (json['total_accepted'] as num?)?.toInt() ?? 0,
      totalDelivered: (json['total_delivered'] as num?)?.toInt() ?? 0,
      totalCancelled: (json['total_cancelled'] as num?)?.toInt() ?? 0,
      acceptanceRate: (json['acceptance_rate'] as num?)?.toDouble() ?? 0.0,
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      cancellationRate: (json['cancellation_rate'] as num?)?.toDouble() ?? 0.0,
      onTimeRate: (json['on_time_rate'] as num?)?.toDouble() ?? 0.0,
      satisfactionRate: (json['satisfaction_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DailyStats {
  final String date;
  final String dayName;
  final int deliveries;
  final double earnings;

  DailyStats({
    required this.date,
    required this.dayName,
    required this.deliveries,
    required this.earnings,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: json['date'],
      dayName: json['day_name'],
      deliveries: (json['deliveries'] as num?)?.toInt() ?? 0,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PeakHour {
  final String hour;
  final String label;
  final int count;
  final double percentage;

  PeakHour({
    required this.hour,
    required this.label,
    required this.count,
    required this.percentage,
  });

  factory PeakHour.fromJson(Map<String, dynamic> json) {
    return PeakHour(
      hour: json['hour'],
      label: json['label'],
      count: (json['count'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RevenueBreakdown {
  final double deliveryCommissionsAmount;
  final double deliveryCommissionsPercent;
  final double challengeBonusesAmount;
  final double challengeBonusesPercent;
  final double rushBonusesAmount;
  final double rushBonusesPercent;
  final double total;

  RevenueBreakdown({
    required this.deliveryCommissionsAmount,
    required this.deliveryCommissionsPercent,
    required this.challengeBonusesAmount,
    required this.challengeBonusesPercent,
    required this.rushBonusesAmount,
    required this.rushBonusesPercent,
    required this.total,
  });

  factory RevenueBreakdown.fromJson(Map<String, dynamic> json) {
    return RevenueBreakdown(
      deliveryCommissionsAmount: (json['delivery_commissions']?['amount'] as num?)?.toDouble() ?? 0.0,
      deliveryCommissionsPercent: (json['delivery_commissions']?['percentage'] as num?)?.toDouble() ?? 0.0,
      challengeBonusesAmount: (json['challenge_bonuses']?['amount'] as num?)?.toDouble() ?? 0.0,
      challengeBonusesPercent: (json['challenge_bonuses']?['percentage'] as num?)?.toDouble() ?? 0.0,
      rushBonusesAmount: (json['rush_bonuses']?['amount'] as num?)?.toDouble() ?? 0.0,
      rushBonusesPercent: (json['rush_bonuses']?['percentage'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class StatsGoals {
  final int weeklyTarget;
  final int currentProgress;
  final double progressPercentage;
  final int remaining;

  StatsGoals({
    required this.weeklyTarget,
    required this.currentProgress,
    required this.progressPercentage,
    required this.remaining,
  });

  factory StatsGoals.fromJson(Map<String, dynamic> json) {
    return StatsGoals(
      weeklyTarget: (json['weekly_target'] as num?)?.toInt() ?? 0,
      currentProgress: (json['current_progress'] as num?)?.toInt() ?? 0,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      remaining: (json['remaining'] as num?)?.toInt() ?? 0,
    );
  }
}
