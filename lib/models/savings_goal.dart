import 'package:flutter/material.dart';

class SavingsGoal {
  final String id;
  final String title;
  final double currentAmount;
  final double targetAmount;
  final IconData icon;
  final Color color;
  final DateTime targetDate;
  final String? imageUrl;
  final bool isCompleted;
  final int streakDays;
  final DateTime? lastCheckInDate;
  final bool isReminderEnabled;
  final String reminderFrequency;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.currentAmount,
    required this.targetAmount,
    required this.icon,
    required this.color,
    required this.targetDate,
    this.imageUrl,
    this.isCompleted = false,
    this.streakDays = 0,
    this.lastCheckInDate,
    this.isReminderEnabled = true,
    this.reminderFrequency = 'ทุกวัน เวลา 20:00 น.',
  });

  double get progress => (targetAmount > 0) ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  double get remainingAmount => (targetAmount - currentAmount).clamp(0, double.infinity);

  int get daysRemaining {
    final diff = targetDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 1;
  }

  double get dailySavingsNeeded {
    if (remainingAmount <= 0) return 0;
    return remainingAmount / daysRemaining;
  }

  double get monthlySavingsNeeded {
    if (remainingAmount <= 0) return 0;
    double months = daysRemaining / 30.0;
    if (months < 1) months = 1;
    return remainingAmount / months;
  }

  bool get isCheckedInToday {
    if (lastCheckInDate == null) return false;
    final now = DateTime.now();
    return lastCheckInDate!.year == now.year &&
        lastCheckInDate!.month == now.month &&
        lastCheckInDate!.day == now.day;
  }

  String get milestoneBadge {
    if (progress >= 1.0) return '🎉 ออมสำเร็จแล้ว!';
    if (progress >= 0.75) return '🔥 อีกนิดเดียว 75% แล้ว!';
    if (progress >= 0.50) return '🚀 ครึ่งทางแล้ว 50%!';
    if (progress >= 0.25) return '💪 เริ่มต้นได้เยี่ยม 25%!';
    return '🌱 เริ่มต้นออมเงิน';
  }

  SavingsGoal copyWith({
    String? id,
    String? title,
    double? currentAmount,
    double? targetAmount,
    IconData? icon,
    Color? color,
    DateTime? targetDate,
    String? imageUrl,
    bool? isCompleted,
    int? streakDays,
    DateTime? lastCheckInDate,
    bool? isReminderEnabled,
    String? reminderFrequency,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      currentAmount: currentAmount ?? this.currentAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      targetDate: targetDate ?? this.targetDate,
      imageUrl: imageUrl ?? this.imageUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      streakDays: streakDays ?? this.streakDays,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      reminderFrequency: reminderFrequency ?? this.reminderFrequency,
    );
  }
}

class SavingsTransaction {
  final String id;
  final String goalTitle;
  final double amount;
  final DateTime date;
  final bool isDeposit; // true = deposit (ฝาก), false = withdraw/adjust (ถอน)
  final String note;

  SavingsTransaction({
    required this.id,
    required this.goalTitle,
    required this.amount,
    required this.date,
    this.isDeposit = true,
    this.note = '',
  });
}
