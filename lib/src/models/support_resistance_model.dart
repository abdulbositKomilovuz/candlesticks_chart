import 'package:candlesticks/src/models/zones.dart';

enum ZoneTypes { support, resistance, trendReversal, fibonacci }

abstract class PriceActionZones extends Zones {
  final double max;
  final double min;
  final ZoneTypes zoneType;

  PriceActionZones({
    required this.max,
    required this.min,
    required this.zoneType,
  });
}

class SupportZone extends PriceActionZones {
  SupportZone({
    required double max,
    required double min,
    ZoneTypes zoneType = ZoneTypes.support,
  }) : super(
          max: max,
          min: min,
          zoneType: zoneType,
        );
}

class ResistanceZone extends PriceActionZones {
  ResistanceZone({
    required double max,
    required double min,
    ZoneTypes zoneType = ZoneTypes.resistance,
  }) : super(
          max: max,
          min: min,
          zoneType: zoneType,
        );
}

class TrendReversalZone extends PriceActionZones {
  TrendReversalZone({
    required double max,
    required double min,
    ZoneTypes zoneType = ZoneTypes.trendReversal,
  }) : super(
          max: max,
          min: min,
          zoneType: zoneType,
        );
}
