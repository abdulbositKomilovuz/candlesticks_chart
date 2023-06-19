import 'package:flutter/material.dart';

import '../../candlesticks.dart';
import '../constant/view_constants.dart';
import 'dash_line.dart';

class PriceActionZoneWidget extends StatelessWidget {
  final PriceActionZones zone;

  final double chartHeight;
  final double low;
  final double high;
  final double maxWidth;
  const PriceActionZoneWidget({
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

class FibonacciZoneWidget extends StatelessWidget {
  final Fibonacci zone;

  final double chartHeight;
  final double low;
  final double high;
  final double maxWidth;
  const FibonacciZoneWidget({
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
    final f0 = calculatePriceIndicatorTopPadding(
      chartHeight,
      low,
      high,
      zone.f0,
    );
    final f786 = calculatePriceIndicatorTopPadding(
      chartHeight,
      low,
      high,
      zone.f786,
    );
    final f618 = calculatePriceIndicatorTopPadding(
      chartHeight,
      low,
      high,
      zone.f618,
    );
    final f5 = calculatePriceIndicatorTopPadding(
      chartHeight,
      low,
      high,
      zone.f5,
    );
    final f382 = calculatePriceIndicatorTopPadding(
      chartHeight,
      low,
      high,
      zone.f382,
    );
    final f236 = calculatePriceIndicatorTopPadding(
      chartHeight,
      low,
      high,
      zone.f236,
    );
    final f1 = calculatePriceIndicatorTopPadding(
      chartHeight,
      low,
      high,
      zone.f1,
    );

    return Stack(
      children: [
        Positioned(
          top: f0,
          child: ZoneLineWidget(
            maxWidth: maxWidth,
            price: zone.f0,
            zoneType: ZoneTypes.fibonacci,
            isMaxPrice: true,
            level: FibonacciLevels.f0,
          ),
        ),
        Positioned(
          top: f786,
          child: ZoneLineWidget(
            maxWidth: maxWidth,
            price: zone.f786,
            zoneType: ZoneTypes.fibonacci,
            isMaxPrice: true,
            level: FibonacciLevels.f786,
          ),
        ),
        Positioned(
          top: f618,
          child: ZoneLineWidget(
            maxWidth: maxWidth,
            price: zone.f618,
            zoneType: ZoneTypes.fibonacci,
            isMaxPrice: true,
            level: FibonacciLevels.f618,
          ),
        ),
        Positioned(
          top: f5,
          child: ZoneLineWidget(
            maxWidth: maxWidth,
            price: zone.f5,
            zoneType: ZoneTypes.fibonacci,
            isMaxPrice: true,
            level: FibonacciLevels.f5,
          ),
        ),
        Positioned(
          top: f382,
          child: ZoneLineWidget(
            maxWidth: maxWidth,
            price: zone.f382,
            zoneType: ZoneTypes.fibonacci,
            isMaxPrice: true,
            level: FibonacciLevels.f382,
          ),
        ),
        Positioned(
          top: f236,
          child: ZoneLineWidget(
            maxWidth: maxWidth,
            price: zone.f236,
            zoneType: ZoneTypes.fibonacci,
            isMaxPrice: true,
            level: FibonacciLevels.f236,
          ),
        ),
        Positioned(
          top: f1,
          child: ZoneLineWidget(
            maxWidth: maxWidth,
            price: zone.f1,
            zoneType: ZoneTypes.fibonacci,
            isMaxPrice: true,
            level: FibonacciLevels.f1,
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
  final FibonacciLevels? level;
  const ZoneLineWidget({
    Key? key,
    required this.maxWidth,
    required this.zoneType,
    required this.price,
    required this.isMaxPrice,
    this.level,
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

      case ZoneTypes.fibonacci:
        switch (level!) {
          case FibonacciLevels.f0:
            return '0@$price';
          case FibonacciLevels.f236:
            return '0.236@$price';
          case FibonacciLevels.f382:
            return '0.382@$price';
          case FibonacciLevels.f5:
            return '0.5@$price';
          case FibonacciLevels.f618:
            return '0.618@$price';
          case FibonacciLevels.f786:
            return '0.786@$price';
          case FibonacciLevels.f1:
            return '1@$price';
          default:
            return '';
        }
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
