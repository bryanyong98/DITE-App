import 'package:flutter/material.dart';
import 'package:heard/api/transaction_history.dart';
import 'package:heard/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heard/firebase_services/auth_service.dart';
import 'package:heard/http_services/booking_services.dart';
import 'package:heard/widgets/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HistoryPage extends StatefulWidget {
  final bool isSLI;
  final Function onBackPress;

  HistoryPage({@required this.isSLI, this.onBackPress});

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<TransactionHistory> transactionHistory;
  String authToken;

  void _onRefresh() async {
    /// added get token again because token constantly changes
    String _authToken = await AuthService.getToken();
    List<TransactionHistory> transactions = await BookingServices()
        .getTransactionHistory(headerToken: _authToken, isSLI: widget.isSLI);
    setState(() {
      transactionHistory = transactions;
      authToken = _authToken;
    });
    print('Refreshing all transaction history ... ');
    if (transactionHistory == null) {
      _refreshController.refreshFailed();
    } else {
      _refreshController.refreshCompleted();
    }
  }

  Widget getListItem({TransactionHistory transaction}) {
    return Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.all(Dimensions.d_20),
                isThreeLine: true,
                leading: CircleAvatar(
                  backgroundColor: Colours.lightGrey,
                  radius: Dimensions.d_35,
                  child: transaction.profilePicture == null ? Image(
                    image: AssetImage('images/avatar.png'),
                  ) : GetCachedNetworkImage(
                    profilePicture: transaction.profilePicture,
                    authToken: authToken,
                    dimensions: Dimensions.d_55,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${!widget.isSLI ? 'BIM:' : 'Pesakit:'} ${transaction.counterpartName}',
                      style: TextStyle(
                          color: Colours.black,
                          fontSize: FontSizes.smallerText),
                    ),
                    Text(
                      'Jenis: ${transaction.type == 'booking' ? 'Janji Temu' : 'Tempahan Segera'}',
                      style: TextStyle(
                          color: Colours.black,
                          fontSize: FontSizes.smallerText,
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic),
                    ),
                    Text(
                      'Tarikh: ${transaction.date}',
                      style: TextStyle(
                          color: Colours.black,
                          fontSize: FontSizes.smallerText),
                    ),
                    Text(
                      'Masa: ${transaction.time}',
                      style: TextStyle(
                          color: Colours.black,
                          fontSize: FontSizes.smallerText),
                    ),
                    Row(
                      children: [
                        Text(
                          'Status: ',
                          style: TextStyle(
                              color: Colours.black,
                              fontSize: FontSizes.smallerText),
                        ),
                        Text(
                          '${transaction.status == 'complete' ? 'Tamat' : 'Dibatal'}',
                          style: TextStyle(
                              color: transaction.status == 'complete'
                                  ? Colours.accept
                                  : Colours.cancel,
                              fontSize: FontSizes.smallerText,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                height: Dimensions.d_0,
                thickness: Dimensions.d_3,
                color: Colours.lightGrey,
              )
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    if (transactionHistory == null) {
      _onRefresh();
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colours.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
                Icons.arrow_back
            ),
            onPressed: () {
              widget.onBackPress();
            },
          ),
          title: Text(
            'Sejarah',
            style: GoogleFonts.lato(
              fontSize: FontSizes.mainTitle,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: widget.isSLI ? Colours.orange : Colours.blue,
        ),
        body: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          enablePullDown: true,
          header: ClassicHeader(),
          child: (transactionHistory == null)
              ? Center(child: CircularProgressIndicator(),)
              : (transactionHistory.length == 0)
                  ? Center(
                      child: Text('Tiada Sejarah Transaksi Pada Masa Ini'),
                    )
                  : ListView(
                      children: <Widget>[
                        ListView.builder(
                          scrollDirection: Axis.vertical,
                          controller: ScrollController(),
                          shrinkWrap: true,
                          itemCount: transactionHistory.length,
                          itemBuilder: (context, index) {
                            return getListItem(
                                transaction: transactionHistory[index]);
                          },
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
