import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heard/constants.dart';
import 'package:heard/firebase_services/auth_service.dart';
import 'package:heard/home/booking/user_booking_result_SLI_profile_page.dart';
import 'package:heard/http_services/booking_services.dart';
import 'package:heard/widgets/loading_screen.dart';
import 'package:heard/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heard/api/user.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class UserBookingResultPage extends StatefulWidget {
  final String pickedDate;
  final String pickedTime;
  final String hospitalName;
  final String preferredLanguage;
  final String bookingFailedMessage;
  final bool isViewOnly;

  UserBookingResultPage(
      {@required this.hospitalName,
      @required this.pickedDate,
      @required this.pickedTime,
      @required this.preferredLanguage,
      this.isViewOnly = false,
      this.bookingFailedMessage});

  @override
  _UserBookingResultPageState createState() => _UserBookingResultPageState();
}

class _UserBookingResultPageState extends State<UserBookingResultPage> {
  List<DropdownMenuItem<String>> genderList;

  String selectedGender;

  List<DropdownMenuItem<String>> experienceList;
  String authToken;
  String selectedExperience;
  List<User> allSLI;
  List<Map<String, dynamic>> allSliMap;
  List<Map<String, dynamic>> filterSLIGenderList;

  List<Map<String, dynamic>> filterSliExperienceList;

  List<Map<String, dynamic>> filterSliList;

