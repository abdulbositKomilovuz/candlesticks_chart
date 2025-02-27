import 'dart:math';

import 'package:candlesticks/candlesticks.dart';
import 'package:candlesticks/src/constant/view_constants.dart';
import 'package:candlesticks/src/models/main_window_indicator.dart';
import 'package:candlesticks/src/utils/helper_functions.dart';
import 'package:candlesticks/src/widgets/candle_stick_widget.dart';
import 'package:candlesticks/src/widgets/dash_line.dart';
import 'package:candlesticks/src/widgets/mainwindow_indicator_widget.dart';
import 'package:candlesticks/src/widgets/price_column.dart';
import 'package:candlesticks/src/widgets/time_row.dart';
import 'package:candlesticks/src/widgets/top_panel.dart';
import 'package:candlesticks/src/widgets/volume_widget.dart';
import 'package:candlesticks/src/widgets/zone_widget.dart';
import 'package:flutter/material.dart';

import '../models/zones.dart';

/// This widget manages gestures
/// Calculates the highest and lowest price of visible candles.
/// Updates right-hand side numbers.
/// And pass values down to [CandleStickWidget].
class MobileChart extends StatefulWidget {
  /// onScaleUpdate callback
  /// called when user scales chart using buttons or scale gesture
  final Function onScaleUpdate;

  /// onHorizontalDragUpdate
  /// callback calls when user scrolls horizontally along the chart
  final Function onHorizontalDragUpdate;

  final Function(double) onAddButtonPressed;

  /// candleWidth controls the width of the single candles.
  /// range: [2...10]
  final double candleWidth;

  /// list of all candles to display in chart
  final List<Candle> candles;

  /// index of the newest candle to be displayed
  /// changes when user scrolls along the chart
  final int index;

  final Color color;

  /// holds main window indicators data and high and low prices.
  final MainWindowDataContainer mainWindowDataContainer;

  /// How chart price range will be adjusted when moving chart
  final ChartAdjust chartAdjust;

  final CandleSticksStyle style;

  final void Function(double) onPanDown;
  final void Function() onPanEnd;

  final void Function(String)? onRemoveIndicator;

  final Function() onReachEnd;

  final List<Zones>? zones;

  MobileChart({
    required this.style,
    required this.color,
    required this.onScaleUpdate,
    required this.onHorizontalDragUpdate,
    required this.candleWidth,
    required this.zones,
    required this.candles,
    required this.index,
    required this.chartAdjust,
    required this.onPanDown,
    required this.onPanEnd,
    required this.onReachEnd,
    required this.mainWindowDataContainer,
    required this.onRemoveIndicator,
    required this.onAddButtonPressed,
  });

  @override
  State<MobileChart> createState() => _MobileChartState();
}

class _MobileChartState extends State<MobileChart> {
  double? longPressX;
  double? longPressY;
  bool showIndicatorNames = false;
  double? manualScaleHigh;
  double? manualScaleLow;

  double? fixedCandlesHighPrice;
  double? fixedCandlesLowPrice;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // determine charts width and height
        final double maxWidth = constraints.maxWidth - PRICE_BAR_WIDTH;
        final double maxHeight = constraints.maxHeight - DATE_BAR_HEIGHT;

        // visible candles start and end indexes
        final int candlesStartIndex = max(widget.index, 0);
        final int candlesEndIndex = min(
            maxWidth ~/ widget.candleWidth + widget.index,
            widget.candles.length - 1);

        if (candlesEndIndex == widget.candles.length - 1) {
          Future(() {
            widget.onReachEnd();
          });
        }

        List<Candle> inRangeCandles = widget.candles
            .getRange(candlesStartIndex, candlesEndIndex + 1)
            .toList();

        double candlesHighPrice = 0;
        double candlesLowPrice = 0;

