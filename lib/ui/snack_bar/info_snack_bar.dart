import 'package:flutter/material.dart';

class InfoSnackBar extends SnackBar {
  InfoSnackBar(String info)
      : super(
          content: Text(info),
          behavior: SnackBarBehavior.floating,
        );
}
