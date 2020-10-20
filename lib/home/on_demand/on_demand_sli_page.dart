import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:heard/api/on_demand_request.dart';
import 'package:heard/api/on_demand_status.dart';
import 'package:heard/constants.dart';
import 'package:heard/firebase_services/auth_service.dart';
import 'package:heard/home/on_demand/on_demand_success.dart';
import 'package:heard/http_services/on_demand_services.dart';
import 'package:heard/widgets/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class OnDemandSLIPage extends StatefulWidget {
  final List<OnDemandRequest> onDemandRequests;
  final OnDemandStatus status;

  OnDemandSLIPage({this.onDemandRequests, this.status});

  @override
  _OnDemandSLIPageState createState() => _OnDemandSLIPageState();
}

class _OnDemandSLIPageState extends State<OnDemandSLIPage>
    with AutomaticKeepAliveClientMixin {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<OnDemandRequest> onDemandRequests;
  String authToken;
  bool showPairingComplete = false;
  OnDemandStatus onDemandStatus;

  @override
  void initState() {
    super.initState();
    getOnDemandRequests();
  }

  Future<void> _onRefresh() async {
    authToken = await AuthService.getToken();

    List<OnDemandRequest> allRequests =
    await OnDemandServices().getAllRequests(headerToken: authToken);
    setState(() {
      onDemandRequests = allRequests;
    });
    print('Refreshed all on-demand requests ...');
    print('Updated Request: $onDemandRequests and length of ${onDemandRequests
        .length}');
    if (onDemandRequests == null) {
      _refreshController.refreshFailed();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  void getOnDemandRequests() async {
    String authTokenString = await AuthService.getToken();
    if (widget.status.status == 'ongoing') {
      showPairingComplete = true;
    }
    setState(() {
      authToken = authTokenString;
      onDemandStatus = widget.status;
      onDemandRequests = widget.onDemandRequests;
    });
    print('Set state complete! on-demand: $onDemandRequests}');
  }

  void confirmRequest({int index}) {
    popUpDialog(
        context: context,
        isSLI: true,
        header: 'Pengesahan',
        content: Text(
          'Adakah anda pasti?',
          textAlign: TextAlign.left,
          style: TextStyle(color: Colours.darkGrey, fontSize: FontSizes.normal),
        ),
        buttonText: 'Teruskan',
        onClick: () async {
          Navigator.pop(context);
          showLoadingAnimation(context: context);
          print('on demand id: ${onDemandRequests[index].onDemandId} ${onDemandRequests[index].patientName} index: $index');
          bool acceptanceResult = await OnDemandServices()
              .acceptOnDemandRequest(
                  headerToken: authToken,
                  onDemandID: onDemandRequests[index].onDemandId);

          if (acceptanceResult) {
            OnDemandStatus status = await OnDemandServices()
                .getOnDemandStatus(headerToken: authToken, isSLI: true);
            setState(() {
              showPairingComplete = true;
              onDemandStatus = status;
            });
          } else {
            confirmRequestError();
          }
          Navigator.pop(context);
        });
  }

  void confirmRequestError() {
    popUpDialog(
        context: context,
        isSLI: true,
        header: 'Amaran',
        touchToDismiss: false,
        content: Text(
          'Gagal Menerima Permintaan',
          textAlign: TextAlign.left,
          style: TextStyle(color: Colours.darkGrey, fontSize: FontSizes.normal),
        ),
        onClick: () {
          Navigator.pop(context);
        });
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
                '${onDemandRequests[index].patientName}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${onDemandRequests[index].hospital}',
                    style: TextStyle(color: Colours.darkGrey),
                  ),
                  Text(
                    '(${onDemandRequests[index].hospitalDepartment})',
                    style: TextStyle(color: Colours.darkGrey),
                  ),
                  onDemandRequests[index].emergency
                      ? Text(
                          '*Kecemasan',
                          style: TextStyle(color: Colours.fail),
                        )
                      : SizedBox.shrink(),
                ],
              ),
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
                      onDemandRequests[index].note,
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
    return showPairingComplete
        ? OnDemandSuccessPage(
            isSLI: true,
            onDemandStatus: onDemandStatus,
            onCancelClick: () async {
              setState(() {
                showPairingComplete = false;
              });
              showLoadingAnimation(context: context);
              await _onRefresh();
              Navigator.pop(context);
            },
          )
        : Scaffold(
          backgroundColor: Colours.white,
          body: SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            enablePullDown: true,
            header: ClassicHeader(),
            child: (onDemandRequests == null)
                ? Container()
                : (onDemandRequests.length == 0)
                    ? Center(
                        child: Text('Tiada Permintaan Pada Masa Ini'),
                      )
                    : ListView(
                        children: <Widget>[
                          GreyTitleBar(
                            title: 'Permintaan Aktif',
                            trailing: Text(
                              '*Leret ke kiri untuk pengesahan',
                              style: TextStyle(
                                  fontSize: FontSizes.tinyText,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          ListView.builder(
                            scrollDirection: Axis.vertical,
                            controller: ScrollController(),
                            shrinkWrap: true,
                            itemCount: onDemandRequests.length,
                            itemBuilder: (context, index) {
                              return SlidableListTile(
                                profilePicture: onDemandRequests[index].userProfilePicture == null ? null : GetCachedNetworkImage(
                                  profilePicture: onDemandRequests[index].userProfilePicture,
                                  authToken: authToken,
                                  dimensions: Dimensions.d_55,
                                ),
                                tileColour:
                                    onDemandRequests[index].emergency
                                        ? Colours.lightOrange
                                        : Colours.white,
                                title: Text(
                                  '${onDemandRequests[index].patientName}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${onDemandRequests[index].hospital}',
                                      style: TextStyle(
                                          color: Colours.darkGrey),
                                    ),
                                    onDemandRequests[index].emergency
                                        ? Text(
                                            'KECEMASAN',
                                            style: TextStyle(
                                                color: Colours.fail,
                                                fontSize:
                                                    FontSizes.biggerText),
                                          )
                                        : SizedBox.shrink(),
                                  ],
                                ),
                                slideLeftActionFunctions:
                                    SlideActionBuilderDelegate(
                                        actionCount: 1,
                                        builder: (context, sliderIndex, animation,
                                            renderingMode) {
                                          return IconSlideAction(
                                              caption: 'Terima',
                                              color: Colours.accept,
                                              icon: Icons.done,
                                              onTap: () {
                                                confirmRequest(
                                                    index: index);
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
