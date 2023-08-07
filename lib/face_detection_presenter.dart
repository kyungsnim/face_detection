import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_pickers/image_pickers.dart';
import '_importer.dart';

class FaceDetectionPresenter extends StatefulWidget {
  const FaceDetectionPresenter({super.key});

  @override
  State<FaceDetectionPresenter> createState() => _FaceDetectionPresenterState();
}

class _FaceDetectionPresenterState extends State<FaceDetectionPresenter> {
  late List<Media>? _listImagePaths = [];

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.front;

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return DetectorView(
      title: 'Face Detector',
      customPaint: _customPaint,
      text: _text,
      onImage: _processImage,
      initialCameraLensDirection: _cameraLensDirection,
      onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);
    } else {
      String text = 'Faces found: ${faces.length}\n\n';
      for (final face in faces) {
        text += 'face: ${face.boundingBox}\n\n';
      }
      _text = text;
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _onPressAddImages() async {
  //
  //     ImagePickers.pickerPaths(
  //       galleryMode: GalleryMode.image,
  //       selectCount: 2,
  //       showGif: false,
  //       showCamera: true,
  //       compressSize: 500,
  //       uiConfig: UIConfig(uiThemeColor: Color(0xffff0f50)),
  //       cropConfig: CropConfig(enableCrop: false, width: 2, height: 1),
  //     ).then((values) {
  //       setState(() {
  //         _listImagePaths = values;
  //       });
  //     });
  //
  //
  //
  //     final List<Face> faces = await faceDetector.processImage(InputImage.fromFilePath(_listImagePaths![0].path!));
  //
  //     for (Face face in faces) {
  //       final Rect boundingBox = face.boundingBox;
  //
  //       final double? rotX = face.headEulerAngleX; // Head is tilted up and down rotX degrees
  //       final double? rotY = face.headEulerAngleY; // Head is rotated to the right rotY degrees
  //       final double? rotZ = face.headEulerAngleZ; // Head is tilted sideways rotZ degrees
  //
  //       // If landmark detection was enabled with FaceDetectorOptions (mouth, ears,
  //       // eyes, cheeks, and nose available):
  //       final FaceLandmark? leftEar = face.landmarks[FaceLandmarkType.leftEar];
  //       if (leftEar != null) {
  //         final Point<int> leftEarPos = leftEar.position;
  //       }
  //
  //       // If classification was enabled with FaceDetectorOptions:
  //       if (face.smilingProbability != null) {
  //         final double? smileProb = face.smilingProbability;
  //       }
  //
  //       // If face tracking was enabled with FaceDetectorOptions:
  //       if (face.trackingId != null) {
  //         final int? id = face.trackingId;
  //       }
  //     }
  }
}
