import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_vision/flutter_vision.dart';

class ScanController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  var isCameraInitialized = false.obs;
  var detectedObjects = <Map<String, dynamic>>[].obs;
  FlutterVision vision = FlutterVision();
  var objectDetectionInProgress = false.obs;

  void setObjectDetectionInProgress(bool value) {
    objectDetectionInProgress.value = value;
  }

  // RxInt 변수를 선언하여 cameraImage의 너비와 높이를 저장합니다.
  var imageWidth = RxInt(0);
  var imageHeight = RxInt(0);
  var imgH;

  @override
  Future<void> onInit() async {
    await initCamera();
    // await initTFLite();
    super.onInit();
//    setObjectDetectionInProgress(false);
  }

  @override
  void dispose() {
    //  vision.closeYoloModel();
    cameraController.dispose();
    super.dispose();
  }

  initCamera() async {
    if (await Permission.camera
        .request()
        .isGranted) {
      cameras = await availableCameras();

      cameraController = CameraController(cameras[0], ResolutionPreset.max);

      //   await cameraController.initialize().then((value) {
      //     cameraController.startImageStream((image) {
      //       // cameraImage의 너비와 높이를 Rx 변수에 할당합니다.
      //       imageWidth.value = image.width;
      //       imageHeight.value = image.height;
      //       objectDetection(image);
      //       print(imageWidth.value);
      //       print(imageHeight.value);
      //
      //     });
      //     isCameraInitialized(true);
      //     update();
      //   });
      // } else {
      //   print("Permission denied");
      // }
    }
  }

    // initTFLite() async {
    //   await vision.loadYoloModel(
    //     labels: 'asset/labels1.txt',
    //     modelPath: 'asset/best_float32.tflite',
    //     modelVersion: "yolov8",
    //     quantization: false,
    //     numThreads: 2,
    //     useGpu: false,
    //   );
    //
    // }
    // objectDetection(CameraImage image) async {
    //   if (objectDetectionInProgress.value == true) return;
    //
    //   final result = await vision.yoloOnFrame(
    //     bytesList: image.planes.map((plane) => plane.bytes).toList(),
    //     imageHeight: image.height,
    //     imageWidth: image.width,
    //     iouThreshold: 0.4,
    //     confThreshold: 0.4,
    //     classThreshold: 0.5,
    //   );
    //
    //   if (result.isNotEmpty) {
    //     List<Map<String, dynamic>> filteredObjects = [];
    //     for (var obj in result) {
    //       if (obj["tag"] == "refrigerator" ||
    //           obj["tag"] == "air conditioner" ||
    //           obj["tag"] == "power soket" ||
    //           obj["tag"] == "gas_stove" ||
    //           obj["tag"] == "washing machine" ||
    //           obj["tag"] == "wood boiler"
    //       ) {
    //         // 인식된 오브젝트의 태그가 원하는 값들 중 하나와 일치하는 경우에만 detectedObjects에 추가
    //         obj["imageHeight"] = image.height;
    //
    //         filteredObjects.add(obj);
    //       }
    //       detectedObjects.value = filteredObjects;
    //       imgH = image.height;
    //       update();
    //     }
    //   }
    // }
    // objectDetectionImage(File imageFile) async {
    //   if (imageFile.path.isNotEmpty) {
    //     objectDetectionInProgress(true);
    //     print(objectDetectionInProgress);
    //     Uint8List byte = await imageFile.readAsBytes();
    //     final image = await decodeImageFromList(byte);
    //     imageWidth.value = image.width;
    //     imageHeight.value = image.height;
    //     final result = await vision.yoloOnImage(
    //       bytesList: byte,
    //       imageHeight: image.height,
    //       imageWidth: image.width,
    //       iouThreshold: 0.4,
    //       confThreshold: 0.4,
    //       classThreshold: 0.5,
    //     );
    //     if (result.isNotEmpty) {
    //
    //       detectedObjects.value = result;
    //       //print("x:${detectedObjects}");
    //       print("1:${detectedObjects}");
    //       update();
    //     }
    //   }
    // }
    // 사진을 찍는 메서드
  Future<XFile?> takePicture() async {
    if (!cameraController.value.isInitialized) {
      print("Error: Camera controller is not initialized");
      return null;
    }

    try {
      // 이미지를 캡처합니다.
      XFile picture = await cameraController.takePicture();

//      objectDetectionImage(picture as File);
      // 캡처한 이미지의 경로를 반환합니다.
      return picture;
    } catch (e) {
      print("Error capturing picture: $e");
      return null;
    }
  }
}
