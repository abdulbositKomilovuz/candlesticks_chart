import 'package:candlesticks/src/models/support_resistance_model.dart';
import 'package:flutter/material.dart';

import '../constant/view_constants.dart';
import 'dash_line.dart';

class ZoneWidget extends StatelessWidget {
  final Zones zone;

  final double chartHeight;
  final double low;
  final double high;
  final double maxWidth;
  const ZoneWidget({
    Key? key,
    required this.zone,
    required this.chartHeight,
    required this.low,
    required this.high,
    required this.maxWidth,
  }) : super(key: key);

  double calculatePriceIndicatorTopPadding(
    double chartHeight,
    double low,
    double high,
    double close,
  ) {
    return chartHeight +
        20 -
        (close - low) / (high - low) * chartHeight -
        MAIN_CHART_VERTICAL_PADDING;
  }

  @override
  Widget build(BuildContext context) {
    final max = calculatePriceIndicatorTopPadding(
      chartHeight,
      low,
      high,
      zone.max,
    );
    final min = calculatePriceIndicatorTopPadding(
      chartHeight,
      low,
      high,
      zone.min,
    );
    return Stack(
      children: [
        Positioned(
          top: max,
          child: ZoneLineWidget(
            maxWidth: maxWidth,
            price: zone.max,
            zoneType: zone.zoneType,
            isMaxPrice: true,
          ),
        ),
        Positioned(
          top: min,
          child: ZoneLineWidget(
            maxWidth: maxWidth,
            price: zone.min,
            zoneType: zone.zoneType,
            isMaxPrice: false,
          ),
        ),
      ],
    );
  }
}

class ZoneLineWidget extends StatelessWidget {
  final double maxWidth;
  final ZoneTypes zoneType;
  final double price;
  final bool isMaxPrice;
  const ZoneLineWidget({
    Key? key,
    required this.maxWidth,
    required this.zoneType,
    required this.price,
    required this.isMaxPrice,
  }) : super(key: key);

  Color get color {
    switch (zoneType) {
      case ZoneTypes.support:
        return Colors.green;
      case ZoneTypes.resistance:
        return Colors.red;
      case ZoneTypes.trendReversal:
        if (isMaxPrice) {
          return Colors.green;
        }
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String get text {
    switch (zoneType) {
      case ZoneTypes.support:
        return 'Support@$price';
      case ZoneTypes.resistance:
        return 'Resistance@$price';
      case ZoneTypes.trendReversal:
        if (isMaxPrice) {
          return 'HH@$price';
        }

        return 'LL@$price';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DashLine(
          length: maxWidth,
          color: color,
          direction: Axis.horizontal,
          thickness: 1,
        ),
        Text(
          text,
          style: TextStyle(
            color: color,
          ),
        ),
      ],
    );
  }
}
