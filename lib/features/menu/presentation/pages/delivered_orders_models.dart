import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class DeliveredOrdersRequest extends Equatable {
  const DeliveredOrdersRequest({required this.range});

  final DateTimeRange range;

  @override
  List<Object> get props => [range];
}
