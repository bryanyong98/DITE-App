import 'package:flutter/material.dart';
import 'package:heard/api/on_demand_request.dart';
import 'package:heard/api/on_demand_status.dart';
import 'package:heard/api/user.dart';
import 'package:heard/constants.dart';
import 'package:heard/firebase_services/auth_service.dart';
import 'package:heard/firebase_services/fcm.dart';
import 'package:heard/home/booking/sli_booking_page.dart';
import 'package:heard/home/booking/user_booking_page.dart';
import 'package:heard/home/booking/user_booking_result_page.dart';
import 'package:heard/home/drawer_tab/covid_questionnaire.dart';
import 'package:heard/home/on_demand/on_demand_sli_page.dart';
import 'package:heard/home/on_demand/on_demand_user_page.dart';
import 'package:heard/home/profile/profile.dart';
import 'package:heard/home/transaction/transaction_page.dart';
import 'package:heard/http_services/on_demand_services.dart';
import 'package:heard/http_services/sli_services.dart';
import 'package:heard/http_services/user_services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heard/chat_service/chathome.dart';

class Navigation extends StatefulWidget {
  final bool isSLI;

  Navigation({this.isSLI = false});

  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _currentPageIndex = 0;
  List<Widget> _pages;
  final List<String> _titles = [
    'Tempahan Segera',
    'Janji Temu',
    'Transaksi',
    'Profil'
  ];
  bool showLoadingAnimation = false;
  String authToken;
  User userDetails;
  OnDemandStatus onDemandStatus;
  List<OnDemandRequest> onDemandRequests;
  final pageController = PageController();

  @override
  void initState() {
    super.initState();
    initializeUser();
  }

  void initializeUser() async {
    setState(() {
      showLoadingAnimation = true;
    });
    String token = await AuthService.getToken();
    print('Auth Token: $token');
    User user;
    List<OnDemandRequest> allRequests = [];
    OnDemandStatus status;
    if (widget.isSLI == false) {
      user = await UserServices().getUser(headerToken: token);
    } else {
      user = await SLIServices().getSLI(headerToken: token);
      status = await OnDemandServices().getOnDemandStatus(isSLI: true, headerToken: token);
      if (status.status != 'ongoing') {
        allRequests =
        await OnDemandServices().getAllRequests(headerToken: token);
        print('Got all on-demand requests ...');
      }
//      print('Request: $onDemandRequests and length of ${onDemandRequests.length}');
    }
    setState(() {
      authToken = token;
      userDetails = user;
      onDemandRequests = allRequests;
      showLoadingAnimation = false;
      onDemandStatus = status;
    });
  }

  void onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Send FCM token depending on whether logged in is user or sli
    widget.isSLI ? print("User type: SLI") : print("User type: User");

    if (_pages == null && userDetails != null && authToken != null) {
      // determine whether its user or sli tab pages
      _pages = widget.isSLI
          ? [
              OnDemandSLIPage(onDemandRequests: onDemandRequests, status: onDemandStatus),
              SLIBookingPage(),
              TransactionPage(),
              Profile(userDetails: userDetails)
            ]
          : [
              OnDemandUserPage(),
              UserBookingPage(pageController: pageController,),
              TransactionPage(),
              Profile(userDetails: userDetails)
            ];
      var fcm = FCM();
      widget.isSLI ? fcm.init("sli") : fcm.init("user");
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colours.white,
        appBar: AppBar(
          leading: widget.isSLI ? SizedBox.shrink() : null,
          title: Text(
            _titles[_currentPageIndex],
            style: GoogleFonts.lato(
              fontSize: FontSizes.mainTitle,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: widget.isSLI ? Colours.orange : Colours.blue,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.d_10),
              child: IconButton(
                icon: Icon(Icons.question_answer),
                iconSize: Dimensions.d_30,
                onPressed: () {
                  Navigator.push(
                    context,
                    /// push the chat screen over here
                    MaterialPageRoute(builder: (context) => ChatHomeScreen()),
                  );
                },
              ),
            )
          ],
        ),
        drawer: widget.isSLI ? null : Drawer(
          child: ListView(
            children: [
              Container(
                height: Dimensions.d_55,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colours.blue
                  ),
                  child: Text('DITE', style: GoogleFonts.lato(
                    color: Colours.white,
                    fontWeight: FontWeight.bold,
                  ),),
                ),
              ),
              ListTile(
                title: Text('Soal Selidik COVID-19'),
                leading: Icon(Icons.assignment, color: Colours.darkGrey,),
                onTap: () {
                  Navigator.push(
                    context,
                    /// push the chat screen over here
                    MaterialPageRoute(builder: (context) => Questionnaire()),
                  );
                },
              ),
              Divider(
                height: Dimensions.d_0,
                thickness: Dimensions.d_3,
                color: Colours.lightGrey,
              ),
              ListTile(
                title: Text('Senarai JBIM Didaftarkan'),
                leading: Icon(Icons.people_outline, color: Colours.darkGrey,),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserBookingResultPage(
                      pickedDate: '',
                      pickedTime: '',
                      hospitalName: '',
                      preferredLanguage: '',
                      isViewOnly: true,
                    )),
                  );
                },
              )
            ],
          ),
        ),
        body: showLoadingAnimation
            ? Center(child: CircularProgressIndicator())
            : PageView(
                physics: NeverScrollableScrollPhysics(),
                children: _pages,
                controller: pageController,
                onPageChanged: onPageChanged,
              ),
        bottomNavigationBar: showLoadingAnimation ? SizedBox.shrink() : BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            onTap: (int index) {
              pageController.jumpToPage(index);
            },
            currentIndex: _currentPageIndex,
            backgroundColor: widget.isSLI ? Colours.orange : Colours.blue,
            selectedItemColor: widget.isSLI ? Colours.darkGrey : Colours.darkBlue,
            unselectedItemColor: Colors.white,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.search, size: Dimensions.d_30),
                  label: 'Permintaan'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today, size: Dimensions.d_30),
                  label: 'Janji Temu'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history, size: Dimensions.d_30),
                  label: 'Transaksi'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle, size: Dimensions.d_30),
                  label: 'Profil',)
            ]),
      ),
    );
  }
}
