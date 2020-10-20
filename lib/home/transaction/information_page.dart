import 'package:flutter/material.dart';
import 'package:heard/api/transaction.dart';
import 'package:heard/constants.dart';
import 'package:heard/firebase_services/auth_service.dart';
import 'package:heard/http_services/booking_services.dart';
import 'package:heard/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:heard/video_chat_components/call.dart';
import 'package:heard/chat_service/chatPage.dart';
import 'package:heard/http_services/chat_services.dart';
import 'package:heard/api/chat_item.dart';
import 'package:wakelock/wakelock.dart';

class InformationPage extends StatefulWidget {
  final Function onCancelClick;
  final String profilePic;
  final bool isSLI;
  final Transaction transaction;

  InformationPage(
      {this.onCancelClick,
      this.profilePic,
      this.transaction,
      this.isSLI = false});

  @override
  _InformationPageState createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final double paddingLR = Dimensions.d_20;
  String authToken;
  Transaction transaction;

  @override
  void initState() {
    super.initState();
    getOnDemandStatus();
  }

  void getOnDemandStatus() async {
    String authTokenString = await AuthService.getToken();
    setState(() {
      authToken = authTokenString;
      transaction = widget.transaction;
    });
  }

  // This method is to retrieve the person's ID that the user is chatting to.
  String getCounterpartID(){

    String counterpartID ;

    if (widget.isSLI){
      counterpartID = transaction.uid;
    }

    // if the current holder is not SLI, the opposite user must be one.
    else {
      counterpartID = transaction.sliId;
    }

    return  counterpartID;
  }


  void confirmationModal({String keyword, Function onClick}) {
    popUpDialog(
        context: context,
        isSLI: widget.isSLI,
        header: 'Pengesahan',
        content: Text(
          'Adakah Anda Pasti Nak $keyword Tempahan?',
          textAlign: TextAlign.left,
          style: TextStyle(color: Colours.darkGrey, fontSize: FontSizes.normal),
        ),
        buttonText: 'Pasti',
        onClick: () {
          Navigator.pop(context);
          onClick();
        });
  }

  Widget cancelBookingButton() {
    return UserButton(
        text: 'Batal Tempahan',
        padding: EdgeInsets.symmetric(horizontal: Dimensions.d_35),
        color: Colours.cancel,
        onClick: () async {
          confirmationModal(
              keyword: 'Batalkan',
              onClick: () async {
                showLoadingAnimation(context: context);
                await BookingServices().cancelBooking(headerToken: authToken,
                    bookingID: transaction.bookingId);
                Navigator.pop(context);
                widget.onCancelClick();
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return transaction == null
        ? Container()
        : SafeArea(
          child: Scaffold(
              backgroundColor: Colours.white,
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back
                  ),
                  onPressed: () {
                    widget.onCancelClick();
                  },
                ),
                title: Text(
                  'Mengurus Tempahan',
                  style: GoogleFonts.lato(
                    fontSize: FontSizes.mainTitle,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                backgroundColor: widget.isSLI ? Colours.orange : Colours.blue,
              ),
              body: ListView(
                children: [
                  Padding(
                      padding: Paddings.horizontal_20,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: Dimensions.d_35),
                          CircleAvatar(
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
                          SizedBox(height: Dimensions.d_15),
                          Text(
                              "${widget.isSLI ? transaction.userName : transaction.sliName}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimensions.d_25)),
                          SizedBox(height: Dimensions.d_35),
                          Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(
                                          width: Dimensions.d_3,
                                          color: Colours.grey),
                                      bottom: BorderSide(
                                          width: Dimensions.d_3,
                                          color: Colours.grey))),
                              child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: Dimensions.d_15),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: SizedBox(
                                            height: Dimensions.d_55,
                                            child: FloatingActionButton(
                                              heroTag: null,
                                              backgroundColor: widget.isSLI
                                                  ? Colours.orange
                                                  : Colours.blue,
                                              onPressed: onTapMessage,
                                              elevation: Dimensions.d_0,
                                              child: Icon(
                                                Icons.message,
                                                size: Dimensions.d_30,
                                              ),
                                            )),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                            height: Dimensions.d_55,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    border: Border(
                                                        left: BorderSide(
                                                            width: Dimensions.d_3,
                                                            color:
                                                                Colours.grey))),
                                                child: FloatingActionButton(
                                                  heroTag: null,
                                                  backgroundColor: widget.isSLI
                                                      ? Colours.orange
                                                      : Colours.blue,
                                                  onPressed: onTapVideo,
                                                  elevation: Dimensions.d_0,
                                                  child: Icon(
                                                    Icons.videocam,
                                                    size: Dimensions.d_35,
                                                  ),
                                                ))),
                                      ),
                                    ],
                                  )))
                        ],
                      )),
                ],
              ),
              bottomNavigationBar: widget.isSLI
                  ? SizedBox.shrink()
                  : (transaction.status == 'accepted') ? Container(
                    height: Dimensions.d_100 * 1.8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        cancelBookingButton(),
                        UserButton(
                            text: 'Tamat Tempahan',
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.d_35, vertical: Dimensions.d_25),
                            color: Colours.cancel,
                            onClick: () async {
                              confirmationModal(
                                  keyword: 'Tamatkan',
                                  onClick: () async {
                                    showLoadingAnimation(context: context);
                                    await BookingServices().finishBooking(headerToken: authToken,
                                        bookingID: transaction.bookingId);
                                    Navigator.pop(context);
                                    widget.onCancelClick();
                                  });
                            }),
                      ],
                    ),
                  ) : Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.d_25),
                    child: cancelBookingButton(),
                  ),
            ),
        );
  }

  void onTapMessage() async {
    debugPrint("Message is tapped");

    String counterpartID = getCounterpartID();

    // call the api to chat/enter
    ChatItem chatSessionInfo = await ChatServices().enterChatRoom(
        headerToken: authToken, counterpartID: counterpartID, isSLI: widget.isSLI);

    if (chatSessionInfo != null){
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>  ChatScreen(
                chatRoomID: chatSessionInfo.chatroomId,
                counterpartName: widget.isSLI ? chatSessionInfo.userName : chatSessionInfo.sliName,
                counterpartPic: "No picture",
                isSLI:           widget.isSLI,
                fromChatHistoryPage: false,


              )
          )
      );
    }
  }

  void onTapVideo() async {
    String onDemandID = transaction.bookingId;
    debugPrint("Video is tapped");

    await _handleCameraAndMic();

    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>  CallPage(
            channelName: onDemandID,
          ),
        )
    );
    bool wakeLockEnabled = await Wakelock.enabled;
    if (wakeLockEnabled) {
      Wakelock.disable();
    }
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }
}
