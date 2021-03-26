import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sliding_sheet/sliding_sheet.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;
import 'boundary_box.dart';

class CameraView extends StatefulWidget {
  final CameraDescription camera;

  CameraView({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  _CameraViewState createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  List<CameraDescription> cameras;
  CameraController cameraController;
  bool isDetecting = false;
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;

  void loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.max,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();



    loadModel();
  }
  void setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }
  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.

            return SafeArea(
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 3/4,
                    child: CameraPreview(_controller),
                  ),
                  BoundaryBox(
                      _recognitions == null ? [] : _recognitions,
                      math.max(_imageHeight, _imageWidth),
                      math.min(_imageHeight, _imageWidth),
                      screen.height,
                      screen.width),
                  Positioned(
                    
                    child: SlidingSheet(
                      elevation: 8,
                      cornerRadius: 16,

                      snapSpec: const SnapSpec(
                        // Enable snapping. This is true by default.
                        snap: true,
                        // Set custom snapping points.
                        snappings: [0.2, 0.4, 0.4],
                        // Define to what the snappings relate to. In this case,
                        // the total available space that the sheet can expand to.
                        positioning: SnapPositioning.relativeToAvailableSpace,
                      ),
                      // The body widget will be displayed under the SlidingSheet
                      // and a parallax effect can be applied to it.

                      builder: (context, state) {
                        // This is the content of the sheet that will get
                        // scrolled, if the content is bigger than the available
                        // height of the sheet.
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Text('This is the content of the sheet'),
                        );
                      },
                    ),
                  )
                ],
              ),
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
