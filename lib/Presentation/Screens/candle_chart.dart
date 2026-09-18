import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

import 'package:persian_number_utility/persian_number_utility.dart';

import '../../logic/Helpers/number.dart';
import 'colors.dart';

class CandleChart extends StatefulWidget {
  CandleChart({super.key, required this.weekData});

  final List weekData;

  List<Color> get availableColors => const <Color>[
        AppColors.contentColorPurple,
        AppColors.contentColorYellow,
        AppColors.contentColorBlue,
        AppColors.contentColorOrange,
        AppColors.contentColorPink,
        AppColors.contentColorRed,
      ];

  final Color barBackgroundColor = AppColors.contentColorWhite.withValues(alpha: 0.3);
  final Color barColor = AppColors.contentColorWhite;
  final Color touchedBarColor = AppColors.contentColorGreen;

  @override
  State<StatefulWidget> createState() => CandleChartState();
}

class CandleChartState extends State<CandleChart> {
  final Duration animDuration = const Duration(milliseconds: 250);
  Map weekDay = {
    0: 'شنبه',
    1: 'یکشنبه',
    2: 'دوشنبه',
    3: 'سه شنبه',
    4: 'چهارشنبه',
    5: 'پنجشنبه',
    6: 'جمعه',
  };

  int touchedIndex = -1;

  bool isPlaying = false;

  double candleData(Map data) {
    return (((data['Transactions']['Entry'] - data['Transactions']['Output']) /
                (widget.weekData.last / 25)) +
            25)
        .toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: [
                    Icon(
                      Iconsax.math_bold,
                      size: 28,
                      color: Colors.white,
                    ),
                    const Text(
                      ' چند چندیم !؟ ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'هفت روزی که گذشت ...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BarChart(
                      isPlaying ? randomData() : mainBarData(),
                      duration: animDuration,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8),
          //   child: Align(
          //     alignment: Alignment.topLeft,
          //     child: IconButton(
          //       icon: Icon(
          //         isPlaying ? Iconsax.pause_outline : Iconsax.play_outline,
          //         color: Colors.white,
          //       ),
          //       onPressed: () {
          //         setState(() {
          //           isPlaying = !isPlaying;
          //           if (isPlaying) {
          //             refreshState();
          //           }
          //         });
          //       },
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 18,
    List<int> showTooltips = const [],
  }) {
    barColor ??= widget.barColor;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          fromY: 25,
          color: isTouched ? widget.touchedBarColor : barColor,
          width: width,
          borderSide: isTouched
              ? BorderSide(color: widget.touchedBarColor)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: (widget.weekData.last / (widget.weekData.last / 25)) + 25,
            color: widget.barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        List data = widget.weekData.first;
        switch (i) {
          case 0:
            return makeGroupData(
              0,
              candleData(data[i]),
              isTouched: i == touchedIndex,
              barColor: candleData(data[i]) < 25 ? Colors.yellow : null,
            );
          case 1:
            return makeGroupData(
              1,
              candleData(data[i]),
              isTouched: i == touchedIndex,
              barColor: candleData(data[i]) < 25 ? Colors.yellow : null,
            );
          case 2:
            return makeGroupData(
              2,
              candleData(data[i]),
              isTouched: i == touchedIndex,
              barColor: candleData(data[i]) < 25 ? Colors.yellow : null,
            );
          case 3:
            return makeGroupData(
              3,
              candleData(data[i]),
              isTouched: i == touchedIndex,
              barColor: candleData(data[i]) < 25 ? Colors.yellow : null,
            );
          case 4:
            return makeGroupData(
              4,
              candleData(data[i]),
              isTouched: i == touchedIndex,
              barColor: candleData(data[i]) < 25 ? Colors.yellow : null,
            );
          case 5:
            return makeGroupData(
              5,
              candleData(data[i]),
              isTouched: i == touchedIndex,
              barColor: candleData(data[i]) < 25 ? Colors.yellow : null,
            );
          case 6:
            return makeGroupData(
              6,
              candleData(data[i]),
              isTouched: i == touchedIndex,
              barColor: candleData(data[i]) < 25 ? Colors.yellow : null,
            );
          default:
            return throw Error();
        }
      });

