import 'dart:collection';
import 'dart:math';

import 'package:datn/model/teach_classes/teach_class.dart';
import 'package:datn/model/user/teach_schedules.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:datn/model/user/user.dart' as model_user;
import 'package:datn/screen/qr_code/components/qr_code_view.dart';
import 'dart:convert';
import 'package:datn/database/firestore/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClassInfoTutorScreen extends StatefulWidget {
  const ClassInfoTutorScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ClassInfoTutorScreenState();
  }
}

class _ClassInfoTutorScreenState extends State<ClassInfoTutorScreen> {
  Map<String, dynamic> learnerInfo = {};
  int lessonOnWeek = 0;
  List<LessonSchedules> lessonSchedules = [];
  late DateTime startDate;
  late DateTime endDate;
  DateTime? _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;
  Map<DateTime, List> _eventsList = {};
  Map<DateTime, Object> _eventsListState = {};
  FirebaseAuth auth = FirebaseAuth.instance;
  FirestoreService firestoreService = FirestoreService();

  @override
  String getTimeHour(Timestamp? attendanceTime) {
    if (attendanceTime == null) {
      return '';
    }
    DateTime dateTimeFromTimestamp = attendanceTime.toDate();

    String formattedTime = DateFormat.Hm().format(dateTimeFromTimestamp);
    print("formattedTime   $formattedTime");
    return formattedTime;
  }

  void initState() {
    super.initState();
    learnerInfo = Provider.of<Map<String, dynamic>>(context, listen: false);
    WeekSchedules? weekSchedules =
        (learnerInfo['teachClass'] as TeachClass).schedules?.weekSchedules;
    lessonOnWeek = countDayOnWeek(weekSchedules);
    if ((learnerInfo['teachClass'] as TeachClass).schedules != null) {
      lessonSchedules =
          (learnerInfo['teachClass'] as TeachClass).schedules!.lessonSchedules!;
    }
    startDate = DateTime.fromMillisecondsSinceEpoch(
        lessonSchedules[0].startTime!.millisecondsSinceEpoch);
    endDate = DateTime.fromMillisecondsSinceEpoch(
        lessonSchedules[lessonSchedules.length - 1]
            .startTime!
            .millisecondsSinceEpoch);
    _focusedDay = startDate;
    _selectedDay = startDate;
    lessonSchedules.forEach((itemLesson) {
      print("itemLesson $itemLesson");

      _eventsList.addAll({
        DateTime.fromMillisecondsSinceEpoch(
            itemLesson.startTime!.millisecondsSinceEpoch): [
          'Thời gian điểm danh :  ${itemLesson.attendanceTime != null ? getTimeHour(itemLesson.attendanceTime) : ''}'
        ],
      });
      _eventsListState.addAll({
        DateTime.fromMillisecondsSinceEpoch(
            itemLesson.startTime!.millisecondsSinceEpoch): itemLesson,
      });
    });
  }

  int countDayOnWeek(WeekSchedules? weekSchedules) {
    int count = 0;
    if (weekSchedules != null) {
      if (weekSchedules.monday != null) {
        count++;
      }
      if (weekSchedules.tuesday != null) {
        count++;
      }
      if (weekSchedules.wednesday != null) {
        count++;
      }
      if (weekSchedules.thursday != null) {
        count++;
      }
      if (weekSchedules.friday != null) {
        count++;
      }
      if (weekSchedules.saturday != null) {
        count++;
      }
      if (weekSchedules.sunday != null) {
        count++;
      }
    }
    return count;
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  Widget build(BuildContext context) {
    final _events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventsList);
    final _eventsState = LinkedHashMap<DateTime, Object>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventsListState);

    Widget _currentDialog;
    List getEventForDay(DateTime day) {
      return _events[day] ?? [];
    }

    Object? getEventStateForDay(DateTime day) {
      return _eventsState[day] != null ? _eventsState[day] : null;
    }

    firestoreService.listenChangeInfoClass(learnerInfo['docId'],
        (dynamic value) {
      setState(() {

        Navigator.of(context).pop();

        learnerInfo = value;
        if ((value['teachClass'] as TeachClass).schedules != null) {
          lessonSchedules =
              (value['teachClass'] as TeachClass).schedules!.lessonSchedules!;
        }
        lessonSchedules.forEach((itemLesson) {
          print("itemLesson $itemLesson");

          _eventsList.addAll({
            DateTime.fromMillisecondsSinceEpoch(
                itemLesson.startTime!.millisecondsSinceEpoch): [
              'Thời gian điểm danh :  ${itemLesson.attendanceTime != null ? getTimeHour(itemLesson.attendanceTime) : ''}'
            ],
          });
          _eventsListState.addAll({
            DateTime.fromMillisecondsSinceEpoch(
                itemLesson.startTime!.millisecondsSinceEpoch): itemLesson,
          });
        });
      });
    });

