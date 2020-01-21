import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class CalendarEvent extends Equatable {
  const CalendarEvent();

  @override
  List<Object> get props => [];
}

class FCalendarAllPillEvent extends CalendarEvent {
  final String uid;

  FCalendarAllPillEvent({@required this.uid});

  @override
  List<Object> get props => [uid];
}

class FCalendarDayPillHistoryEvent extends CalendarEvent {
  final String uid;
  final String date;

  FCalendarDayPillHistoryEvent({
    @required this.uid,
    @required this.date,
  });

  @override
  List<Object> get props => [
        uid,
        date,
      ];
}

class FCalendarMonthPillHistoryEvent extends CalendarEvent {
  final String uid;
  final int year;
  final int month;
  final String creationDate;

  FCalendarMonthPillHistoryEvent({
    @required this.uid,
    @required this.year,
    @required this.month,
    @required this.creationDate,
  });

  @override
  List<Object> get props => [
        uid,
        year,
        month,
        creationDate,
      ];
}
