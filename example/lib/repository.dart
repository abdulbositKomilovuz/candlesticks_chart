import 'dart:convert';

import 'package:candlesticks/candlesticks.dart';
import 'package:http/http.dart' as http;

class BinanceRepository {
  Future<List<Candle>> fetchCandles(
      {required String symbol, required String interval, int? endTime}) async {
    final uri = Uri.parse(
      "http://64.226.108.199/api/analytics/binance/?symbol=BTCUSDT&interval=4h",
    );
    final res = await http.get(uri);

    final List<dynamic> data = jsonDecode(res.body);

    return data
        .map<Candle>(
          (dynamic e) => Candle(
            date: DateTime.fromMillisecondsSinceEpoch(e[0]),
            high: double.parse(e[2]), // (e[2] is int ? e[2].toDouble() : e[2]),
            low: double.parse(e[3]), //(e[3] is int ? e[3].toDouble() : e[3]),
            open: double.parse(e[1]), //(e[1] is int ? e[1].toDouble() : e[1]),
            close: double.parse(e[4]), //(e[4] is int ? e[4].toDouble() : e[4]),
            volume:
                double.parse(e[5]), //(e[5] is int ? e[5].toDouble() : e[5]),
          ),
        )
        .toList()
        .reversed
        .toList();
  }
}
