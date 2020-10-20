import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heard/constants.dart';
import 'package:heard/chat_service/chatPage.dart';
import 'package:heard/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:heard/http_services/chat_services.dart';
import 'package:heard/api/chat_item.dart';
import 'package:heard/firebase_services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

auth.User loggedInUser ;

class ChatHomeScreen extends StatefulWidget {


  @override
  _ChatHomeScreenState createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {

//  final List<String> entries = <String>['Bryan Yong', 'James Chadwick', 'Ariana Grande', 'Taylor Swift', 'Bruno Mars', 'Shawn Mendes', 'Emma Watson', 'James Bond'];
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  bool isSLI = false ;
  String authToken;
  List<ChatItem> entries = []; // give an initial value to prevent null error on app starting
  String profilePicture;


  @override
  void initState() {
    super.initState();
    setSLI();
    getCurrentUser();
    getUserChatList();
  }

  void setSLI() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isSLI = preferences.getBool('isSLI');

    });
  }

  void getCurrentUser() async{

    try{
      final user = _auth.currentUser;

      if (user != null){
        loggedInUser = user ;
        print('hello');
        print(loggedInUser.displayName);
      }
    }
    catch(e){
      print(e);
    }
  }

  // retrieve the user's personal chat list based on chat history
  void getUserChatList() async{

    authToken = await AuthService.getToken();

    List<ChatItem> chatList = await ChatServices().getChatRoomList(
        isSLI: isSLI, headerToken: authToken);

    // save the result to the defined state variable.
    setState(() {
      entries = chatList;
    });

    if (chatList == null){
      print('Chat list retrieval failed.');
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text('Mesej', style: GoogleFonts.lato(
              fontSize: FontSizes.mainTitle,
              fontWeight: FontWeight.bold,
            ),),
            centerTitle: true,
            backgroundColor: isSLI ? Colours.orange : Colours.blue,
          ),

          body: Container(
            child: Column(

                  children: <Widget>[

                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: entries.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (isSLI) {
                            profilePicture = entries[index].userProfilePicture;
                          }
                          else {
                            profilePicture = entries[index].sliProfilePicture;
                          }
                          return ListTile(
                                  onTap: (){

                                    // direct the user to the designated chat page
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ChatScreen(
                                                chatRoomID: entries[index].chatroomId,
                                                counterpartName: isSLI ? entries[index].userName : entries[index].sliName,
                                                counterpartPic: "No picture",
                                                fromChatHistoryPage: true,

                                          ),
                                        )
                                      );
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: Colours.lightGrey,
                                    radius: Dimensions.d_35,
                                    child: profilePicture == null ? Image(
                                      image: AssetImage('images/avatar.png'),
                                    ) : GetCachedNetworkImage(
                                      profilePicture: profilePicture,
                                      authToken: authToken,
                                      dimensions: Dimensions.d_55,
                                    ),
                                  ),


                                  title: isSLI ?
                                      Text(
                                        '${entries[index].userName}',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      )

                                      :

                                      Text(
                                        '${entries[index].sliName}',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),

                                  subtitle: Text('Available'),

                                );
                        },
                        separatorBuilder: (BuildContext context, int index) => const Divider(),
                      ),
                    ),

                  ],

            ),
          ),

      ),
    );

  }
}
