import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heard/api/user.dart';
import 'package:heard/constants.dart';
import 'package:heard/firebase_services/auth_service.dart';
import 'package:heard/home/booking/user_booking_result_page.dart';
import 'package:heard/home/booking/user_booking_success.dart';
import 'package:heard/http_services/booking_services.dart';
import 'package:heard/widgets/loading_screen.dart';
import 'package:heard/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class UserBookingResultSLIProfilePage extends StatefulWidget {
  final String id;
  final String name;
  final String gender;
  final String age;
  final String description;
  final String profilePic;
  final String pickedDate;
  final String pickedTime;
  final String hospitalName;
  final String preferredLanguage;
  final User sli;

  UserBookingResultSLIProfilePage({
    this.id,
    this.name,
    this.gender,
    this.age,
    this.description,
    this.profilePic,
    this.pickedTime,
    this.pickedDate,
    this.hospitalName,
    this.preferredLanguage,
    this.sli
  });

  @override
  _UserBookingResultSLIProfilePageState createState() =>
      _UserBookingResultSLIProfilePageState();
}

class _UserBookingResultSLIProfilePageState
    extends State<UserBookingResultSLIProfilePage> {
  TextEditingController notes = TextEditingController();
  bool sendingRequest = false;
  String authToken;

  @override
  void initState() {
    super.initState();
    getAuthToken();
  }

  void getAuthToken() async {
    String _authToken = await AuthService.getToken();
    setState(() {
      authToken = _authToken;
    });
  }

  void showUserInformation({int index}) {
    popUpDialog(
      context: context,
      isSLI: false,
      height: Dimensions.d_160 * 3.5,
      padding: EdgeInsets.symmetric(
          vertical: Dimensions.d_15, horizontal: Dimensions.d_20),
      contentFlexValue: 5,
      buttonText: 'Mengesah',
      onClick: () {
        Navigator.pop(context);
        setState(() {
          sendingRequest = true;
        });
        requestBooking();
      },
      header: 'Pengesahan',
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: ListTile(
              isThreeLine: true,
              subtitle: ListView(
                children: <Widget>[
                  RichTextField("Nama", widget.name),
                  RichTextField("Jantina", widget.gender == 'female' ? 'Perempuan' : 'Lelaki'),
                  RichTextField("Tarikh", widget.pickedDate),
                  RichTextField("Masa", widget.pickedTime),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(top: Dimensions.d_15),
              child: Container(
                height: Dimensions.d_200,
                decoration: BoxDecoration(
                  color: Colours.lightGrey,
                  borderRadius:
                      BorderRadius.all(Radius.circular(Dimensions.d_10)),
                  // border: Border.all(),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.d_25),
                  child: InputField(
                    controller: notes,
                    labelText: 'Nota kepada JBIM',
                    backgroundColour: Colours.lightGrey,
                    moreLines: true,
                    hintText: '(Tempoh masa meeting)',
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  requestBooking() async {
    int response = await BookingServices().requestBooking(
        headerToken: authToken,
        sliId: widget.id,
        date: widget.pickedDate,
        time: widget.pickedTime,
        hospitalName: widget.hospitalName,
        notes: 'Bahasa Pilihan ialah ${widget.preferredLanguage}. ${notes.text.toString()}',
    );
    if (response == 200) {
      setState(() {
        sendingRequest = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserBookingSuccessPage()),
      );
    } else {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserBookingResultPage(
          pickedDate: widget.pickedDate,
          pickedTime: widget.pickedTime,
          hospitalName: widget.hospitalName,
          preferredLanguage: widget.preferredLanguage,
          bookingFailedMessage: 'JBIM yang dipilih tidak tersedia untuk menerima tempahan pada masa ini. Sila memilih masa yang lain.',
        )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colours.white,
        appBar: AppBar(
          backgroundColor: Colours.blue,
          title: Text(
            'Profil JBIM',
            style: GoogleFonts.lato(
              fontSize: FontSizes.mainTitle,
              fontWeight: FontWeight.bold,
              color: Colours.white,
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: sendingRequest
            ? LoadingScreen()
            : ListView(
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(Dimensions.d_0,
                          Dimensions.d_25, Dimensions.d_0, Dimensions.d_10),
                      child: CircleAvatar(
                        backgroundColor: Colours.lightGrey,
                        radius: Dimensions.d_65,
                        child: widget.profilePic == null ? Image(
                          image: AssetImage('images/avatar.png'),
                        ) : GetCachedNetworkImage(
                          profilePicture: widget.profilePic,
                          authToken: authToken,
                          dimensions: Dimensions.d_120,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      widget.name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: FontSizes.title),
                    ),
                  ),
                  SizedBox(height: Dimensions.d_20),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.d_35),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions.d_20),
                      ),
                      elevation: Dimensions.d_10,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.d_20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: Dimensions.d_20),
                            RichTextField("Jantina", widget.gender == 'female' ? 'Perempuan' : 'Lelaki'),
                            SizedBox(height: Dimensions.d_10),
                            RichTextField("Nombor Telefon", widget.sli.phoneNo),
                            SizedBox(height: Dimensions.d_10),
                            RichTextField("Kemahiran Dalam Bidang Perubatan", widget.sli.experienced_medical == true? 'Mahir':'Tiada' ),
                            SizedBox(height: Dimensions.d_10),
                            RichTextField("Kemahiran Menterjemah", widget.sli.experienced_bim == true? 'Mahir':'Tiada' ),
                            SizedBox(height: Dimensions.d_10),
                            RichTextField("Pengalaman Dalam Bidang Perubatan", widget.sli.years_medical.toString()),
                            SizedBox(height: Dimensions.d_10),
                            RichTextField("Pengalaman Menterjemah", widget.sli.years_bim.toString()),
                            SizedBox(height: Dimensions.d_10),
                            RichTextField("Bahasa Isyarat ASL", widget.sli.asl_proficient == true ? 'Mahir' : 'Tiada'),
                            SizedBox(height: Dimensions.d_10),
                            RichTextField("Bahasa Isyarat BIM", widget.sli.bim_proficient == true ? 'Mahir' : 'Tiada'),
                            SizedBox(height: Dimensions.d_10),
                            RichTextField("Pendidikan", widget.sli.education.text.toString()),
                            SizedBox(height: Dimensions.d_20),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(Dimensions.d_35),
                    child: Container(
                      height: Dimensions.d_160,
                      decoration: BoxDecoration(
                        color: Colours.lightBlue,
                        borderRadius:
                            BorderRadius.all(Radius.circular(Dimensions.d_10)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(Dimensions.d_20),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("Deskripsi",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: Dimensions.d_10),
                              Container(
                                child: Text(
                                  widget.description,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: sendingRequest
            ? SizedBox.shrink()
            : UserButton(
                text: 'Buat Tempahan',
                color: Colours.blue,
                padding: EdgeInsets.all(Dimensions.d_30),
                onClick: () {
                  showUserInformation();
                },
              ),
      ),
    );
  }
}
