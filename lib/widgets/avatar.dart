import 'package:flutter/material.dart';

double _kAvatarSize = 48;

class Avatar extends StatelessWidget {
  Avatar({Key? key, this.photo}) : super(key: key);

  final String? photo;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: _kAvatarSize,
      backgroundImage: photo != null ? NetworkImage(photo!) : null,
      child:
          photo == null ? Icon(Icons.person_outline, size: _kAvatarSize) : null,
    );
  }
}
