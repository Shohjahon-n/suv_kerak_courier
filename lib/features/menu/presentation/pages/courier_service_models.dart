import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CourierServiceRequest extends Equatable {
  const CourierServiceRequest({
    required this.range,
  });

  final DateTimeRange range;

  @override
  List<Object> get props => [range];
}

class CourierServiceReport extends Equatable {
  const CourierServiceReport({
    required this.ok,
    required this.businessId,
    required this.courierId,
    required this.courierName,
    required this.startCashBalance,
    required this.startMessage,
    required this.startMessageColor,
    required this.endCashBalance,
    required this.endMessage,
    required this.endMessageColor,
    required this.totalIncome,
    required this.totalExpense,
    required this.rows,
  });

  final bool ok;
  final int businessId;
  final int courierId;
  final String courierName;
  final String startCashBalance;
  final String startMessage;
  final String startMessageColor;
  final String endCashBalance;
  final String endMessage;
  final String endMessageColor;
  final String totalIncome;
  final String totalExpense;
  final List<CourierServiceRow> rows;

  @override
  List<Object> get props => [
        ok,
        businessId,
        courierId,
        courierName,
        startCashBalance,
        startMessage,
        startMessageColor,
        endCashBalance,
        endMessage,
        endMessageColor,
        totalIncome,
        totalExpense,
        rows,
      ];

  factory CourierServiceReport.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((row) => CourierServiceRow.fromJson(Map<String, dynamic>.from(row)))
        .toList();
    return CourierServiceReport(
      ok: json['ok'] == true,
      businessId: _toInt(json['business_id']) ?? 0,
      courierId: _toInt(json['kuryer_id']) ?? 0,
      courierName: json['kuryer_name']?.toString() ?? '',
      startCashBalance: _toRawString(json['bosh_cash_balance']),
      startMessage: json['bosh_message']?.toString() ?? '',
      startMessageColor: json['bosh_message_color']?.toString() ?? '',
      endCashBalance: _toRawString(json['tugash_cash_balance']),
      endMessage: json['tugash_message']?.toString() ?? '',
      endMessageColor: json['tugash_message_color']?.toString() ?? '',
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

class CourierServiceRow extends Equatable {
  const CourierServiceRow({
    required this.date,
    required this.time,
    required this.operation,
    required this.orderNumber,
    required this.charged,
    required this.paid,
    required this.cashBalance,
    required this.serviceCount,
  });

  final String date;
  final String time;
  final String operation;
  final String orderNumber;
  final String charged;
  final String paid;
  final String cashBalance;
  final int serviceCount;

  @override
  List<Object> get props => [
        date,
        time,
        operation,
        orderNumber,
        charged,
        paid,
        cashBalance,
        serviceCount,
      ];

  factory CourierServiceRow.fromJson(Map<String, dynamic> json) {
    return CourierServiceRow(
      date: json['oper_sana']?.toString() ?? '',
      time: json['oper_vaqt']?.toString() ?? '',
      operation: json['operation']?.toString() ?? '',
      orderNumber: json['buyurtma_num']?.toString() ?? '',
      charged: CourierServiceReport._toRawString(json['hisoblandi']),
      paid: CourierServiceReport._toRawString(json['tolandi']),
      cashBalance: CourierServiceReport._toRawString(json['cash_balance']),
      serviceCount: CourierServiceReport._toInt(json['xizmat_soni']) ?? 0,
    );
  }
}
