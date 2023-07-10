import 'dart:convert';

import 'package:candlesticks/candlesticks.dart';
import 'package:http/http.dart' as http;

class BinanceRepository {
  Future<List<Candle>> fetchCandles(
      {required String symbol, required String interval, int? endTime}) async {
    final uri = Uri.parse(
      "https://ahsan-screener.uz/api/analytics/binance/?symbol=BTCUSDT&interval=4h",
    );
    final res = await http.get(uri);

    final List<dynamic> data = jsonDecode(res.body);

    return data
        .map<Candle>(
          (dynamic e) => Candle(
            date: DateTime.fromMillisecondsSinceEpoch(e[0]),
            high: double.parse(e[2]),
            low: double.parse(e[3]),
            open: double.parse(e[1]),
            close: double.parse(e[4]),
            volume: double.parse(e[5]),
          ),
        )
        .toList()
        .reversed
        .toList();
  }
}
