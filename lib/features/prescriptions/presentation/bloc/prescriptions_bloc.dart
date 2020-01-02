import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meta/meta.dart';
import 'package:reminder/features/reminder_schedule/domain/usecases/f_reminder_schedule_unset_usecase.dart';

import './bloc.dart';
import '../../../../core/usecases/c_app_add_pill_usecase.dart';
import '../../../../core/usecases/c_app_all_pill_usecase.dart';
import '../../../../core/usecases/c_app_delete_pill_usecase.dart';
import '../../../../core/usecases/c_app_get_pill_usecase.dart';
import '../../../reminder_schedule/domain/usecases/f_reminder_schedule_get_id_usecase.dart';
import '../../../reminder_schedule/domain/usecases/f_reminder_schedule_set_usecase.dart';
import '../../domain/entities/f_pill_entity.dart';

class PrescriptionsBloc extends Bloc<PrescriptionsEvent, PrescriptionsState> {
  final CAppAddPillUsecase cAppAddPillUsecase;
  final CAppAllPillUsecase cAppAllPillUsecase;
  final CAppGetPillUsecase cAppGetPillUsecase;
  final CAppDeletePillUsecase cAppDeletePillUsecase;
  final FReminderScheduleSetUsecase fReminderScheduleSetUsecase;
  final FReminderScheduleGetIdUsecase fReminderScheduleGetIdUsecase;
  final FReminderScheduleUnsetUsecase fReminderScheduleUnsetUsecase;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  PrescriptionsBloc({
    @required this.cAppAddPillUsecase,
    @required this.cAppAllPillUsecase,
    @required this.cAppGetPillUsecase,
    @required this.cAppDeletePillUsecase,
    @required this.fReminderScheduleSetUsecase,
    @required this.fReminderScheduleGetIdUsecase,
    @required this.flutterLocalNotificationsPlugin,
    @required this.fReminderScheduleUnsetUsecase,
  });

  @override
  PrescriptionsState get initialState => InitialPrescriptionsState();

  void _reminderUnsetSchedule(String pillName) async {
    final usecaseGetId = await fReminderScheduleGetIdUsecase(
        FReminderScheduleGetIdParam(name: pillName));
    int notificationId;
    usecaseGetId.fold(
      (failure) {
        print(failure.message);
      },
      (success) {
        notificationId = success;
      },
    );

    await fReminderScheduleUnsetUsecase(FReminderScheduleUnsetParam(
      notificationName: pillName,
      notificationId: notificationId,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
    ));
  }

  void _reminderSetSchedule(FPPillEntity fpPillEntity) async {
    print("setting notification");
    final notificationName = fpPillEntity.pillName;
    final usecaseGetId = await fReminderScheduleGetIdUsecase(
        FReminderScheduleGetIdParam(name: fpPillEntity.pillName));
    int notificationId;
    usecaseGetId.fold(
      (failure) {
        print(failure.message);
      },
      (success) {
        notificationId = success;
      },
    );

    final time =
        Time(fpPillEntity.remindWhen.hour, fpPillEntity.remindWhen.minute);

    await fReminderScheduleSetUsecase(FReminderScheduleSetUsecaseParam(
      time: time,
      notificationId: notificationId,
      notificationName: notificationName,
      flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
    ));
    print("notification set");
  }

  @override
  Stream<PrescriptionsState> mapEventToState(
    PrescriptionsEvent event,
  ) async* {
    if (event is FPrescListPillEvent) {
      print("ListPillsEvent");
      final listPills = await cAppAllPillUsecase(
        CAppGetAllPillParam(uid: event.uid),
      );
      yield* listPills.fold(
        (failure) async* {
          print("Failure gettings list pills : " + failure.message.toString());
          yield InitialPrescriptionsState();
        },
        (allPills) async* {
          yield FPrescLoadingState();
          yield FprescListPillState(allPill: allPills);

          // Set the alarm
          allPills.forEach(_reminderSetSchedule);
        },
      );
    }

    if (event is FPrescShowPillEvent) {
      final showPill = await cAppGetPillUsecase(CAppGetPillParam(
        pillName: event.pillName,
        uid: event.uid,
      ));

      yield* showPill.fold(
        (failure) async* {
          print("Error:${failure.message}");
          yield InitialPrescriptionsState();
        },
        (success) async* {
          yield FPrescShowPillState(pillEntity: success);
        },
      );
    }

    if (event is FPrescDisplayAddPillEvent) {
      yield FPrescDisplayAddPillState();
    }

    if (event is FPrescChangePillEvent) {
      //TODO Add change pill event login
    }

    if (event is FPrescValidatePillEvent) {
      _reminderUnsetSchedule(event.pillName);
    }

    if (event is FPrescDeletePillEvent) {
      print("DeletePillEvent");
      final usecase = await cAppDeletePillUsecase(
        CAppDeletePillParam(
          pillName: event.pillName,
          uid: event.uid,
        ),
      );

      yield* usecase.fold(
        (failure) async* {
          print("Error:${failure.message}");
          yield FPrescDeletePillState(uid: event.uid);
        },
        (result) async* {
          yield FPrescDeletePillState(uid: event.uid);
          _reminderUnsetSchedule(event.pillName);
        },
      );
    }

    if (event is FPrescAddPillEvent) {
      print("AddPillEvent");
      final usecase = await cAppAddPillUsecase(
        CAppAddPillParams(
          fpPillEntity: event.pillEntity,
          uid: event.uid,
        ),
      );
      yield* usecase.fold(
        (failure) async* {
          print("Error:${failure.message}");
          yield FPrescAddPillState(uid: event.uid);
        },
        (success) async* {
          print("Success:${success}");
          yield FPrescAddPillState(uid: event.uid);
        },
      );
    }
  }
}
