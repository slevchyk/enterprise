import 'package:enterprise/models/profile.dart';
import 'package:flutter/material.dart';

class UserPhoto extends StatelessWidget {
  final Profile profile;

  UserPhoto({
    this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return _userPhoto();
  }

  Widget _userPhoto() {
    if (profile == null ||
        profile.photoName == null ||
        profile.photoName == '') {
      return CircleAvatar(
        child: Text('фото'),
      );
    } else {
      Widget circleAvatar;
      try {
        circleAvatar = CircleAvatar(
          backgroundImage: AssetImage(profile.photoName),
        );
      } catch (e){
        circleAvatar = CircleAvatar(
          child: Text('фото'),
        );
      }
      return circleAvatar;
    }
  }
}
