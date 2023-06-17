enum ZoneTypes { support, resistance, trendReversal }

abstract class Zones {
  final double max;
  final double min;
  final ZoneTypes zoneType;

  Zones({
    required this.max,
    required this.min,
    required this.zoneType,
  });
}

class SupportZone extends Zones {
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

class ResistanceZone extends Zones {
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

class TrendReversalZone extends Zones {
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
