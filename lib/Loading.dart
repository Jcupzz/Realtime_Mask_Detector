import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).backgroundColor,
        child: Center(
          child: SpinKitRipple(
            color:Colors.white,
            size: 80.0,
          ),
        ));
  }
}