        if (manualScaleHigh != null) {
          candlesHighPrice = manualScaleHigh!;
          candlesLowPrice = manualScaleLow!;
        } else if (widget.chartAdjust == ChartAdjust.visibleRange) {
          candlesHighPrice = widget.mainWindowDataContainer.highs
              .getRange(candlesStartIndex, candlesEndIndex + 1)
              .reduce(max);

          fixedCandlesHighPrice = candlesHighPrice;
          candlesLowPrice = widget.mainWindowDataContainer.lows
              .getRange(candlesStartIndex, candlesEndIndex + 1)
              .reduce(min);
          fixedCandlesLowPrice ??= candlesLowPrice;

          if (widget.zones != null && widget.zones is PriceActionZones) {
            final max = (widget.zones! as PriceActionZones).max;
            final min = (widget.zones! as PriceActionZones).min;

            if (max >= candlesHighPrice) {
              candlesHighPrice = max;
            }
            if (min <= candlesLowPrice) {
              candlesLowPrice = min;
            }
          }
        } else if (widget.chartAdjust == ChartAdjust.fullRange) {
          candlesHighPrice = widget.mainWindowDataContainer.highs.reduce(max);
          candlesLowPrice = widget.mainWindowDataContainer.lows.reduce(min);
        }

        if (candlesHighPrice == candlesLowPrice) {
          candlesHighPrice += 10;
          candlesLowPrice -= 10;
        }

        // calculate priceScale
        double chartHeight = maxHeight * 0.75 - 2 * MAIN_CHART_VERTICAL_PADDING;

        // calculate highest volume
        double volumeHigh = inRangeCandles.map((e) => e.volume).reduce(max);

        if (longPressX != null && longPressY != null) {
          longPressX = max(longPressX!, 0);
          longPressX = min(longPressX!, maxWidth);
          longPressY = max(longPressY!, 0);
          longPressY = min(longPressY!, maxHeight);
        }

