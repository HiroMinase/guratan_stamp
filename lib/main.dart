import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  File? _image;
  final _picker = ImagePicker();
  List<Widget> stampWidgets = [];

  // 画像取得処理
  Future getImage(FileMode fileMode) async {
    late final dynamic pickedFile;

    // カメラからとギャラリーからの2通りの画像取得（パスの取得）を設定
    if (fileMode == FileMode.takePicture) {
      pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 100);
    } else {
      pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    }

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  addStampWidget(String fileName) {
    setState(() {
      stampWidgets.add(StatefulDragArea(child: Image.asset("assets/stamp/$fileName", width: 60, height: 60)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_image != null) Image.file(_image!),
                if (_image == null) GestureDetector(
                  onTap: () {
                    getImage(FileMode.importFromGallery);
                  },
                  child: const Text("読み込み"),
                ),
                if (_image != null) GestureDetector(
                  onTap: () {
                    addStampWidget("guratan.png");
                  },
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(width: 1.0, color: Colors.black),
                      ),
                      child: const Text("スタンプを追加")
                    ),
                  ),
                ),
              ]
            ),
            ...stampWidgets,
          ],
        ),
      ),
    );
  }
}

class StatefulDragArea extends StatefulWidget {
  const StatefulDragArea({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  State<StatefulDragArea> createState() => _DragAreaStateState();
}

class _DragAreaStateState extends State<StatefulDragArea> {
  Offset position = const Offset(0, 0);
  double prevScale = 1;
  double scale = 1;

  updateScale(double zoom) {
    print(zoom);
    setState(() {
      scale = prevScale * zoom;
    });
  }

  commitScale() {
    print(scale);
    setState(() {
      prevScale = scale;
    });
  }

  updatePosition(Offset newPosition) {
    print(newPosition);
    print(newPosition.dx);
    print(newPosition.dy);
    print(Offset(newPosition.dx, newPosition.dy - 103));
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
              onDragEnd: (details) => updatePosition(details.offset),
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
