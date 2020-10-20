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

// Modify the message bubble to encapsulate different media
// e.g text, image, video, documents
class MessageBubble extends StatelessWidget {
  MessageBubble({this.dateTime, this.text, this.type, this.isMe, this.sender});


  final String text        ;
  final String type        ;
  final bool isMe          ;
  final String sender      ;
  final String dateTime    ;

  /* Method to activate video player */
  void showVideoPlayer(parentContext,String videoUrl) async {
    await showModalBottomSheet(
        context: parentContext,
        builder: (BuildContext bc) {
          return VideoPlayerWidget(videoUrl);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(2.0),
      child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[

            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.70),
              child: Material(
                  borderRadius: isMe ?  BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0) ,
                  )

                      :

                  BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0) ,
                  )
                  ,
                  color: (sender == 'sli') ? Colours.orange : Colours.blue,
                  child:

                  type == 'text/plain' ?

                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                      child:

                      // Modify here.
                      Text(text,style: TextStyle(
                        fontSize: FontSizes.smallerText,
                        color: Colors.black,
                      ),
                      )
                  )


                      : type == 'FileType.image' ?
                  Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 0.0),
                      child:

                      Container(
                        child: FlatButton(
                          child: Material(
                            child: CachedNetworkImage(
                              placeholder: (context, url) => Container(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlueAccent),
                                ),
                                width: 100.0,
                                height: 100.0,
                                padding: EdgeInsets.all(70.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                ),
                              ),

                              /*TODO*/
                              errorWidget: (context, url, error) => Material(
                                child: Image.asset(
                                  'images/logo.png',
                                  width: 100.0,
                                  height: 100.0,
                                  fit: BoxFit.cover,
                                ),

                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),

                                clipBehavior: Clip.hardEdge,

                              ),

                              imageUrl: text,
                              width: 150.0,
                              height: 150.0,
                              fit: BoxFit.cover,
                            ),

                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),

                          onPressed: (){
                            // enlarge the photo to full screen
                          },

                        ),
                      )


                  )

                      : type == 'FileType.video' ?


                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Stack(
                          alignment: AlignmentDirectional.center,
                          children: <Widget>[
                            Container(
                              width: 130,
                              color: Colors.black45,
                              height: 80,
                            ),

                            Column(
                              children: <Widget>[
                                Icon(
                                  Icons.videocam,
                                  color: Colors.black,
                                ),

                                SizedBox(height: 5,),

                                Text('Video',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ) ,
                                )

                              ],
                            ),
                          ],
                        ),

                        Container(
                          height: 40,
                          child: IconButton(
                            icon: Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                            ),

                            // implement onPressed here
                            // the text here is the video url
                            onPressed: () => showVideoPlayer(context, text),

                          ),
                        ),


                      ],
                    ),
                  )

                  // if not, it must be a document
                  // requires file downloader API
                  // requires changing android permissions
                  // TODO - Do later! After integrating with the main application
                      :
                  Container()

              ),
            ),
          ]
      ),
    );
  }
}