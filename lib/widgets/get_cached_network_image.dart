import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:heard/constants.dart';

class GetCachedNetworkImage extends StatelessWidget {
  final String profilePicture;
  final String authToken;
  final double dimensions;

  GetCachedNetworkImage({this.profilePicture, this.authToken, this.dimensions});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimensions.d_65),
      child: CachedNetworkImage(
        imageUrl:
        'https://heard-project.herokuapp.com/attachment?filename=$profilePicture',
        httpHeaders: {'Authorization': authToken},
        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
            child: CircularProgressIndicator(value: downloadProgress.progress)),
        errorWidget: (context, url, error) => Icon(Icons.error),
        width: dimensions,
        height: dimensions,
        fit: BoxFit.fitHeight,
      ),
    );
  }
}
