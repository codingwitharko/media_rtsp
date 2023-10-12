import 'dart:ui' as ui;
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
 import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
 import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/media_kit_video_controls.dart'
    as media_kit_video_controls;
import 'package:path_provider/path_provider.dart';

import 'face_detector/painter/face_detector_painter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var rtspSet = false;
  var isPlaying = false;
  var rtspServer =
      'rtsp://admin:123asdfg@185.190.23.227:555/cam/realmonitor?channel=1&subtype=0';
  final player = Player();
  VideoController? vc;

  Future<void> initRtsp() async {
    rtspSet = false;
    onChanged();
    await player.open(Media(rtspServer), play: true);
    vc = VideoController(player);
    vc!.player.play();
    rtspSet = true;
    onChanged();
    onFrames();
  }
  //TODO: Implement HomeController
   var selectedImagePath='';
  var extractedBarcode='';
  var isLoading = false;
  List<Face> ?facess;
  ui.Image ?iimage;
  InputImage ?image;

  Future <void>getImageAndDetectFaces({required Uint8List imageFile}) async {
//var imageFilee=imageFile.toFile();
    isLoading = true;
    final f =
    File('${(await getTemporaryDirectory()).path}/images/image-ph.png');
    await f.create(recursive: true);
    f.writeAsBytes(imageFile);
    image = InputImage.fromFile(f) ;
    final faceDetector = GoogleMlKit.vision.faceDetector(
        FaceDetectorOptions(performanceMode: FaceDetectorMode.fast, enableLandmarks: true));
    List<Face> faces = await faceDetector.processImage(image!);
    facess = faces;
    await _loadImage(imageFile);
    capturedPhotoDialog(iimage,facess);
   onChanged();

  }

  _loadImage(Uint8List file) async {
    await decodeImageFromList(file).then(
            (value) =>
        iimage = value);
    isLoading = false;
    onChanged();

  }
  void onChanged() {
    setState(() {});
  }

  bool canCapture = false;

  capture() async {
    final Uint8List? screenshot = await player.screenshot();
    if(Get.isDialogOpen==true){
      Get.back();
      Get.dialog(
        Center(
          child:Container(
            width: 300,
            height: 200,
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color:  Colors.green, width: 4.0),
              image: DecorationImage(
                image: MemoryImage(screenshot!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        barrierDismissible: false,
        useSafeArea: true,
      );
    }else{
      Get.dialog(
        Center(
          child:Container(
            width: 300,
            height: 200,
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color:  Colors.green, width: 4.0),
              image: DecorationImage(
                image: MemoryImage(screenshot!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        barrierDismissible: false,
        useSafeArea: true,
      );
    }

    canCapture = false;
    print('---------------------');
    print('---------------------');
    print('screenshot');
    print('---------------------');
    print('---------------------');
    await Future.delayed(const Duration(seconds: 10));
    onChanged();
  }

  Future<void> onFrames() async {
// Get notified as [Stream]:
    player.stream.playing.listen(
          (bool playing) {
            isPlaying=playing;
            onChanged();
      },
    );
    var lastPose = Duration();
    player.stream.buffer.listen(
      (Duration position) async {
        if (lastPose != position) {
          if(isPlaying){
          await capture();
          lastPose = position;
          onChanged();
        }
        }
      },
    );
  }

  @override
  void initState() {
    initRtsp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: rtspSet
            ? Video(
                controller: vc!,
                wakelock: true,
                controls: media_kit_video_controls.NoVideoControls,
              )
            : Container(),
      ),
    );
  }
}
var capturedPhoto = false.obs;

Future<void> capturedPhotoDialog( iimage,facess) async {
  Get.dialog(
    Center(
      child: Row(
        children: [
          Container(
            width: 160,
            height: 200,
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color:  Colors.green, width: 4.0),
            ),
            child:  FittedBox(
              child: SizedBox(
                width:  iimage?.width.toDouble(),
                height: iimage?.height.toDouble(),
                child: CustomPaint(
                  painter: FaceDetectorPainter(
                     iimage!,
                     facess!,
                    Size( iimage!.height.toDouble(),
                         iimage!.width.toDouble()),
                    InputImageRotation.rotation90deg,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    barrierDismissible: false,
    useSafeArea: true,
  );
}