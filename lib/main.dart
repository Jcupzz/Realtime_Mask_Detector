import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:realtime_mask_detector/CameraView.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;
  runApp(MyApp(firstCamera: firstCamera,));
}



class MyApp extends StatelessWidget {
  var firstCamera;

  // This widget is the root of your application.
  MyApp({
  this.firstCamera
});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: CameraView(camera: firstCamera,),
    );
  }
}

