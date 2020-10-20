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

final _fireStore = FirebaseFirestore.instance;



// need to modify from here ----
class MessageStream extends StatelessWidget {

  final String chatRoomID ;
  final bool isSLI ;

  MessageStream({ this.chatRoomID, this.isSLI});


  bool checkIsSLI(String userType){
    bool checkforSLI = false ;

    if (userType == "sli"){
      checkforSLI = true;
    }

    return checkforSLI;
  }



  @override
  Widget build(BuildContext context) {

    // errors are caused here.
    return StreamBuilder<QuerySnapshot>(
      stream  : _fireStore.collection('chatrooms').doc(chatRoomID).collection('chat').orderBy("datetime", descending: true).snapshots(),
      builder : (context, snapshot){

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }

        final messages = snapshot.data.docs ;
        List<MessageBubble> messageBubbles = [] ;
        for (var message in messages){

          final messageText   = message.data()['message'];
          final messageType   = message.data()['mimetype'];
          final messageSender = message.data()['sender'];
          final messageTime   = message.data()['datetime'].toString();

          final currentSender = checkIsSLI(message.data()['sender']);



          final messageBubble = MessageBubble(
            dateTime: messageTime,
            text:     messageText,
            type:     messageType,
            isMe:     currentSender == isSLI,
            sender:   messageSender,

          );

          Text('$messageText from Ali',
            style: TextStyle(
              fontSize: 50.0,
            ),
          );
          messageBubbles.add(messageBubble);
        }


        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 20.0
            ),
            children: messageBubbles,
          ),
        );

      },
    );
  }
}