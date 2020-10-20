import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:heard/api/booking_request.dart';
import 'package:heard/constants.dart';
import 'package:heard/firebase_services/auth_service.dart';
import 'package:heard/http_services/booking_services.dart';
import 'package:heard/widgets/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class SLIBookingPage extends StatefulWidget {
  @override
  _SLIBookingPageState createState() => _SLIBookingPageState();
}

class _SLIBookingPageState extends State<SLIBookingPage>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<BookingRequest> bookingRequests;
  String authToken;

  List<UserInfoTemp> mockInfoList = [
    UserInfoTemp().addInfo(
        name: 'James Cooper',
        hospital: 'Hospital Sg Buloh',
        requestedDateTime: '20-03-2020',
        requestedTime: '3.00pm'),
    UserInfoTemp().addInfo(
        name: 'Kyle Jenner',
        hospital: 'Hospital Sg Long',
        requestedDateTime: '28-06-2020',
        requestedTime: '7.00pm'),
    UserInfoTemp().addInfo(
        name: 'Kim Possible',
        hospital: 'Hospital Sarawak',
        requestedDateTime: '02-04-2020',
        requestedTime: '9.00pm'),
    UserInfoTemp().addInfo(
        name: 'Arthur Knight',
        hospital: 'Hospital Kuala Lumpur',
        requestedDateTime: '20-03-2020',
        requestedTime: '11.00pm'),
    UserInfoTemp().addInfo(
        name: 'John Monash',
        hospital: 'Hospital Selangor',
        requestedDateTime: '20-03-2020',
        requestedTime: '10.00pm'),
    UserInfoTemp().addInfo(
        name: 'Michael Lee',
        hospital: 'Hospital Pahang',
        requestedDateTime: '20-03-2020',
        requestedTime: '9.00pm'),
    UserInfoTemp().addInfo(
        name: 'Takashi Hiro',
        hospital: 'Hospital Sabah',
        requestedDateTime: '20-03-2020',
        requestedTime: '8.00pm'),
    UserInfoTemp().addInfo(
        name: 'James Cooper',
        hospital: 'Hospital Pulau Pinang',
        requestedDateTime: '20-03-2020',
        requestedTime: '12.00pm'),
    UserInfoTemp().addInfo(
        name: 'James Cooper',
        hospital: 'Hospital Seremban',
        requestedDateTime: '20-03-2020',
        requestedTime: '1.00pm'),
  ];

  @override
  void initState() {
    super.initState();
    initializeBooking();
  }

  void _onRefresh() async {
    /// added get token again because token constantly changes
    authToken = await AuthService.getToken();
    List<BookingRequest> allRequests =
        await BookingServices().getAllCurrentRequests(headerToken: authToken);
    setState(() {
      bookingRequests = allRequests;
    });
    print('Refreshing all booking requests ...');
    print(
        'Updated Request: $bookingRequests and length of ${bookingRequests.length}');
    if (bookingRequests == null) {
      _refreshController.refreshFailed();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  void initializeBooking() async {
    String authTokenString = await AuthService.getToken();
    List<BookingRequest> allRequests = await BookingServices().getAllCurrentRequests(headerToken: authTokenString);
    setState(() {
      authToken = authTokenString;
      bookingRequests = allRequests;
    });
    print('Set state complete! booking: $bookingRequests}');
  }

  Future<bool> confirmationModal(
      {BuildContext context, int index, bool isAcceptBooking}) async {
    bool response = false;
    bool hasClicked = false;
    await popUpDialog(
        context: context,
        isSLI: true,
        header: 'Pengesahan',
        content: Text(
          'Adakah Anda Pasti ${isAcceptBooking ? 'Terima' : 'Tolak'}?',
          textAlign: TextAlign.left,
          style: TextStyle(color: Colours.darkGrey, fontSize: FontSizes.normal),
        ),
        buttonText: 'Teruskan',
        onClick: () async {
          Navigator.pop(context);
          hasClicked = true;
        });
    if (hasClicked) {
      response = await postBookingResponse(
          index: index, isAcceptBooking: isAcceptBooking);
    }
    return response;
  }

  Future<bool> postBookingResponse({int index, bool isAcceptBooking}) async {
    bool toRemoveBooking = false;

    /// showing loading screen when post response to backend
    showLoadingAnimation(context: context);
    bool responseResult = await BookingServices().postSLIResponse(
        headerToken: authToken,
        bookingID: bookingRequests[index].bookingId,
        isAcceptBooking: isAcceptBooking);
    Navigator.pop(context);

    if (responseResult) {
      toRemoveBooking = true;
      if (isAcceptBooking) {
        await confirmRequestModal(
            isAcceptBooking: isAcceptBooking, isSuccessAccept: true);
      }
    } else {
      await confirmRequestModal(
          isAcceptBooking: isAcceptBooking, isSuccessAccept: false);
    }

    return toRemoveBooking;
  }

  Future<void> confirmRequestModal(
      {bool isAcceptBooking, bool isSuccessAccept}) async {
    await popUpDialog(
        context: context,
        isSLI: true,
        header: isSuccessAccept ? 'Pengesahan' : 'Amaran',
        touchToDismiss: false,
        content: Text(
          isSuccessAccept
              ? 'Berjaya Menerima Permintaan!'
              : 'Gagal ${isAcceptBooking ? 'Menerima' : 'Menolak'} Permintaan',
          textAlign: TextAlign.left,
          style: TextStyle(color: Colours.darkGrey, fontSize: FontSizes.normal),
        ),
        onClick: () {
          Navigator.pop(context);
        });
  }

  Widget getUserDetails({int index}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${bookingRequests[index].hospitalName}',
        ),
        Text(
          'Tarikh: ${bookingRequests[index].date}',
          style: TextStyle(color: Colours.darkGrey),
        ),
        Text(
          'Masa: ${bookingRequests[index].time}',
          style: TextStyle(color: Colours.darkGrey),
        ),
      ],
    );
  }

  Widget getListItem({int index}) {
    return SlidableListTile(
      profilePicture: bookingRequests[index].userProfilePicture == null ? null : GetCachedNetworkImage(
        profilePicture: bookingRequests[index].userProfilePicture,
        authToken: authToken,
        dimensions: Dimensions.d_55,
      ),
      onDismissed: (actionType) {
        setState(() {
          bookingRequests.removeAt(index);
        });
      },
      title: Text(
        '${bookingRequests[index].userName}',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: getUserDetails(index: index),
      slideRightActionFunctions: SlideActionBuilderDelegate(
          actionCount: 1,
          builder: (slideContext, index, animation, renderingMode) {
            return IconSlideAction(
              caption: 'Tolak',
              color: Colours.cancel,
              icon: Icons.cancel,
              onTap: () async {
                SlidableState state = Slidable.of(slideContext);
                bool dismiss = await confirmationModal(
                    context: context, index: index, isAcceptBooking: false);
                if (dismiss) {
                  state.dismiss();
                }
              },
            );
          }),
      slideLeftActionFunctions: SlideActionBuilderDelegate(
          actionCount: 1,
          builder: (context, index, animation, renderingMode) {
            return IconSlideAction(
                caption: 'Terima',
                color: Colours.accept,
                icon: Icons.done,
                onTap: () async {
                  var state = Slidable.of(context);
                  bool dismiss = await confirmationModal(
                      context: context, index: index, isAcceptBooking: true);
                  if (dismiss) {
                    state.dismiss();
                  }
                });
          }),
      onTrailingButtonPress: IconButton(
        icon: Icon(Icons.info_outline),
        color: Colours.orange,
        iconSize: Dimensions.d_30,
        onPressed: () {
          showUserInformation(index: index);
        },
      ),
    );
  }

  void showUserInformation({int index}) {
    popUpDialog(
      context: context,
      isSLI: true,
      height: Dimensions.d_130 * 3.5,
      contentFlexValue: 3,
      onClick: () {
        Navigator.pop(context);
      },
      header: 'Maklumat',
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            flex: 2,
            child: ListTile(
              isThreeLine: true,
              title: Text(
                '${bookingRequests[index].userName}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: getUserDetails(index: index),
            ),
          ),
          Flexible(
            flex: 5,
            child: Padding(
              padding: EdgeInsets.only(top: Dimensions.d_35),
              child: Container(
                  height: Dimensions.d_280,
                  decoration: BoxDecoration(
                      color: Colours.lightGrey,
                      borderRadius:
                      BorderRadius.all(Radius.circular(Dimensions.d_10))),
                  child: ListTile(
                    title: Text(
                      bookingRequests[index].notes,
                      style: TextStyle(fontSize: FontSizes.smallerText),
                    ),
                  )),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colours.white,
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh,
        enablePullDown: true,
        header: ClassicHeader(),
        child: (bookingRequests == null)
            ? Center(child: CircularProgressIndicator())
            : (bookingRequests.length == 0)
                ? Center(
                    child: Text('Tiada Tempahan Pada Masa Ini'),
                  )
                : ListView(
                    children: <Widget>[
                      GreyTitleBar(
                        title: 'Permintaan Tempahan',
                        trailing: Text(
                          '*Leret ke kanan untuk membatalkan tempahan',
                          style: TextStyle(
                              fontSize: FontSizes.tinyText,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      ListView.builder(
                        scrollDirection: Axis.vertical,
                        controller: ScrollController(),
                        shrinkWrap: true,
                        itemCount: bookingRequests.length,
                        itemBuilder: (context, index) {
                          return getListItem(index: index);
                        },
                      )
                    ],
                  ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class UserInfoTemp {
  String patientName;
  String uid;
  String datetime;
  String bookingId = '123456';

  UserInfoTemp addInfo(
      {@required String name,
      @required String hospital,
      @required String requestedDateTime,
      String requestedTime = ''}) {
    UserInfoTemp newPerson = UserInfoTemp();
    newPerson.patientName = name;
    newPerson.uid = hospital;
    newPerson.datetime = requestedDateTime;

    return newPerson;
  }
}
