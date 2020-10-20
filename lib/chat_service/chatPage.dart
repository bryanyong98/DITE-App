import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:heard/chat_service/chatConstants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:heard/chat_service/VideoPlayerWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:heard/constants.dart';
import 'package:heard/chat_service/chathome.dart';
import 'package:heard/http_services/chat_services.dart';
import 'package:heard/firebase_services/auth_service.dart';
import 'package:heard/chat_service/messageBubble.dart';
import 'package:heard/chat_service/messageStream.dart';



auth.User loggedInUser ;


class ChatScreen extends StatefulWidget {

  static const routeName = '/chatPage';
  static String id = 'chat_screen';

  final String chatRoomID;
  final String counterpartName;
  final String counterpartPic;
  final bool isSLI;
  final bool fromChatHistoryPage;


  ChatScreen({this.chatRoomID, this.counterpartName, this.counterpartPic, this.isSLI, this.fromChatHistoryPage  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  // for text inputting usage
  final messageTextController = TextEditingController();
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  String authToken ;

  // To cater for various format of messages
  var messageText ;
  var fileURL ;
  var file ;   /* This is an attachment file */
  var isSLI = false;  // assign a default value


  @override
  void initState() {
    super.initState();
    getCurrentUser();
    setSLI();
    getAuthToken();
  }

  void getAuthToken() async {
    String authTokenString = await AuthService.getToken();
    setState(() {
      authToken = authTokenString;
    });
  }

  void setSLI() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      isSLI = preferences.getBool('isSLI');

      print('check if is SLI');
      print(isSLI);

    });
  }

  void getCurrentUser() async{

    try{
      final user = _auth.currentUser;

      if (user != null){
        loggedInUser = user ;
        print('hello');
        print(loggedInUser.phoneNumber);
      }
    }
    catch(e){
      print(e);
    }

  }


  void sendMessage(String content) async{

    if (content != '')
    {
      // clear the text editing controller
      messageTextController.clear();

      // call the chat/send API
      bool messageSent = await ChatServices().sendChatMessage(
          headerToken: authToken,
          isSLI: isSLI,
          roomID: widget.chatRoomID,
          message: content,
      );

      if (messageSent){
        print('Message sent.');
      }

      else {
        print("Message is not sent");
      }
    }

    else
      print("empty string printed");
  }



  @override
  Widget build(BuildContext context) {

    final ChatHomeScreen args = ModalRoute.of(context).settings.arguments;


    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
//          IconButton(
//              icon: Icon(Icons.close),
//              onPressed: () {
//                //Implement logout functionality
//                messageStream();
//                Navigator.pop(context);
//              }),
        ],
        title: Row(
          children: [
            Text(widget.counterpartName),
          ],
        ),
        backgroundColor: isSLI ? Colours.orange : Colours.blue,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[

            // Create Message Stream, and specify the specific room id to pull the messages
            MessageStream(chatRoomID: widget.chatRoomID,
                          isSLI:      isSLI,
            )
            ,
            Visibility(
              visible: !widget.fromChatHistoryPage,
              child: Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[

                    // The widget for text input
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        onChanged: (value) {
                          //Do something with the user input.
                          messageText = value ;
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),

                    // The add attachment icon for adding other file
                    FlatButton(
                      onPressed: () {
                          debugPrint('Attachment file button clicked');
//                      showModalBottomSheet(
//                          context: context,
//                          builder: (BuildContext bc){
//                            return Container(
//                              child: Wrap(
//                                children: <Widget>[
//                                  ListTile(
//                                    leading: Icon(Icons.image),
//                                    title: Text('Image'),
//                                    onTap: () => showFilePicker(FileType.image),
//                                  ),
//
//                                  ListTile(
//                                    leading: Icon(Icons.videocam),
//                                    title: Text('Video'),
//                                    onTap: () => showFilePicker(FileType.video),
//                                  ),
//
//                                  ListTile(
//                                    leading: Icon(Icons.insert_drive_file),
//                                    title: Text('Document'),
//                                    onTap: () => showFilePicker(FileType.any),
//                                  ),
//                                ],
//                              ),
//                            );
//                          });

                      },
                      child: IconButton(
                          icon : Icon(Icons.attach_file, color: Colors.black,)
                      ),
                    ),

                    FlatButton(
                      onPressed: () {

                        // The code 'filetype.text' means for messageTEXT
                        sendMessage(messageText);

                      },
                      child: IconButton(
                          icon : Icon(Icons.send, color: Colors.black45,)
                      ),

                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





// commented out codes
//  Future<dynamic> uploadFile() async {
//    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
//    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
//    StorageUploadTask uploadTask = reference.putFile(file);
//
//    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
//    var url = storageTaskSnapshot.ref.getDownloadURL();
//
//    return url ;
//
//  }

/*Follow up method to send attachments*/
//  showFilePicker(FileType fileType) async {
//
//    file = await FilePicker.getFile(type: fileType);
//
//    if (file == null) return ;
//
//    // send attachment event function implementation
//    String url = await uploadFile();
//
//    messageText = url;
//    // then, proceed to send this message
//    sendMessage(url, fileType);
//    print(fileType);
//
//    Navigator.pop(context);
//
//  }