import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heard/constants.dart';
import 'package:heard/home/booking/user_booking_result_page.dart';
import 'package:heard/widgets/widgets.dart';
import 'package:intl/intl.dart';

class UserBookingPage extends StatefulWidget {
  final PageController pageController;

  UserBookingPage({this.pageController});
  @override
  _UserBookingPageState createState() => _UserBookingPageState();
}

class _UserBookingPageState extends State<UserBookingPage> {
  TimeOfDay currentTime;
  DateTime currentDate;
  String formattedDate;
  bool isButtonDisabled = true;


  List <DropdownMenuItem <String>> languageList;
  String selectedLanguage;

  List <DropdownMenuItem <String>> clinicList;
  String selectedClinic;

  void resetSearchCriteria() {
    setState(() {
      selectedLanguage = null;
      selectedClinic = null;
      currentDate = null;
      currentTime = null;
      isButtonDisabled= true;
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

  Future<DateTime> _pickDate({bool isStart = true}) async {
    DateTime selectedDate =
    await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().add(new Duration(days: 0)),
        lastDate: DateTime.now().add(new Duration(days: 366))
    );
    return selectedDate;
  }

  void loadLanguageList(){

    languageList=[];
    languageList.add(new DropdownMenuItem(
      child: new Text ('Bahasa Malaysia'),
      value: 'bm',
    ));

    languageList.add(new DropdownMenuItem(
      child: new Text ('English'),
      value: "eng",
    ));
  }

  void loadClinicList(){

    clinicList=[];
    clinicList.add(new DropdownMenuItem(
      child: new Text ('Klinik Ria'),
      value: 'clinic1',
    ));

    clinicList.add(new DropdownMenuItem(
      child: new Text ('Hospital Sunway'),
      value: "hospital1",
    ));
  }

  Widget _timePickerField() {
    return StatefulBuilder(builder: (context, setState) {
      return Ink(
        decoration:BoxDecoration(
            color:Colours.lightBlue,
            borderRadius: BorderRadius.all(Radius.circular(Dimensions.d_10))
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.d_10)),
          title: Text(
            currentTime == null ?
            'Pilih Masa ...' :
            _getFormattedTime(currentTime),
          ),
          trailing: Icon(Icons.keyboard_arrow_down),
          onTap: () async {
            TimeOfDay selectedTime= await _pickTime();
            if (selectedTime != null) {
              setState(() {
                currentTime = selectedTime;
              });
            }
          },
        ),
      );
    });
  }

  Widget _datePickerField() {
    return StatefulBuilder(builder: (context, setState) {
      return Ink(
        decoration:BoxDecoration(
            color:Colours.lightBlue,
            borderRadius: BorderRadius.all(Radius.circular(Dimensions.d_10))
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Dimensions.d_10)),
          title: Text(
            currentDate == null ?
            'Pilih Tarikh ...' :
            DateFormat('yyyy-MM-dd').format(currentDate),
          ),
          trailing: Icon(Icons.keyboard_arrow_down),
          onTap: () async {
            DateTime selectedDate= await _pickDate();
            if (selectedDate != null) {
              setState(() {
                currentDate = selectedDate;
              });
            }
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    loadLanguageList();
    loadClinicList();
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colours.white,
        body: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(Dimensions.d_30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      height: Dimensions.d_160,
                      child: Image(
                          image: AssetImage('images/bookingCalendar.png')
                      ),
                    ),
                  ),
                  FieldLabel(
                    text:"Tarikh Temu Janji",
                  ),
                  SizedBox(
                    height: Dimensions.d_5,
                  ),
                  _datePickerField(),
                  SizedBox(
                    height: Dimensions.d_5,
                  ),
                  FieldLabel(
                    text:"Masa Temu Janji",
                  ),
                  SizedBox(
                    height: Dimensions.d_5,
                  ),
                  _timePickerField(),
                  FieldLabel(
                    text:"Pilihan Bahasa",
                  ),
                  SizedBox(
                    height: Dimensions.d_5,
                  ),
                  DropdownList(
                    hintText: "Bahasa Malaysia",
                    selectedItem: selectedLanguage,
                    itemList: languageList,
                    onChanged: (value){
                      setState(() {
                        selectedLanguage= value;
                      });
                    },
                  ),
                  SizedBox(
                    height: Dimensions.d_5,
                  ),
                  FieldLabel(
                    text:"Nama Hospital / Klinik",
                  ),
                  SizedBox(
                    height: Dimensions.d_5,
                  ),
                  DropdownList(
                    hintText: "Klinik A",
                    selectedItem: selectedClinic,
                    itemList: clinicList,
                    onChanged: (value){
                      setState(() {
                        selectedClinic= value;
                        checkAllInformationFilled();
                      });
                    },
                  ),
                  SizedBox(
                    height: Dimensions.d_45,
                  ),
                  UserButton(
                    text: 'Carian',
                    color: Colours.blue,
                    onClick: isButtonDisabled ? null: () async {
                      bool canResetSearchCriteria = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserBookingResultPage(
                          pickedDate: DateFormat('yyyy-MM-dd').format(currentDate) ,
                          pickedTime: _getFormattedTime(currentTime),
                          hospitalName: selectedClinic,
                          preferredLanguage: selectedLanguage,
                        )),
                      );
                      if (canResetSearchCriteria != null && canResetSearchCriteria) {
                        resetSearchCriteria();
                        setState(() {
                          widget.pageController.jumpToPage(2);
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkAllInformationFilled() {
    if (selectedLanguage.isNotEmpty &&  selectedClinic.isNotEmpty &&
        currentDate != null &&  currentTime != null)
      isButtonDisabled = false;
    else
      isButtonDisabled = true;
  }


}