  BarChartData mainBarData() {
    List data = widget.weekData.first;

    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Colors.red.shade800,
          tooltipHorizontalAlignment: FLHorizontalAlignment.center,
          tooltipBorderRadius: BorderRadius.circular(15),
          tooltipMargin: 15,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String weekDay;
            switch (group.x) {
              case 0:
                weekDay = 'جمعه';
                break;
              case 1:
                weekDay = 'پنجشنبه';
                break;
              case 2:
                weekDay = 'چهارشنبه';
                break;
              case 3:
                weekDay = 'سه‌شنبه';
                break;
              case 4:
                weekDay = 'دوشنبه';
                break;
              case 5:
                weekDay = 'یکشنبه';
                break;
              case 6:
                weekDay = 'شنبه';
                break;
              default:
                throw Error();
            }

            return
                // null;
                BarTooltipItem(
              '$weekDay\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              children: <TextSpan>[
                TextSpan(
                  text:
                      ('دخل : ${splitNumber((data[group.x]['Transactions']['Entry']).toInt())}\n')
                          .toPersianDigit(),
                  style: const TextStyle(
                    color: Colors.white, //widget.touchedBarColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text:
                      ('خرج : ${splitNumber((data[group.x]['Transactions']['Output']).toInt())}\n')
                          .toPersianDigit(),
                  style: const TextStyle(
                    color: Colors.white, //widget.touchedBarColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: ('برآیند : ').toPersianDigit(),
                  style: const TextStyle(
                    color: Colors.white, //widget.touchedBarColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: (splitNumber((data[group.x]['Transactions']['Entry'] -
                                      data[group.x]['Transactions']['Output'])
                                  .toInt() >
                              0
                          ? (data[group.x]['Transactions']['Entry'] -
                                  data[group.x]['Transactions']['Output'])
                              .toInt()
                          : (data[group.x]['Transactions']['Entry'] -
                                      data[group.x]['Transactions']['Output'])
                                  .toInt() *
                              -1))
                      .toPersianDigit(),
                  style: TextStyle(
                    color: data[group.x]['Transactions']['Entry'] -
                                data[group.x]['Transactions']['Output'] <
                            0
                        ? Colors.yellow
                        : Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 25,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 8,
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = Text(weekDay[6], style: style);
        break;
      case 1:
        text = Text(weekDay[5], style: style);
        break;
      case 2:
        text = Text(weekDay[4], style: style);
        break;
      case 3:
        text = Text(weekDay[3], style: style);
        break;
      case 4:
        text = Text(weekDay[2], style: style);
        break;
      case 5:
        text = Text(weekDay[1], style: style);
        break;
      case 6:
        text = Text(weekDay[0], style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: text,
    );
  }

  BarChartData randomData() {
    return BarChartData(
      barTouchData: BarTouchData(
        enabled: false,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 25,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(
              0,
              Random().nextInt(50).toDouble(),
              barColor: widget.availableColors[
                  Random().nextInt(widget.availableColors.length)],
            );
          case 1:
            return makeGroupData(
              1,
              Random().nextInt(50).toDouble(),
              barColor: widget.availableColors[
                  Random().nextInt(widget.availableColors.length)],
            );
          case 2:
            return makeGroupData(
              2,
              Random().nextInt(50).toDouble(),
              barColor: widget.availableColors[
                  Random().nextInt(widget.availableColors.length)],
            );
          case 3:
            return makeGroupData(
              3,
              Random().nextInt(50).toDouble(),
              barColor: widget.availableColors[
                  Random().nextInt(widget.availableColors.length)],
            );
          case 4:
            return makeGroupData(
              4,
              Random().nextInt(50).toDouble(),
              barColor: widget.availableColors[
                  Random().nextInt(widget.availableColors.length)],
            );
          case 5:
            return makeGroupData(
              5,
              Random().nextInt(50).toDouble(),
              barColor: widget.availableColors[
                  Random().nextInt(widget.availableColors.length)],
            );
          case 6:
            return makeGroupData(
              6,
              Random().nextInt(50).toDouble(),
              barColor: widget.availableColors[
                  Random().nextInt(widget.availableColors.length)],
            );
          default:
            return throw Error();
        }
      }),
      gridData: const FlGridData(show: false),
    );
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
      animDuration + const Duration(milliseconds: 50),
    );
    if (isPlaying) {
      await refreshState();
    }
  }
}
