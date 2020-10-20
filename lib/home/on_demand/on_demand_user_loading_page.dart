import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heard/api/user.dart';
import 'package:heard/constants.dart';
import 'package:heard/firebase_services/auth_service.dart';
import 'package:heard/firebase_services/fcm.dart';
import 'package:heard/widgets/loading_screen.dart';
import 'package:heard/widgets/widgets.dart';
import 'package:heard/http_services/on_demand_services.dart';
import 'package:heard/home/on_demand/data_structure/OnDemandInputs.dart';
import 'package:heard/http_services/user_services.dart';

class OnDemandUserLoadingPage extends StatefulWidget {
  OnDemandUserLoadingPage(
      {Key key,
      @required this.onCancelClick,
      @required this.onSearchComplete,
      @required this.onDemandInputs,
      this.reNavigation = false})
      : super(key: key);
  final Function onCancelClick;
  final Function onSearchComplete;
  final OnDemandInputs onDemandInputs;
  final bool reNavigation;

  @override
  OnDemandUserLoadingPageState createState() =>
      new OnDemandUserLoadingPageState();
}

class OnDemandUserLoadingPageState extends State<OnDemandUserLoadingPage> {
  String _authToken;
  int _countdownValue = 60;
  Timer _countdownTimer;
  Widget inputWidget;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initializeInputWidget();
    getAuthToken().whenComplete(() {
      if (!widget.reNavigation) {
        onDemandRequest();
      }
      subscribeFCMListener();
      startTimer();
    });
  }

  void initializeInputWidget() {
    setState(() {
      inputWidget = Card(
          margin: EdgeInsets.only(
            top: Dimensions.d_25,
            left: Dimensions.d_25,
            right: Dimensions.d_25,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.d_10),
          ),
          elevation: Dimensions.d_5,
          child: Padding(
              padding: EdgeInsets.all(Dimensions.d_10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Perincian Permintaan'),
                    Divider(thickness: Dimensions.d_2),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Nama Hospital:'),
                          Text('${widget.onDemandInputs.hospital.text}')
                        ]),
                    Padding(padding: EdgeInsets.all(Dimensions.d_2)),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Jabatan Hospital:'),
                          Text('${widget.onDemandInputs.department.text}')
                        ]),
                    Padding(padding: EdgeInsets.all(Dimensions.d_2)),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Jantina:'),
                          Text(
                              '${widget.onDemandInputs.genderType.toString().split('.').last == 'male' ? 'Lelaki' : 'Perempuan'}')
                        ]),
                    Padding(padding: EdgeInsets.all(Dimensions.d_2)),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Kecemasan:'),
                          Text(
                              '${widget.onDemandInputs.isEmergency ? 'Ya' : 'Tidak'}')
                        ]),
                    Padding(padding: EdgeInsets.all(Dimensions.d_2)),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Permintaan bagi orang lain:'),
                          Text(
                              '${widget.onDemandInputs.isBookingForOthers ? 'Ya' : 'Tidak'}')
                        ]),
                    Padding(padding: EdgeInsets.all(Dimensions.d_2)),
                    widget.onDemandInputs.isBookingForOthers
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                                Text('Name Pesakit:'),
                                Text(
                                    '${widget.onDemandInputs.patientName.text}')
                              ])
                        : SizedBox.shrink(),
                    widget.onDemandInputs.isBookingForOthers
                        ? Padding(padding: EdgeInsets.all(Dimensions.d_2))
                        : SizedBox.shrink(),
                    widget.onDemandInputs.isBookingForOthers
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Text('Note kepada JBIM:'),
                                Flexible(
                                    child: Padding(
                                        padding: EdgeInsets.only(
                                            left: Dimensions.d_15),
                                        child: Text(
                                            '${widget.onDemandInputs.noteToSLI.text.isEmpty ? 'Tiada' : widget.onDemandInputs.noteToSLI.text}')))
                              ])
                        : SizedBox.shrink(),
                    widget.onDemandInputs.isBookingForOthers
                        ? Padding(padding: EdgeInsets.all(Dimensions.d_2))
                        : SizedBox.shrink(),
                  ])));
    });
  }

  @override
  void dispose() {
    super.dispose();
    _countdownTimer?.cancel();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _countdownTimer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_countdownValue < 1) {
            OnDemandServices().cancelOnDemandRequest(headerToken: _authToken);
            widget.onCancelClick(message: "No response to request");
            _countdownTimer.cancel();
          } else {
            _countdownValue = _countdownValue - 1;
          }
        },
      ),
    );
  }

  Future<void> getAuthToken() async {
    String _authTokenString = await AuthService.getToken();
    setState(() {
      _authToken = _authTokenString;
    });
  }

  void subscribeFCMListener() {
    StreamSubscription<Map<String, dynamic>> fcmListener;
    fcmListener = FCM.onFcmMessage.listen((event) async {
      if (event['data']['type'] == 'ondemand-accepted') {
        widget.onSearchComplete();
        fcmListener.cancel();
      }
    });
  }

  void onDemandRequest() async {
    await getAuthToken();
    if (widget.onDemandInputs.patientName.text.isEmpty) {
      User _user = await UserServices().getUser(headerToken: _authToken);
      String _username = _user.name.text;
      widget.onDemandInputs.patientName =
          TextEditingController.fromValue(TextEditingValue(text: _username));
    }
    await OnDemandServices().makeOnDemandRequest(
        headerToken: _authToken, onDemandInputs: widget.onDemandInputs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colours.white,
      body: Scrollbar(
          controller: _scrollController,
          isAlwaysShown: true,
          child: SingleChildScrollView(
              controller: _scrollController,
              child: LoadingScreen(topWidget: inputWidget))),
      bottomNavigationBar: UserButton(
          text: 'Batal',
          padding: EdgeInsets.all(Dimensions.d_30),
          color: Colours.cancel,
          onClick: () {
            OnDemandServices().cancelOnDemandRequest(headerToken: _authToken);
            widget.onCancelClick();
          }),
    );
  }
}