        return TweenAnimationBuilder(
          tween: Tween(begin: candlesHighPrice, end: candlesHighPrice),
          duration: Duration(milliseconds: manualScaleHigh == null ? 300 : 0),
          builder: (context, double high, _) {
            return TweenAnimationBuilder(
              tween: Tween(begin: candlesLowPrice, end: candlesLowPrice),
              duration:
                  Duration(milliseconds: manualScaleHigh == null ? 300 : 0),
              builder: (context, double low, _) {
                final currentCandle = longPressX == null
                    ? null
                    : widget.candles[min(
                        max(
                            (maxWidth - longPressX!) ~/ widget.candleWidth +
                                widget.index,
                            0),
                        widget.candles.length - 1)];
                return Container(
                  color: widget.color,
                  child: Stack(
                    children: [
                      TimeRow(
                        style: widget.style,
                        indicatorX: longPressX,
                        candles: widget.candles,
                        candleWidth: widget.candleWidth,
                        indicatorTime: currentCandle?.date,
                        index: widget.index,
                      ),
                      Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Stack(
                              children: [
                                PriceColumn(
                                  style: widget.style,
                                  low: candlesLowPrice,
                                  high: candlesHighPrice,
                                  width: constraints.maxWidth,
                                  chartHeight: chartHeight,
                                  lastCandle: widget.candles[
                                      widget.index < 0 ? 0 : widget.index],
                                  onScale: (delta) {
                                    // ?
                                    // if (longPressX != null &&
                                    //     longPressX != null) {
                                    //   setState(() {
                                    //     longPressX = details.localPosition.dx;
                                    //     longPressY = details.localPosition.dy;
                                    //   });
                                    // }

                                    if (manualScaleHigh == null) {
                                      manualScaleHigh = candlesHighPrice;
                                      manualScaleLow = candlesLowPrice;
                                    }

                                    double deltaPrice = delta /
                                        chartHeight *
                                        (manualScaleHigh! - manualScaleLow!);
                                    // print('price: ${deltaPrice}');
                                    final tempManualScaleHigh =
                                        manualScaleHigh! + deltaPrice;
                                    final tempManualScaleLow =
                                        manualScaleLow! - deltaPrice;

                                    if (tempManualScaleHigh <
                                        fixedCandlesHighPrice!) {
                                      return;
                                    }

                                    setState(() {
                                      manualScaleHigh = tempManualScaleHigh;
                                      manualScaleLow = tempManualScaleLow;
                                    });
                                  },
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border(
                                            right: BorderSide(
                                              color: widget.style.borderColor,
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        child: AnimatedPadding(
                                          duration: Duration(milliseconds: 300),
                                          padding: EdgeInsets.symmetric(
                                              vertical:
                                                  MAIN_CHART_VERTICAL_PADDING),
                                          child: RepaintBoundary(
                                            child: Stack(
                                              children: [
                                                MainWindowIndicatorWidget(
                                                  indicatorDatas: widget
                                                      .mainWindowDataContainer
                                                      .indicatorComponentData,
                                                  index: widget.index,
                                                  candleWidth:
                                                      widget.candleWidth,
                                                  low: low,
                                                  high: high,
                                                ),
                                                // candle
                                                CandleStickWidget(
                                                  candles: widget.candles,
                                                  candleWidth:
                                                      widget.candleWidth,
                                                  index: widget.index,
                                                  high: high,
                                                  low: low,
                                                  bearColor:
                                                      widget.style.primaryBear,
                                                  bullColor:
                                                      widget.style.primaryBull,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: PRICE_BAR_WIDTH,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color: widget.style.borderColor,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: VolumeWidget(
                                        candles: widget.candles,
                                        barWidth: widget.candleWidth,
                                        index: widget.index,
                                        high:
                                            HelperFunctions.getRoof(volumeHigh),
                                        bearColor: widget.style.secondaryBear,
                                        bullColor: widget.style.secondaryBull,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: DATE_BAR_HEIGHT,
                                        child: Center(
                                          child: Row(
                                            children: [
                                              Text(
                                                "-${HelperFunctions.addMetricPrefix(HelperFunctions.getRoof(volumeHigh))}",
                                                style: TextStyle(
                                                  color:
                                                      widget.style.borderColor,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  width: PRICE_BAR_WIDTH,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: DATE_BAR_HEIGHT,
                          ),
                        ],
                      ),
                      for (Zones zone in widget.zones ?? [])
                        zone is PriceActionZones
                            ? PriceActionZoneWidget(
                                zone: zone,
                                high: high,
                                low: low,
                                chartHeight: chartHeight,
                                maxWidth: maxWidth,
                              )
                            : zone is Fibonacci
                                ? FibonacciZoneWidget(
                                    zone: zone,
                                    high: high,
                                    low: low,
                                    chartHeight: chartHeight,
                                    maxWidth: maxWidth,
                                  )
                                : const SizedBox(),
                      longPressY != null
                          ? Positioned(
                              top: longPressY! - 10,
                              child: Row(
                                children: [
                                  DashLine(
                                    length: maxWidth - 20,
                                    color: widget.style.borderColor,
                                    direction: Axis.horizontal,
                                    thickness: 0.5,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      final priceInString = longPressY! <
                                              maxHeight * 0.75
                                          ? HelperFunctions.priceToString(
                                              high -
                                                  (longPressY! -
                                                          MAIN_CHART_VERTICAL_PADDING) /
                                                      (maxHeight * 0.75 -
                                                          2 * MAIN_CHART_VERTICAL_PADDING) *
                                                      (high - low),
                                            )
                                          : HelperFunctions.addMetricPrefix(
                                              HelperFunctions.getRoof(
                                                      volumeHigh) *
                                                  (1 -
                                                      (longPressY! -
                                                              maxHeight * 0.75 -
                                                              10) /
                                                          (maxHeight * 0.25 -
                                                              10)));

                                      final price =
                                          double.tryParse(priceInString);

                                      if (price != null) {
                                        widget.onAddButtonPressed(price);
                                      }
                                    },
                                    child: Container(
                                      color: widget
                                          .style.hoverIndicatorBackgroundColor,
                                      child: Center(
                                        child: Row(
                                          children: [
                                            Container(
                                              height: 20,
                                              width: 20,
                                              color: widget.style
                                                  .hoverIndicatorBackgroundColor,
                                              child: Center(
                                                child: Icon(
                                                  Icons
                                                      .add_circle_outline_rounded,
                                                  size: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              longPressY! < maxHeight * 0.75
                                                  ? HelperFunctions.priceToString(high -
                                                      (longPressY! -
                                                              MAIN_CHART_VERTICAL_PADDING) /
                                                          (maxHeight * 0.75 -
                                                              2 *
                                                                  MAIN_CHART_VERTICAL_PADDING) *
                                                          (high - low))
                                                  : HelperFunctions.addMetricPrefix(
                                                      HelperFunctions.getRoof(
                                                              volumeHigh) *
                                                          (1 -
                                                              (longPressY! -
                                                                      maxHeight *
                                                                          0.75 -
                                                                      10) /
                                                                  (maxHeight *
                                                                          0.25 -
                                                                      10))),
                                              style: TextStyle(
                                                color: widget
                                                    .style.secondaryTextColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      width: PRICE_BAR_WIDTH + 20,
                                      height: 20,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      longPressX != null
                          ? Positioned(
                              child: Container(
                                width: widget.candleWidth,
                                height: maxHeight,
                                color: widget.style.mobileCandleHoverColor,
                              ),
                              right: (maxWidth - longPressX!) ~/
                                      widget.candleWidth *
                                      widget.candleWidth +
                                  PRICE_BAR_WIDTH,
                            )
                          : Container(),
                      Padding(
                        padding: const EdgeInsets.only(right: 100, bottom: 20),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              longPressX = null;
                              longPressY = null;
                            });
                          },
                          onScaleEnd: (_) {
                            widget.onPanEnd();
                          },
                          onScaleUpdate: (details) {
                            if (longPressX != null && longPressY != null) {
                              setState(() {
                                longPressX =
                                    longPressX! + details.focalPointDelta.dx;
                                longPressY =
                                    longPressY! + details.focalPointDelta.dy;
                              });
                              return;
                            }
                            if (details.scale == 1) {
                              widget.onHorizontalDragUpdate(
                                details.focalPoint.dx,
                              );
                              setState(() {
                                manualScaleHigh = null;
                                manualScaleLow = null;
                              });
                            }
                            widget.onScaleUpdate(details.scale);
                          },
                          onScaleStart: (details) {
                            widget.onPanDown(details.localFocalPoint.dx);
                          },
                          onLongPressStart: (LongPressStartDetails details) {
                            setState(() {
                              longPressX = details.localPosition.dx;
                              longPressY = details.localPosition.dy;
                            });
                          },
                          behavior: HitTestBehavior.translucent,
                          onLongPressMoveUpdate:
                              (LongPressMoveUpdateDetails details) {
                            setState(() {
                              longPressX = details.localPosition.dx;
                              longPressY = details.localPosition.dy;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 12),
                        child: TopPanel(
                          style: widget.style,
                          onRemoveIndicator: widget.onRemoveIndicator,
                          currentCandle: currentCandle,
                          indicators: widget.mainWindowDataContainer.indicators,
                          toggleIndicatorVisibility: (indicatorName) {
                            setState(() {
                              widget.mainWindowDataContainer
                                  .toggleIndicatorVisibility(indicatorName);
                            });
                          },
                          unvisibleIndicators: widget
                              .mainWindowDataContainer.unvisibleIndicators,
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        width: PRICE_BAR_WIDTH,
                        height: 20,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor:
                                widget.style.hoverIndicatorBackgroundColor,
                          ),
                          child: Text(
                            "Auto",
                            style: TextStyle(
                              color: widget.style.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              manualScaleHigh = null;
                              manualScaleLow = null;
                            });
                          },
                        ),
                      )
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