  bool loading = true;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    getAllSli();
    Future.delayed(Duration.zero, () {
      if (widget.bookingFailedMessage != null) {
        bookingFailedDialog();
      }
    });
  }

  bookingFailedDialog() {
    // set up the button
    Widget closeButton = FlatButton(
      child: Text("Tutup"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Tempahan Tidak Tersedia"),
      content: Text(widget.bookingFailedMessage),
      actions: [
        closeButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void loadGenderList() {
    genderList = [];
    genderList.add(new DropdownMenuItem(
      child: new Text('Lelaki'),
      value: 'male',
    ));

    genderList.add(new DropdownMenuItem(
      child: new Text('Perempuan'),
      value: "female",
    ));

    genderList.add(new DropdownMenuItem(
      child: new Text('Semua'),
      value: "all",
    ));
  }

  void loadExperienceList() {
    experienceList = [];
    for (int i = 0; i < 11; i++) {
      experienceList.add(DropdownMenuItem(
        child: Text('${i != 10 ? '$i' : '$i+'} Tahun'),
        value: i.toString(),
      ));
    }

    experienceList.add(new DropdownMenuItem(
      child: new Text('Semua'),
      value: "all",
    ));
  }

  Widget loadSliList() {
    return Column(
      children: allSliMap
          .map((sli) => createSLITemplate(
              id: sli['sli_id'],
              name: sli['name'],
              gender: sli['gender'],
              age: sli['age'],
              profilePic: sli['profile_pic'],
              description: sli['description']))
          .toList(),
    );
  }

  Widget loadFilteredSliList() {
    getFilterList();
    return ListView.builder(
      scrollDirection: Axis.vertical,
      controller: ScrollController(),
      shrinkWrap: true,
      itemCount: filterSliList.length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            createSLITemplate(
              id: filterSliList[index]['sli_id'],
              name: filterSliList[index]['name'],
              gender: filterSliList[index]['gender'],
              age: filterSliList[index]['age'],
              profilePic: filterSliList[index]['profile_pic'],
              description: filterSliList[index]['description'],
              sli: allSLI[index]
            ),
            SizedBox(height: Dimensions.d_10)
          ],
        );
      },
    );
  }

  Widget createSLITemplate(
      {String id,
      String name,
      String gender,
      String age,
      String profilePic,
      String description,
      User sli}) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.d_25),
      onTap: widget.isViewOnly ? null : () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserBookingResultSLIProfilePage(
                    id: id,
                    name: name,
                    gender: gender,
                    age: age,
                    profilePic: profilePic,
                    description: description,
                    pickedDate: widget.pickedDate,
                    pickedTime: widget.pickedTime,
                    hospitalName: widget.hospitalName,
                    preferredLanguage: widget.preferredLanguage,
                    sli: sli,
                  )),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.d_20),
        ),
        elevation: Dimensions.d_10,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Dimensions.d_10),
          child: ListTile(
            leading: CircleAvatar(
                backgroundColor: Colours.lightGrey,
                radius: Dimensions.d_35,
                child: profilePic == null ? Image(
                  image: AssetImage('images/avatar.png'),
                ) : GetCachedNetworkImage(
                  profilePicture: profilePic,
                  authToken: authToken,
                  dimensions: Dimensions.d_55,
                ),
              ),
            title: RichTextField("Nama", name),
            subtitle: RichTextField("Jantina", gender == 'female' ? 'Perempuan' : 'Lelaki'),
            isThreeLine: true,
          ),
        ),
      ),
    );
  }

  Future<void> getAllSli() async {
    String _authToken = await AuthService.getToken();
    List<User> _allSli =
        await BookingServices().getAllSLI(headerToken: _authToken);
    List<Map<String, dynamic>> _allSliJson = List<Map<String, dynamic>>();
    for (User sli in _allSli) {
      _allSliJson.add(sli.toJson());
    }
    setState(() {
      allSLI = _allSli;
      allSliMap = _allSliJson;
      loading = false;
      authToken = _authToken;
    });
  }

  void _onRefresh() async {
    await getAllSli();
    if (allSliMap == null) {
      _refreshController.refreshFailed();
    } else {
      _refreshController.refreshCompleted();
      setState(() {
        selectedGender = null;
        selectedExperience = null;
      });
    }
  }

  void getFilterList() {
    filterSLIGenderList = [];
    filterSliExperienceList = [];
    filterSliList = [];

    if (selectedGender != null && selectedGender != 'all') {
      allSliMap.forEach((element) {
        if (element['gender'] == selectedGender) {
          filterSLIGenderList.add(element);
        }
      });
    } else {
      allSliMap.forEach((element) {
        filterSLIGenderList.add(element);
      });
    }

    if (selectedExperience != null && selectedExperience != 'all') {
      allSliMap.forEach((element) {
        if (element['years_medical'].toString() == selectedExperience) {
          filterSliExperienceList.add(element);
        }
      });
    } else {
      allSliMap.forEach((element) {
        filterSliExperienceList.add(element);
      });
    }

    for (var sli in filterSLIGenderList) {
      if (filterSliExperienceList.contains(sli)) {
        filterSliList.add(sli);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    loadGenderList();
    loadExperienceList();
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colours.white,
          appBar: AppBar(
            backgroundColor: Colours.blue,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            title: Text(
              widget.isViewOnly ? 'JBIM Didaftarkan' : 'Hasil Carian',
              style: GoogleFonts.lato(
                fontSize: FontSizes.mainTitle,
                fontWeight: FontWeight.bold,
                color: Colours.white,
              ),
            ),
            centerTitle: true,
            elevation: 0.0,
          ),
          body: loading
              ? LoadingScreen()
              : SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  enablePullDown: true,
                  header: ClassicHeader(),
                  child: ListView(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(Dimensions.d_15,
                            Dimensions.d_10, Dimensions.d_15, Dimensions.d_30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            widget.isViewOnly ? SizedBox.shrink() : Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 8,
                                      child: Container(
                                        height: Dimensions.d_45,
                                        child: DropdownList(
                                          hintText: "Jantina",
                                          selectedItem: selectedGender,
                                          itemList: genderList,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedGender = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: Dimensions.d_10),
                                    Expanded(
                                      flex: 10,
                                      child: Container(
                                        height: Dimensions.d_45,
                                        child: DropdownList(
                                          hintText: "Pengalaman",
                                          selectedItem: selectedExperience,
                                          itemList: experienceList,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedExperience = value;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Dimensions.d_20),
                              ],
                            ),
                            loadFilteredSliList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
    );
  }
}
