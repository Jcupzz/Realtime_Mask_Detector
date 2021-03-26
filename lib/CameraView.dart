import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:sliding_sheet/sliding_sheet.dart';

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
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return SafeArea(
              child: Stack(
                children: [
                  Container(
                    child: CameraPreview(_controller),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.85,
                  ),
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
