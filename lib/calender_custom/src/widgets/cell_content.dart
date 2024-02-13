import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mukim_app/providers/theme.dart';
import 'package:mukim_app/utils/get_theme_color.dart';
import 'package:provider/provider.dart';
import '../customization/calendar_builders.dart';
import '../customization/calendar_style.dart';

class CellContent extends StatelessWidget {
  final DateTime day;
  final DateTime focusedDay;
  final dynamic locale;
  final bool isTodayHighlighted;
  final bool isToday;
  final bool isSelected;
  final bool isRangeStart;
  final bool isRangeEnd;
  final bool isWithinRange;
  final bool isOutside;
  final bool isDisabled;
  final bool isHoliday;
  final bool isWeekend;
  final CalendarStyle calendarStyle;
  final CalendarBuilders calendarBuilders;

  const CellContent({
    Key? key,
    required this.day,
    required this.focusedDay,
    required this.calendarStyle,
    required this.calendarBuilders,
    required this.isTodayHighlighted,
    required this.isToday,
    required this.isSelected,
    required this.isRangeStart,
    required this.isRangeEnd,
    required this.isWithinRange,
    required this.isOutside,
    required this.isDisabled,
    required this.isHoliday,
    required this.isWeekend,
    this.locale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String theme = Provider.of<ThemeNotifier>(context).appTheme;

    Widget? cell =
        calendarBuilders.prioritizedBuilder?.call(context, day, focusedDay);

    if (cell != null) {
      return cell;
    }
    HijriCalendar hijri = HijriCalendar.fromDate(day);
    final text = '${hijri.hDay}';
    final margin = calendarStyle.cellMargin;
    final duration = const Duration(milliseconds: 250);

    final dowLabel = DateFormat.EEEE(locale).format(day);
    final dayLabel = DateFormat.yMMMMd(locale).format(day);
    final semanticsLabel = '$dowLabel, $dayLabel';

    if (isDisabled) {
      cell = Column(
        children: [
          calendarBuilders.disabledBuilder?.call(context, day, focusedDay) ??
              AnimatedContainer(
                duration: duration,
                margin: margin,
                decoration: calendarStyle.disabledDecoration,
                alignment: Alignment.center,
                child: Text(text, style: calendarStyle.disabledTextStyle),
              ),
          Text(DateFormat("MMM dd").format(day),
              style: TextStyle(color: getColor(theme), fontSize: 10)),
        ],
      );
    } else if (isSelected) {
      cell = Column(
        children: [
          calendarBuilders.selectedBuilder?.call(context, day, focusedDay) ??
              AnimatedContainer(
                padding: EdgeInsets.all(0),
                duration: duration,
                margin: margin,
                decoration: calendarStyle.selectedDecoration,
                alignment: Alignment.center,
                child: Text(text, style: calendarStyle.selectedTextStyle),
              ),
          Text(DateFormat("MMM dd").format(day),
              style: TextStyle(color: getColor(theme), fontSize: 10)),
        ],
      );
    } else if (isRangeStart) {
      cell = Column(
        children: [
          calendarBuilders.rangeStartBuilder?.call(context, day, focusedDay) ??
              AnimatedContainer(
                duration: duration,
                margin: margin,
                decoration: calendarStyle.rangeStartDecoration,
                alignment: Alignment.center,
                child: Text(text, style: calendarStyle.rangeStartTextStyle),
              ),
          Text(DateFormat("MMM dd").format(day),
              style: TextStyle(color: getColor(theme), fontSize: 10)),
        ],
      );
    } else if (isRangeEnd) {
      cell = Column(
        children: [
          calendarBuilders.rangeEndBuilder?.call(context, day, focusedDay) ??
              AnimatedContainer(
                duration: duration,
                margin: margin,
                decoration: calendarStyle.rangeEndDecoration,
                alignment: Alignment.center,
                child: Text(text, style: calendarStyle.rangeEndTextStyle),
              ),
          Text(DateFormat("MMM dd").format(day),
              style: TextStyle(color: getColor(theme), fontSize: 10)),
        ],
      );
    } else if (isToday && isTodayHighlighted) {
      cell = Column(
        children: [
          calendarBuilders.todayBuilder?.call(context, day, focusedDay) ??
              AnimatedContainer(
                duration: duration,
                margin: margin,
                decoration: calendarStyle.todayDecoration,
                alignment: Alignment.center,
                child: Text(text, style: calendarStyle.todayTextStyle),
              ),
          Text(DateFormat("MMM dd").format(day),
              style: TextStyle(color: getColor(theme), fontSize: 10)),
        ],
      );
    } else if (isHoliday) {
      cell = Column(
        children: [
          calendarBuilders.holidayBuilder?.call(context, day, focusedDay) ??
              AnimatedContainer(
                duration: duration,
                margin: margin,
                decoration: calendarStyle.holidayDecoration,
                alignment: Alignment.center,
                child: Text(text, style: calendarStyle.holidayTextStyle),
              ),
          Text(DateFormat("MMM dd").format(day),
              style: TextStyle(color: getColor(theme), fontSize: 10)),
        ],
      );
    } else if (isWithinRange) {
      cell = Column(
        children: [
          calendarBuilders.withinRangeBuilder?.call(context, day, focusedDay) ??
              AnimatedContainer(
                duration: duration,
                margin: margin,
                decoration: calendarStyle.withinRangeDecoration,
                alignment: Alignment.center,
                child: Text(text, style: calendarStyle.withinRangeTextStyle),
              ),
          Text(DateFormat("MMM dd").format(day),
              style: TextStyle(color: getColor(theme), fontSize: 10)),
        ],
      );
    } else if (isOutside) {
      cell = Column(
        children: [
          calendarBuilders.outsideBuilder?.call(context, day, focusedDay) ??
              AnimatedContainer(
                duration: duration,
                margin: margin,
                decoration: calendarStyle.outsideDecoration,
                alignment: Alignment.center,
                child: Text(text, style: calendarStyle.outsideTextStyle),
              ),
          Text(DateFormat("MMM dd").format(day),
              style: TextStyle(color: getColor(theme), fontSize: 10)),
        ],
      );
    } else {
      cell = Column(
        children: [
          calendarBuilders.defaultBuilder?.call(context, day, focusedDay) ??
              AnimatedContainer(
                duration: duration,
                margin: margin,
                decoration: isWeekend
                    ? calendarStyle.weekendDecoration
                    : calendarStyle.defaultDecoration,
                alignment: Alignment.center,
                child: Text(
                  text,
                  style: isWeekend
                      ? calendarStyle.weekendTextStyle
                      : calendarStyle.defaultTextStyle,
                ),
              ),
          Text(DateFormat("MMM dd").format(day),
              style: TextStyle(color: getColor(theme), fontSize: 10)),
        ],
      );
    }

    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: cell,
    );
  }
}
