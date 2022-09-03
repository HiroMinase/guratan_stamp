import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:image_editor/image_editor.dart';
import 'package:provider/provider.dart';

import 'package:guratan_stamp/StickerProvider.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<StickerProvider>(
          create: (context) => StickerProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
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
  ImageProvider? editImage;
  final _picker = picker.ImagePicker();
  List<Widget> stampWidgets = [];
  Uint8List? result;

  BlendMode blendMode = BlendMode.srcOver;

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

  addStampWidget(String fileName, int stampNamePositionsLength, Function syncStickerPositions) {
    setState(() {
      stampWidgets.add(
        StatefulDragArea(
          fileName: fileName,
          widgetId: stampNamePositionsLength + 1,
          child: Image.asset(
            "assets/stickers/$fileName",
            width: 60,
            height: 60,
          )
        )
      );
    });

    syncStickerPositions(stampNamePositionsLength + 1, fileName, 0.0, 0.0);
  }

  mixStickers(BuildContext context, Map stampNamePositions) {
    print("ステッカーのfile名と座標群: $stampNamePositions");
    for (var namePosition in stampNamePositions.values) {
      mixImage(
        context,
        namePosition["fileName"],
        namePosition["xPosition"],
        namePosition["yPosition"],
      );
    }
  }

  Future mixImage(BuildContext context, String fileName, double xPosition, double yPosition) async {
    final Uint8List? src = result ?? _pickImage?.readAsBytesSync();
    final Uint8List dst = await loadFromAsset("assets/stickers/$fileName");

    RenderBox? getBox = context.findRenderObject() as RenderBox;
    var localPos = getBox.globalToLocal(Offset(xPosition, yPosition));

    // TODO: ここが無理矢理すぎるのでどうにか解決したい
    // Image Widget から取得した Offset をそのまま MixImageOption に当てるだけではダメそう
    int x = localPos.dx.toInt() * 4 + 25;
    int y = localPos.dy.toInt() * 4 - 143;

    final ImageEditorOption optionGroup = ImageEditorOption();
    optionGroup.outputFormat = const OutputFormat.png();

    print("ぐらたんのX座標: $xPosition");
    print("ローカルポジションに変換後のX座標: $x");

    print("ぐらたんのY座標: $yPosition");
    print("ローカルポジションに変換後のY座標: $y");

    optionGroup.addOption(
      MixImageOption(
        x: x,
        y: y,
        width: 250,
        height: 250,
        target: MemoryImageSource(dst),
        blendMode: blendMode,
      ),
    );

    result = await ImageEditor.editImage(image: src!, imageEditorOption: optionGroup);

    setState(() {
      if (result == null) {
        editImage = null;
      } else {
        result = result;
        editImage = MemoryImage(result!);
      }

      stampWidgets = [];
      _pickImage = null;
    });
  }

  Future<Uint8List> loadFromAsset(String key) async {
    final ByteData byteData = await rootBundle.load(key);
    return byteData.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    final StickerProvider stickerProvider = Provider.of<StickerProvider>(context, listen: true);

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
                editImage != null ? Image(image: editImage!) : Container(),
                if (_pickImage != null && editImage == null) Image.file(_pickImage!, fit: BoxFit.cover, width: double.infinity),
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
                        addStampWidget("guratan.png", stickerProvider.stampNamePositions.length, stickerProvider.syncStickerPositions);
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
                        mixStickers(context, stickerProvider.stampNamePositions);
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
                            child: const Text("画像を生成")
                        ),
                      ),
                    ),
                  ]
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
  const StatefulDragArea({Key? key, required this.child, required this.fileName, required this.widgetId}) : super(key: key);

  final Widget child;
  final String fileName;
  final int widgetId;

  @override
  State<StatefulDragArea> createState() => _DragAreaStateState();
}

class _DragAreaStateState extends State<StatefulDragArea> {
  final Size windowSize = MediaQueryData.fromWindow(window).size;
  late Offset position = Offset((windowSize.width / 2 - 30), (windowSize.height / 2 - 30));
  // Offset position = const Offset(0, 0);
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

  updatePosition(Offset newPosition, Function syncStickerPositions) {
    print("移動後のOffset: $newPosition");
    setState(() {
      position = Offset(newPosition.dx, newPosition.dy - 103);
    });

    syncStickerPositions(widget.widgetId, widget.fileName, position.dx, position.dy);
  }

  @override
  Widget build(BuildContext context) {
    final StickerProvider stickerProvider = Provider.of<StickerProvider>(context, listen: true);

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
                updatePosition(details.offset, stickerProvider.syncStickerPositions);
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
