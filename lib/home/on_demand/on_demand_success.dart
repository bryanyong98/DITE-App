import 'package:flutter/material.dart';
import 'package:heard/api/chat_item.dart';
import 'package:heard/api/on_demand_status.dart';
import 'package:heard/constants.dart';
import 'package:heard/firebase_services/auth_service.dart';
import 'package:heard/http_services/on_demand_services.dart';
import 'package:heard/widgets/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:heard/video_chat_components/call.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:heard/chat_service/chatPage.dart';
import 'package:heard/http_services/chat_services.dart';
import 'package:wakelock/wakelock.dart';

class OnDemandSuccessPage extends StatefulWidget {
  final Function onCancelClick;
  final bool isSLI;
  final OnDemandStatus onDemandStatus;

  OnDemandSuccessPage(
      {this.onCancelClick, this.onDemandStatus, this.isSLI = false});

  @override
  _OnDemandSuccessPageState createState() => _OnDemandSuccessPageState();
}

class _OnDemandSuccessPageState extends State<OnDemandSuccessPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  final double paddingLR = Dimensions.d_20;
  String authToken;
  OnDemandStatus onDemandStatus;

  @override
  void initState() {
    super.initState();
    getOnDemandStatus();
  }

  String getVideoCallRoomID() {
    Details details = onDemandStatus.details;

    // get the unique two party on demand ID from on demand status object
    String onDemandID = details.onDemandId;

    print("Video call on demand ID: $onDemandID");
    return onDemandID;
  }

  // This method is to retrieve the person's ID that the user is chatting to.
  String getCounterpartID() {
    Details details = onDemandStatus.details;
    String counterpartID;

    if (widget.isSLI) {
      counterpartID = details.uid;
    }

    // if the current holder is not SLI, the opposite user must be one.
    else {
      counterpartID = details.sliID;
    }

    return counterpartID;
  }

  void getOnDemandStatus() async {
    String authTokenString = await AuthService.getToken();
    setState(() {
      authToken = authTokenString;
      onDemandStatus = widget.onDemandStatus;
    });
  }

  void _onRefresh() async {
    authToken = await AuthService.getToken();

    OnDemandStatus status = await OnDemandServices()
        .getOnDemandStatus(isSLI: widget.isSLI, headerToken: authToken);

    if (status.status != 'ongoing' && widget.isSLI == true) {
      widget.onCancelClick();
    }
    setState(() {
      onDemandStatus = status;
    });
    if (status == null) {
      _refreshController.refreshFailed();
    } else {
      _refreshController.refreshCompleted();
    }

    print(onDemandStatus.details.userName);
    print(onDemandStatus.details.sliName);
  }

  @override
  Widget build(BuildContext context) {
    return onDemandStatus == null
        ? Container()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              enablePullDown: true,
              header: ClassicHeader(),
              child: ListView(
                children: [
                  Padding(
                      padding: Paddings.horizontal_20,
                      child: Column(
                        children: <Widget>[
                          SizedBox(height: Dimensions.d_15),
                          Row(children: <Widget>[
                            SizedBox(
                              height: Dimensions.d_25,
                              child: Image(
                                  image: AssetImage('images/successTick.png')),
                            ),
                            SizedBox(
                              width: Dimensions.d_10,
                            ),
                            Text("Berpasangan dilengkapkan",
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold))
                          ]),
                          SizedBox(height: Dimensions.d_20),
                          CircleAvatar(
                            backgroundColor: Colours.lightGrey,
                            radius: Dimensions.d_65,
                            child: widget.isSLI
                                ? onDemandStatus.details.userProfilePicture ==
                                        null
                                    ? Image(
                                        image: AssetImage('images/avatar.png'))
                                    : GetCachedNetworkImage(
                                        profilePicture: onDemandStatus
                                            .details.userProfilePicture,
                                        authToken: authToken,
                                        dimensions: Dimensions.d_120,)
                                : onDemandStatus.details.sliProfilePicture ==
                                        null
                                    ? Image(
                                        image: AssetImage('images/avatar.png'))
                                    : GetCachedNetworkImage(
                                        profilePicture: onDemandStatus
                                            .details.sliProfilePicture,
                                        authToken: authToken,
                                        dimensions: Dimensions.d_120,),
                          ),
                          SizedBox(height: Dimensions.d_15),
                          Text(
                              "${widget.isSLI ? onDemandStatus.details.patientName : onDemandStatus.details.sliName}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: Dimensions.d_25)),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.d_45,
                                  vertical: Dimensions.d_15),
                              child: (widget.isSLI)
                                  ? Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: Dimensions.d_10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text('Nombor Telefon'),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  ': ${onDemandStatus.details.userPhone}',
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: Dimensions.d_10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text('Nota'),
                                              ),
                                              Expanded(
                                                child: Text(
                                                    ': ${onDemandStatus.details.note}'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: Dimensions.d_10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text('Jantina'),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  ': ${onDemandStatus.details.sliGender == 'male' ? 'Lelaki' : 'Perempuan'}',
                                                  textAlign: TextAlign.left,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: Dimensions.d_10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text('Penerangan'),
                                              ),
                                              Expanded(
                                                child: Text(
                                                    ': ${this.onDemandStatus.details.sliDesc}'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
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
                                                            width:
                                                                Dimensions.d_3,
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
            ),
            bottomNavigationBar: widget.isSLI
                ? SizedBox.shrink()
                : UserButton(
                    text: 'Batal Berpasangan',
                    padding: EdgeInsets.all(Dimensions.d_30),
                    color: Colours.cancel,
                    onClick: () {
                      OnDemandServices()
                          .endOnDemandRequest(headerToken: authToken);
                      widget.onCancelClick();
                    }),
          );
  }

  // this will trigger a call to the api chat/enter
  void onTapMessage() async {
    debugPrint("Message is tapped");

    String counterpartID = getCounterpartID();

    // call the api to chat/enter
    ChatItem chatSessionInfo = await ChatServices().enterChatRoom(
        headerToken: authToken,
        counterpartID: counterpartID,
        isSLI: widget.isSLI);

    if (chatSessionInfo != null) {
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(
                    chatRoomID: chatSessionInfo.chatroomId,
                    counterpartName: widget.isSLI
                        ? chatSessionInfo.userName
                        : chatSessionInfo.sliName,
                    counterpartPic: widget.isSLI
                        ? onDemandStatus.details.userProfilePicture
                        : onDemandStatus.details.sliProfilePicture,
                    isSLI: widget.isSLI,
                    fromChatHistoryPage: false,
                  )));
    }
  }

  void onTapVideo() async {
    String onDemandID = getVideoCallRoomID();
    debugPrint("Video is tapped");

    await _handleCameraAndMic();

    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CallPage(
            channelName: onDemandID,
          ),
        ));

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
