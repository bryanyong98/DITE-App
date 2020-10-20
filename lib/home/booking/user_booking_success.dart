import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heard/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:heard/widgets/user_button.dart';

class UserBookingSuccessPage extends StatefulWidget {
  @override
  _UserBookingSuccessPageState createState() => _UserBookingSuccessPageState();
}

class _UserBookingSuccessPageState extends State<UserBookingSuccessPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colours.white,
      appBar: AppBar(
        backgroundColor: Colours.blue,
        leading: SizedBox.shrink(),
        title: Text(
          'Status Tempahan',
          style: GoogleFonts.lato(
            fontSize: FontSizes.mainTitle,
            fontWeight: FontWeight.bold,
            color: Colours.white,
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          SizedBox(
            height: Dimensions.d_35,
          ),
          Center(
            child: SizedBox(
              height: Dimensions.d_200,
              child: Image(
                image: AssetImage('images/bookingSuccessTick.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          SizedBox(
            height: Dimensions.d_35,
          ),
          Center(
            child: Text(
              "Tempahan Dibuat",
              style: TextStyle(
                  fontSize: FontSizes.mainTitle,
                  color: Colours.accept,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.d_35, vertical: Dimensions.d_10),
            child: Card(
              elevation: Dimensions.d_3,
              child: Padding(
                padding: EdgeInsets.all(Dimensions.d_10),
                child: Text(
                  "Anda Boleh Mengurus Tempahan Yang Dibuat Dalam Tab Transaksi",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      // fontSize: FontSizes.tinyText,
                      color: Colours.darkGrey,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: UserButton(
        text: 'Menuju Ke Tab Transaksi',
        color: Colours.blue,
        padding: EdgeInsets.all(Dimensions.d_30),
        onClick: () {
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context, true);
        },
      ),
    );
  }
}
