import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:image_gallery_saver/image_gallery_saver.dart';

// カメラ経由かギャラリー経由かを示すフラグ
enum FileMode{
  takePicture,
  importFromGallery,
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _pickImage;
  final _picker = picker.ImagePicker();
  List<Widget> stampWidgets = [];
  final _globalKey = GlobalKey();

  //  画像取得処理
  Future getImage(FileMode fileMode) async {
    late final dynamic pickedFile;

    // カメラからとギャラリーからの2通りの画像取得（パスの取得）を設定
    if (fileMode == FileMode.takePicture) {
      pickedFile = await _picker.pickImage(source: picker.ImageSource.camera, imageQuality: 100);
    } else {
      pickedFile = await _picker.pickImage(source: picker.ImageSource.gallery, imageQuality: 100);
    }

    if (pickedFile != null) {
      setState(() {
        _pickImage = File(pickedFile.path);
      });
    }
  }

  addStampWidget(String fileName) {
    setState(() {
      stampWidgets.add(
        StatefulDragArea(
          fileName: fileName,
          child: Image.asset(
            "assets/stickers/$fileName",
            width: 60,
            height: 60,
          )
        )
      );
    });
  }

  // RepaintBoundary の key を渡す
  void convertWidgetToImage(GlobalKey widgetGlobalKey) async {
    // RenderObjectを取得
    final RenderRepaintBoundary boundary = widgetGlobalKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    // RenderObject を dart:ui の Image に変換する
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List buffer = byteData!.buffer.asUint8List();
    ImageGallerySaver.saveImage(buffer, quality: 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: RepaintBoundary(
                key: _globalKey,
                child: Stack(
                  children: [
                    if (_pickImage != null) Image.file(_pickImage!, fit: BoxFit.cover, width: double.infinity),
                    ...stampWidgets,
                  ],
                ),
              ),
            ),
            if (_pickImage == null) GestureDetector(
              onTap: () {
                getImage(FileMode.importFromGallery);
              },
              child: const Text("読み込み"),
            ),
            if (_pickImage != null) Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    addStampWidget("guratan_camera.png");
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1.0, color: Colors.black),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text("スタンプを追加")
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    convertWidgetToImage(_globalKey);
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1.0, color: Colors.black),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text("画像を保存")
                    ),
                  ),
                ),
              ]
            ),
          ]
        ),
      ),
    );
  }
}

class StatefulDragArea extends StatefulWidget {
  const StatefulDragArea({Key? key, required this.child, required this.fileName}) : super(key: key);

  final Widget child;
  final String fileName;

  @override
  State<StatefulDragArea> createState() => _DragAreaStateState();
}

class _DragAreaStateState extends State<StatefulDragArea> {
  final Size windowSize = MediaQueryData.fromWindow(ui.window).size;
  late Offset position = Offset((windowSize.width / 2 - 30), (windowSize.height / 2 - 30));
  double prevScale = 1;
  double scale = 1;

  updateScale(double zoom) {
    setState(() {
      scale = prevScale * zoom;
    });
  }

  commitScale() {
    setState(() {
      prevScale = scale;
    });
  }

  updatePosition(Offset newPosition) {
    setState(() {
      position = Offset(newPosition.dx, newPosition.dy - 103);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleUpdate: (details) => updateScale(details.scale),
      onScaleEnd: (_) => commitScale(),
      child: Stack(
        children: [
          Positioned(
            left: position.dx,
            top: position.dy,
            child: Draggable(
              maxSimultaneousDrags: 1,
              feedback: widget.child,
              childWhenDragging: Container(),
              onDragEnd: (details) {
                updatePosition(details.offset);
              },
              child: Transform.scale(
                scale: scale,
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
