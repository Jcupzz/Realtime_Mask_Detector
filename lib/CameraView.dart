import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:realtime_mask_detector/Loading.dart';
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
      useGpuDelegate: true
    );
  }

  @override
  void initState() {
    super.initState();
    loadModel();
    _initializeCamera();
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
    cameraController.dispose();
    super.dispose();
  }

  void _initializeCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.high);
    cameraController.initialize().then(
      (_) {
        if (!mounted) {
          return;
        }
        cameraController.startImageStream(
          (CameraImage img) {
            if (!isDetecting) {
              isDetecting = true;
              Tflite.runModelOnFrame(
                bytesList: img.planes.map(
                  (plane) {
                    return plane.bytes;
                  },
                ).toList(),
                imageHeight: img.height,
                imageWidth: img.width,
                imageMean: 127.5,   // defaults to 127.5
                imageStd: 127.5,    // defaults to 127.5
                rotation: 90,       // defaults to 5
                threshold: 0.1,     // defaults to 0.1
                asynch: true,
                numResults: 3,
              ).then(
                (recognitions) {
                  setRecognitions(recognitions, img.height, img.width);
                  isDetecting = false;
                },
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
        body: cameraController == null ? Loading():SafeArea(
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: CameraPreview(cameraController),
          ),
          BoundaryBox(_recognitions == null ? [] : _recognitions, math.max(_imageHeight, _imageWidth),
              math.min(_imageHeight, _imageWidth), screen.height, screen.width),
          // Positioned(
          //   child: SlidingSheet(
          //     elevation: 8,
          //     cornerRadius: 16,
          //
          //     snapSpec: const SnapSpec(
          //       // Enable snapping. This is true by default.
          //       snap: true,
          //       // Set custom snapping points.
          //       snappings: [0.2, 0.4, 0.4],
          //       // Define to what the snappings relate to. In this case,
          //       // the total available space that the sheet can expand to.
          //       positioning: SnapPositioning.relativeToAvailableSpace,
          //     ),
          //     // The body widget will be displayed under the SlidingSheet
          //     // and a parallax effect can be applied to it.
          //
          //     builder: (context, state) {
          //       // This is the content of the sheet that will get
          //       // scrolled, if the content is bigger than the available
          //       // height of the sheet.
          //       return Container(
          //         height: MediaQuery.of(context).size.height * 0.5,
          //         child: Text('This is the content of the sheet'),
          //       );
          //     },
          //   ),
          // )
        ],
      ),
    ));
  }
}
