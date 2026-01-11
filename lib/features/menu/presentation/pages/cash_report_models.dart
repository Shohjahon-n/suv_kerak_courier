import 'package:flutter/material.dart';

enum CashReportKind { periodic, onlinePayments }

class CashReportRequest {
  const CashReportRequest({
    required this.kind,
    required this.range,
  });

  final CashReportKind kind;
  final DateTimeRange range;
}

class CashPeriodReport {
  const CashPeriodReport({
    required this.ok,
    required this.businessId,
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
  final int businessId;
  final int courierId;
  final String startDate;
  final String endDate;
  final String openingBalance;
  final String closingBalance;
  final String totalIncome;
  final String totalExpense;
  final List<CashPeriodRow> rows;

  factory CashPeriodReport.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((row) => CashPeriodRow.fromJson(Map<String, dynamic>.from(row)))
        .toList();
    return CashPeriodReport(
      ok: json['ok'] == true,
      businessId: _toInt(json['business_id']) ?? 0,
      courierId: _toInt(json['kuryer_id']) ?? 0,
      startDate: json['bosh_sana']?.toString() ?? '',
      endDate: json['tugash_sana']?.toString() ?? '',
      openingBalance: _toRawString(json['saldo_bosh']),
      closingBalance: _toRawString(json['saldo_tugash']),
      totalIncome: _toRawString(json['jami_kirim']),
      totalExpense: _toRawString(json['jami_chiqim']),
      rows: rows,
    );
  }

  static int? _toInt(dynamic value) {
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

  static String _toRawString(dynamic value) {
    if (value == null) {
      return '0';
    }
    if (value is String) {
      return value;
    }
    if (value is int) {
      return value.toString();
    }
    if (value is double) {
      final text = value.toString();
      if (text.endsWith('.0')) {
        return text.substring(0, text.length - 2);
      }
      return text;
    }
    if (value is num) {
      return value.toString();
    }
    return value.toString();
  }
}

class CashPeriodRow {
  const CashPeriodRow({
    required this.date,
    required this.time,
    required this.operation,
    required this.courierName,
    required this.income,
    required this.expense,
    required this.balance,
  });

  final String date;
  final String time;
  final String operation;
  final String courierName;
  final String income;
  final String expense;
  final String balance;

  factory CashPeriodRow.fromJson(Map<String, dynamic> json) {
    return CashPeriodRow(
      date: json['sana']?.toString() ?? '',
      time: json['vaqt']?.toString() ?? '',
      operation: json['kassa_oper']?.toString() ?? '',
      courierName: json['kuryer_name']?.toString() ?? '',
      income: CashPeriodReport._toRawString(json['kirim']),
      expense: CashPeriodReport._toRawString(json['chiqim']),
      balance: CashPeriodReport._toRawString(json['balance']),
    );
  }
}

class OnlinePaymentReport {
  const OnlinePaymentReport({
    required this.ok,
    required this.businessId,
    required this.startDate,
    required this.endDate,
    required this.totalAmount,
    required this.rows,
  });

  final bool ok;
  final int businessId;
  final String startDate;
  final String endDate;
  final String totalAmount;
  final List<OnlinePaymentRow> rows;

  factory OnlinePaymentReport.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((row) => OnlinePaymentRow.fromJson(Map<String, dynamic>.from(row)))
        .toList();
    return OnlinePaymentReport(
      ok: json['ok'] == true,
      businessId: CashPeriodReport._toInt(json['business_id']) ?? 0,
      startDate: json['bosh_sana']?.toString() ?? '',
      endDate: json['tugash_sana']?.toString() ?? '',
      totalAmount: CashPeriodReport._toRawString(json['jami_summa']),
      rows: rows,
    );
  }
}

class OnlinePaymentRow {
  const OnlinePaymentRow({
    required this.date,
    required this.time,
    required this.orderNumber,
    required this.buyer,
    required this.paymentSystem,
    required this.amount,
  });

  final String date;
  final String time;
  final String orderNumber;
  final String buyer;
  final String paymentSystem;
  final String amount;

  factory OnlinePaymentRow.fromJson(Map<String, dynamic> json) {
    return OnlinePaymentRow(
      date: json['oper_sana']?.toString() ?? '',
      time: json['oper_vaqt']?.toString() ?? '',
      orderNumber: json['buyurtma_num']?.toString() ?? '',
      buyer: json['buyurtmachi']?.toString() ?? '',
      paymentSystem: json['tulov_tizimi']?.toString() ?? '',
      amount: CashPeriodReport._toRawString(json['summa']),
    );
  }
}
