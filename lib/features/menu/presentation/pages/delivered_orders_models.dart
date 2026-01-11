import 'package:flutter/material.dart';

class DeliveredOrdersRequest {
  const DeliveredOrdersRequest({
    required this.range,
  });

  final DateTimeRange range;
}
