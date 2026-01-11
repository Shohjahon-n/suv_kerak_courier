import 'package:flutter/material.dart';

enum BottleBalanceKind {
  emptyBottles,
  fullWater,
}

int? _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

class BottleBalanceRequest {
  const BottleBalanceRequest({
    required this.kind,
    required this.range,
  });

  final BottleBalanceKind kind;
  final DateTimeRange range;
}

class BottleBalancePeriodReport {
  const BottleBalancePeriodReport({
    required this.ok,
    required this.courierId,
    required this.startDate,
    required this.endDate,
    required this.openingBalance,
    required this.closingBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.rows,
  });

  final bool ok;
  final int courierId;
  final String startDate;
  final String endDate;
  final int openingBalance;
  final int closingBalance;
  final int totalIncome;
  final int totalExpense;
  final List<BottleBalanceRow> rows;

  factory BottleBalancePeriodReport.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((row) => BottleBalanceRow.fromJson(Map<String, dynamic>.from(row)))
        .toList();
    return BottleBalancePeriodReport(
      ok: json['ok'] == true,
      courierId: _toInt(json['kuryer_id']) ?? 0,
      startDate: json['bosh_sana']?.toString() ?? '',
      endDate: json['tugash_sana']?.toString() ?? '',
      openingBalance: _toInt(json['bosh_sana_tara_qoldiq']) ?? 0,
      closingBalance: _toInt(json['tugash_sana_tara_qoldiq']) ?? 0,
      totalIncome: _toInt(json['jami_kirim']) ?? 0,
      totalExpense: _toInt(json['jami_chiqim']) ?? 0,
      rows: rows,
    );
  }
}

class BottleBalanceRow {
  const BottleBalanceRow({
    required this.date,
    required this.time,
    required this.operation,
    required this.income,
    required this.expense,
    required this.balance,
  });

  final String date;
  final String time;
  final String operation;
  final int income;
  final int expense;
  final int balance;

  factory BottleBalanceRow.fromJson(Map<String, dynamic> json) {
    return BottleBalanceRow(
      date: json['oper_sana']?.toString() ?? '',
      time: json['oper_vaqti']?.toString() ?? '',
      operation: json['operation']?.toString() ?? '',
      income: _toInt(json['tara_kirimi']) ?? 0,
      expense: _toInt(json['tara_chiqimi']) ?? 0,
      balance: _toInt(json['tara_qoldiqi']) ?? 0,
    );
  }
}

class FullWaterPeriodReport {
  const FullWaterPeriodReport({
    required this.ok,
    required this.courierId,
    required this.startDate,
    required this.endDate,
    required this.openingBalance,
    required this.closingBalance,
    required this.totalIncome,
    required this.totalExpense,
    required this.rows,
  });

  final bool ok;
  final int courierId;
  final String startDate;
  final String endDate;
  final int openingBalance;
  final int closingBalance;
  final int totalIncome;
  final int totalExpense;
  final List<FullWaterRow> rows;

  factory FullWaterPeriodReport.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((row) => FullWaterRow.fromJson(Map<String, dynamic>.from(row)))
        .toList();
    return FullWaterPeriodReport(
      ok: json['ok'] == true,
      courierId: _toInt(json['kuryer_id']) ?? 0,
      startDate: json['bosh_sana']?.toString() ?? '',
      endDate: json['tugash_sana']?.toString() ?? '',
      openingBalance: _toInt(json['bosh_sana_water_balance']) ?? 0,
      closingBalance: _toInt(json['tug_sana_water_balance']) ?? 0,
      totalIncome: _toInt(json['jami_kirim']) ?? 0,
      totalExpense: _toInt(json['jami_chiqim']) ?? 0,
      rows: rows,
    );
  }
}

class FullWaterRow {
  const FullWaterRow({
    required this.date,
    required this.time,
    required this.operation,
    required this.income,
    required this.expense,
    required this.balance,
  });

  final String date;
  final String time;
  final String operation;
  final int income;
  final int expense;
  final int balance;

  factory FullWaterRow.fromJson(Map<String, dynamic> json) {
    return FullWaterRow(
      date: json['oper_sana']?.toString() ?? '',
      time: json['oper_vaqt']?.toString() ?? '',
      operation: json['operation']?.toString() ?? '',
      income: _toInt(json['kirim']) ?? 0,
      expense: _toInt(json['chiqim']) ?? 0,
      balance: _toInt(json['balance']) ?? 0,
    );
  }
}
