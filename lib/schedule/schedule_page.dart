import 'package:flutter/material.dart';
import 'package:heard/constants.dart';
import 'package:heard/widgets/widgets.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> with AutomaticKeepAliveClientMixin{

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colours.orange,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colours.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Jadual',
            style: TextStyle(
                fontSize: FontSizes.mainTitle,
                fontWeight: FontWeight.bold,
                color: Colours.white),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        backgroundColor: Colours.white,
        body: ListView(children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ScheduleSlot(title: 'Isnin'),
              ScheduleSlot(title: 'Selesa'),
              ScheduleSlot(title: 'Rabu'),
              ScheduleSlot(title: 'Khamis'),
              ScheduleSlot(title: 'Jumaat'),
            ],
          ),
        ]),
      ),
    );
  }
}

class ScheduleSlot extends StatefulWidget {
  final String title;

  ScheduleSlot({this.title});

  @override
  _ScheduleSlotState createState() => _ScheduleSlotState();
}

class _ScheduleSlotState extends State<ScheduleSlot> {
  List<String> testTimeSlots = [];
  TimeOfDay startTime;
  TimeOfDay endTime;

  void _addTimeSlot() {
    String newTimeSlot =
        '${_getFormattedTime(startTime)} - ${_getFormattedTime(endTime)}';
    setState(() {
      startTime = null;
      endTime = null;
      if (!testTimeSlots.contains(newTimeSlot)) {
        testTimeSlots.add(newTimeSlot);
      }
    });
  }

  String _getFormattedTime(TimeOfDay currentTime) {
    return currentTime.toString().substring(
        currentTime.toString().length - 6, currentTime.toString().length - 1);
  }

  Future<TimeOfDay> _pickTime({bool isStart = true}) async {
    TimeOfDay selectedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    return selectedTime;
  }

  Widget _timePickerField(
      {String initialTitle, TimeOfDay currentTime, bool isStartTime = true}) {
    return StatefulBuilder(builder: (context, setState) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.d_10),
        child: Container(
          color: Colours.lightOrange,
          child: ListTile(
            title: Text(
              currentTime == null
                  ? initialTitle
                  : _getFormattedTime(currentTime),
              style: TextStyle(
                  color: Colours.darkGrey,
                  fontSize: FontSizes.normal,
                  fontWeight: FontWeight.w300),
            ),
            trailing: IconButton(
              icon: Icon(Icons.keyboard_arrow_down),
              onPressed: () async {
                TimeOfDay selectedTime = await _pickTime();
                if (selectedTime != null) {
                  setState(() {
                    currentTime = selectedTime;
                    if (isStartTime)
                      startTime = currentTime;
                    else
                      endTime = currentTime;
                  });
                }
              },
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          color: Colours.lightOrange,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          borderOnForeground: true,
          elevation: 0,
          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ListTile(
            title: Padding(
              padding: Paddings.horizontal_5,
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: FontSizes.title,
                  fontWeight: FontWeight.bold,
                  color: Colours.darkGrey,
                ),
              ),
            ),
            trailing: IconButton(
                icon: Icon(
                  Icons.add_circle,
                  color: Colours.darkGrey,
                  size: Dimensions.d_30,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // return object of type Dialog
                      return Dialog(
                        child: Container(
                          height: Dimensions.dialogHeight,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: Dimensions.d_15,
                                horizontal: Dimensions.d_30),
                            child: ListView(
                              children: <Widget>[
                                Padding(
                                  padding: Paddings.vertical_15,
                                  child: Text(
                                    "Pilih Masa",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: FontSizes.title,
                                        color: Colours.darkGrey),
                                  ),
                                ),
                                SizedBox(
                                  height: Dimensions.d_30,
                                ),
                                _timePickerField(
                                  initialTitle: 'Pilih Masa Mula',
                                  currentTime: startTime,
                                ),
                                SizedBox(
                                  height: Dimensions.d_15,
                                ),
                                _timePickerField(
                                    initialTitle: 'Pilih Masa Tamat',
                                    currentTime: endTime,
                                    isStartTime: false),
                                SizedBox(
                                  height: Dimensions.d_65,
                                ),
                                UserButton(
                                  text: 'Mengesah',
                                  color: Colours.orange,
                                  onClick: () {
                                    _addTimeSlot();
                                    Navigator.pop(context);
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                                Radius.circular(Dimensions.d_10))),
                        elevation: Dimensions.d_15,
                      );
                    },
                  );
                }),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: Dimensions.d_15, vertical: Dimensions.d_10),
          child: TimeSlots(
            timeSlots: testTimeSlots,
          ),
        ),
      ],
    );
  }
}

class TimeSlotList extends StatefulWidget {
  final List<String> timeSlots;

  TimeSlotList({this.timeSlots});

  @override
  State createState() => TimeSlotListState();
}

class TimeSlotListState extends State<TimeSlotList> {
  Iterable<Widget> get timeSlotWidgets sync* {
    for (final String timeSlot in widget.timeSlots) {
      yield Padding(
        padding: const EdgeInsets.all(4.0),
        child: Chip(
          deleteIconColor: Colours.white,
          backgroundColor: Colours.orange,
          label: Text(timeSlot),
          labelStyle: TextStyle(
              fontSize: FontSizes.normal,
              fontWeight: FontWeight.w500,
              color: Colours.darkGrey),
          onDeleted: () {
            setState(() {
              widget.timeSlots.removeWhere((String entry) {
                return entry == timeSlot;
              });
            });
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: timeSlotWidgets.toList(),
    );
  }
}

class TimeSlots extends StatefulWidget {
  final List<String> timeSlots;

  TimeSlots({this.timeSlots});

  @override
  _TimeSlotsState createState() => _TimeSlotsState();
}

class _TimeSlotsState extends State<TimeSlots> {
  @override
  Widget build(BuildContext context) {
    return TimeSlotList(
      timeSlots: widget.timeSlots,
    );
  }
}