    void _openModalQrClass(BuildContext context, dynamic classInfo) {
      var info = {"uid": classInfo["docId"], "type": 'class'};

      String jsonInfo = classInfo["docId"] != null ? jsonEncode(info) : "";
      _currentDialog = Dialog(
        child: Container(
          width: double.infinity,
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: QRCodeView(text: jsonInfo),
                ),
              ),
            ],
          ),
        ),
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return _currentDialog;
        },
      );
    }

    void _openModalQrUser(BuildContext context, dynamic user) {
      var info = {"uid": user.uid, "type": 'learner'};
      String jsonInfo = user.uid != null ? jsonEncode(info) : "";
      _currentDialog = Dialog(
        child: Container(
          width: double.infinity,
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: QRCodeView(text: jsonInfo),
                ),
              ),
            ],
          ),
        ),
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return _currentDialog;
        },
      );
    }

    void _openModalActionQrClass(BuildContext context, String jsonInfo) {
      _currentDialog = Dialog(
        child: Container(
          width: double.infinity,
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: QRCodeView(text: jsonInfo),
                ),
              ),
            ],
          ),
        ),
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return _currentDialog;
        },
      );
    }

    String _getTimeNow() {
      DateTime currentDateTime = DateTime.now();
      Timestamp timestamp = Timestamp.fromDate(currentDateTime);

      Map<String, dynamic> timestampJson = {
        'seconds': timestamp.seconds,
        'nanoseconds': timestamp.nanoseconds,
      };

      String timestampJsonString = jsonEncode(timestampJson);
      return timestampJsonString;
    }

    void _openModalOff(BuildContext context, dynamic classInfo) {
      var info = {"uid": classInfo["docId"], "type": 'class'};
      var objState = getEventStateForDay(_selectedDay!) as dynamic;
      var obj = {};
      if (objState == null) {
        return null;
      }
      Timestamp timestampStart = objState.startTime;
      Map<String, dynamic> startTimeJson = {
        'seconds': timestampStart.seconds,
        'nanoseconds': timestampStart.nanoseconds,
      };

      String startTimeJsonString = jsonEncode(startTimeJson);
      info["timeCheck"] = _getTimeNow();
      info["startTime"] = startTimeJsonString;
      info['state'] = 'not-stydying';
      String jsonInfo = classInfo["docId"] != null ? jsonEncode(info) : "";
      _openModalActionQrClass(context, jsonInfo);
    }

    dynamic _renderAction(BuildContext context, dynamic classInfo) {
      print(lessonSchedules);
      print("classInfo : $classInfo");
      var objState = getEventStateForDay(_selectedDay!) as dynamic;

      print("objState.state == 'progress' ${objState}");

      var obj = {};
      if (objState == null) {
        return null;
      }
      Timestamp timestampStart = objState.startTime;
      Map<String, dynamic> startTimeJson = {
        'seconds': timestampStart.seconds,
        'nanoseconds': timestampStart.nanoseconds,
      };

      String startTimeJsonString = jsonEncode(startTimeJson);
      var info = {"uid": classInfo["docId"], "type": 'class'};
      info["startTime"] = startTimeJsonString;
      obj['text'] = 'Bắt đầu dạy';
      info['state'] = 'progress';
      print(info);
      obj['action'] = () {
        info["timeCheck"] = _getTimeNow();
        String jsonInfo = classInfo["docId"] != null ? jsonEncode(info) : "";
        _openModalActionQrClass(context, jsonInfo);
      };
      if (objState.state == 'progress') {
        obj['text'] = 'Đang dạy';
        info['state'] = 'done';
        obj['action'] = () {
          info["timeCheck"] = _getTimeNow();
          String jsonInfo = classInfo["docId"] != null ? jsonEncode(info) : "";
          _openModalActionQrClass(context, jsonInfo);
        };
      }
      if (objState.state == 'done') {
        obj['text'] = 'Đã dạy xong';
        obj['action'] = () {};
      }
      if (objState.state == 'not-stydying') {
        obj['text'] = 'Nghỉ dạy';
        info['state'] = 'not-stydying';
        obj['action'] = () {
        };
      }
      print("obj === $obj");
      return obj;
    }

    ;
    return Scaffold(
      appBar: AppBar(title: const Text("Thông tin lớp học")),
      body: SingleChildScrollView(
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Text(
                        'Học viên',
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CircleAvatar(
                      backgroundImage: (((learnerInfo['learnerInfo'])
                                      as model_user.User)
                                  .photoUrl !=
                              null)
                          ? NetworkImage(
                              ((learnerInfo['learnerInfo']) as model_user.User)
                                  .photoUrl!)
                          : const AssetImage('assets/bear.jpg')
                              as ImageProvider,
                      radius: 50),
                  const SizedBox(
                    height: 20,
                  ),
                  IconButton(
                    iconSize: 30,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    style: const ButtonStyle().copyWith(
                        backgroundColor: MaterialStatePropertyAll(
                            Theme.of(context).colorScheme.background)),
                    onPressed: () {
                      _openModalQrUser(context, ((learnerInfo['learnerInfo'])));
                    },
                    icon: const Icon(Icons.qr_code),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Card(
                    color: Theme.of(context).colorScheme.primary,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(
                        (((learnerInfo['learnerInfo']) as model_user.User)
                                .displayName) ??
                            '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Card(
                    color: Theme.of(context).colorScheme.background,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Môn :',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  (((learnerInfo['teachClass']) as TeachClass)
                                          .subject) ??
                                      '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const Text(
                                'Hình thức dạy :',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  (((learnerInfo['teachClass']) as TeachClass)
                                          .teachMethod) ??
                                      '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const Text(
                                'Số điện thoại người học :',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  (((learnerInfo['learnerInfo'])
                                              as model_user.User)
                                          .phone) ??
                                      '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const Text(
                                'Số buổi học :',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  (lessonOnWeek.toString() + " buổi/tuần"),
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              const Text(
                                'Địa chỉ :',
                                style: TextStyle(fontSize: 16),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  (((learnerInfo['teachClass']) as TeachClass)
                                          .address) ??
                                      '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          const Row(
                            children: [
                              Text(
                                'Lương/tháng :',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  '',
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.edit_document,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                label: Text(
                                  'Viết báo cáo',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                ),
                                style: OutlinedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                icon: Icon(
                                  Icons.qr_code,
                                  color:
                                      Theme.of(context).colorScheme.onSecondary,
                                ),
                                label: Text(
                                  'Thông tin lớp học',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary),
                                ),
                                style: OutlinedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary),
                                onPressed: () {
                                  _openModalQrClass(context, learnerInfo);
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (_renderAction(context, learnerInfo) != null)
                                OutlinedButton.icon(
                                  icon: Icon(
                                    Icons.qr_code,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                  ),
                                  label: Text(
                                    _renderAction(
                                            context, learnerInfo)['text'] ??
                                        '',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary),
                                  onPressed: () {
                                    _renderAction(
                                            context, learnerInfo)['action']() ??
                                        () => {};
                                  },
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if ((getEventStateForDay(_selectedDay!)
                                          as dynamic) !=
                                      null &&
                                  ((getEventStateForDay(_selectedDay!)
                                                  as dynamic)
                                              .state ==
                                          'open' ||
                                      (getEventStateForDay(_selectedDay!)
                                                  as dynamic)
                                              .state ==
                                          null))
                                OutlinedButton.icon(
                                  icon: Icon(
                                    Icons.qr_code,
                                    color:
                                        Theme.of(context).colorScheme.onError,
                                  ),
                                  label: Text(
                                    'Nghỉ học',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onError),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error),
                                  onPressed: () {
                                    _openModalOff(context, learnerInfo);
                                  },
                                ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: Theme.of(context).colorScheme.background,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Lịch dạy ',
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  TableCalendar(
                    focusedDay: _focusedDay,
                    firstDay: startDate,
                    lastDay: endDate,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        // Call `setState()` when updating calendar format
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      print(selectedDay.toString());
                      print(focusedDay.toString());
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      // getDaySchedules(selectedDay);
                    },
                    eventLoader: (day) {
                      return getEventForDay(day);
                    },
                  ),
                  ListView(
                    shrinkWrap: true,
                    children: getEventForDay(_selectedDay!)
                        .map((event) => ListTile(
                              title: Text(event.toString()),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
