import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/scan_controller.dart';

List<Widget> displayBoxesAroundRecognizedObjects(
    ScanController controller,
    var width,
    var height,
    ) {
  List<Map<String, dynamic>> yoloResults = controller.detectedObjects;
  if (yoloResults.isEmpty) return [];

  Color colorPick = const Color.fromARGB(255, 50, 233, 30);
  return yoloResults.map((result) {
    double x = result["box"][0];
    double y = result["box"][1];
    double w = result["box"][2];
    double h = result["box"][3];
    double imgH = result["imageHeight"];
    double fontSize = (y - h) * 0.2; // 텍스트 길이가 박스 높이의 70%가 되도록 설정


    return Positioned(
      top: y * (imgH/imgH*width),
      left: x * width,

      child: Container(
        width: w*width,
        height: h*imgH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.pink, width: 2.0),
        ),
        child: Text(
          "${result['tag']} ${(result['box'][4] * 100).toStringAsFixed(0)}%",
          style: TextStyle(
            background: Paint()..color = colorPick,
            color: Colors.white,
            fontSize: math.min(fontSize, 18.0),
          ),
        ),
      ),
    );
  }
  ).toList();
}

class CameraView extends StatelessWidget {
  const CameraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ScanController controller = Get.put(ScanController()); // ScanController 초기화
    controller.setObjectDetectionInProgress(false);
    print(controller.objectDetectionInProgress);
    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    var width = controller.imageWidth.value;
    var height = controller.imageHeight.value;
    var previewH = math.max(height, width);
    var previewW = math.min(height, width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    //mediaQuery 부분
    var Mwidth = MediaQuery.sizeOf(context).width;
    var Mheight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: GetBuilder<ScanController>(
        builder: (controller) {
          return controller.isCameraInitialized.value
              ? Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(controller.cameraController),
              Positioned(
                bottom: 16.0,
                left: 16.0,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  color: Colors.black.withOpacity(0.5),
                  child: Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detected Objects:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        if (controller.detectedObjects.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: controller.detectedObjects
                                .map((obj) => Text(
                              '- ${obj['tag']} ${obj['box'][4]}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
                            ))
                                .toList(),
                          ),
                      ],
                    );
                    }),
                ),
              ),
              Positioned(
                bottom: 16.0,
                right: 16.0,
                child: ElevatedButton(
                  onPressed: () async {
                    XFile? image = await controller.takePicture();
                    RxList<Map<String, dynamic>>? content =
                        controller.detectedObjects;
                    print("image: ${image?.path}");
                    print("content: $content");
                    if (image?.path != null) {

                    } else {
                      print('Failed to take picture');
                    }
                  },
                  child: Icon(Icons.camera),
                ),
              ),
              // ...displayBoxesAroundRecognizedObjects(
              //   controller,
              //   Mwidth,
              //   Mheight,
              // ),
            ],
          )
              : Center(child: Text("Loading Preview..."));
        },
      ),
      floatingActionButton: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
