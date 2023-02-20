import 'dart:convert';

import 'package:candlesticks/candlesticks.dart';
import 'package:http/http.dart' as http;

class BinanceRepository {
  Future<List<Candle>> fetchCandles(
      {required String symbol, required String interval, int? endTime}) async {
    final uri = Uri.parse(
        "http://161.35.152.177:90/v1/api/ticker-history?symbol=${symbol.toUpperCase()}&interval=$interval");
    final res = await http.get(uri);

    final List<dynamic> data = jsonDecode(res.body)['data'] as List<dynamic>;

    return data
        .map(
          (e) => Candle(
            date: DateTime.fromMillisecondsSinceEpoch(e['date']),
            high: (e['high'] is int ? e['high'].toDouble() : e['high']),
            low: (e['low'] is int ? e['low'].toDouble() : e['low']),
            open: (e['open'] is int ? e['open'].toDouble() : e['open']),
            close: (e['close'] is int ? e['close'].toDouble() : e['close']),
            volume: (e['volume'] is int ? e['volume'].toDouble() : e['volume']),
          ),
        )
        .toList()
        .reversed
        .toList();
  }
}
