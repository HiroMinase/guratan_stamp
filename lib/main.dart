import 'dart:io';

import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stick_it/stick_it.dart';
import 'package:uuid/uuid.dart';

import 'color_table.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ぐらたんスタンプ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: ColorTable.primaryWhiteColor,
        ).copyWith(
          secondary: ColorTable.primaryBlackColor,
        ),
      ),
      home: const AdvancedExample(),
    );
  }
}

class AdvancedExample extends StatefulWidget {
  const AdvancedExample({Key? key}) : super(key: key);

  @override
  State<AdvancedExample> createState() => _AdvancedExampleState();
}

class _AdvancedExampleState extends State<AdvancedExample> {
  final String _background = 'https://images.unsplash.com/photo-1545147986-a9d6f2ab03b5?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=934&q=80';
  final _picker = ImagePicker();
  late StickIt _stickIt;
  File? _image;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).size.height / 4;
    double leftPadding = MediaQuery.of(context).size.width / 10;
    double boxSize = 56.0;
    _stickIt = StickIt(
      stickerList: [
        Image.asset(
          'assets/stickers/guratan_camera.png',
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ),
        Image.asset('assets/stickers/guratan_cry.png'),
        Image.asset('assets/stickers/guratan_funny.png'),
        Image.asset('assets/stickers/guratan_katakata.png'),
        Image.asset('assets/stickers/guratan_macaroni_pray.png'),
        Image.asset('assets/stickers/guratan_nagoya_01.png'),
        Image.asset('assets/stickers/guratan_worried.png'),
        Image.asset('assets/stickers/guratan_macaroni_teruteru.png'),
        Image.asset('assets/stickers/guratan_ehime_01.png'),
      ],
      key: UniqueKey(),
      panelHeight: 170,
      panelBackgroundColor: ColorTable.primaryWhiteColor,
      panelStickerBackgroundColor: ColorTable.primaryBlueColor,
      stickerSize: 100,
      child: _image == null ? Image.network(_background) : Image.file(_image!, fit: BoxFit.cover),
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          title: const Text("ぐらたんスタンプ", style: TextStyle(fontSize: 16)),
        ),
      ),
      body: Stack(
        children: [
          _stickIt,
          Positioned(
            bottom: bottomPadding,
            left: leftPadding,
            child: Column(
              children: [
                // 画像を保存
                GestureDetector(
                  onTap: () async {
                    final image = await _stickIt.exportImage();
                    final directory = await getApplicationDocumentsDirectory();
                    final path = directory.path;
                    final uniqueIdentifier = const Uuid().v1();
                    final file = await File('$path/$uniqueIdentifier.png').create();
                    file.writeAsBytesSync(image);
                    GallerySaver.saveImage(file.path, albumName: 'guratan');

                    Fluttertoast.showToast(
                      msg: "保存が完了しました！",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.CENTER,
                      timeInSecForIosWeb: 2,
                      backgroundColor: ColorTable.primaryWhiteColor,
                      textColor: ColorTable.primaryBlackColor,
                      fontSize: 16.0,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: ColorTable.primaryBlackColor.withOpacity(0.4),
                    ),
                    child: const Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                // ベース画像を選択
                GestureDetector(
                  onTap: () {
                    generateModal(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: ColorTable.primaryBlackColor.withOpacity(0.4),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSaving == true) Center(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: ColorTable.primaryBlackColor.withOpacity(0.5)
              ),
              child: const SizedBox(
                width: 100,
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(ColorTable.primaryWhiteColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 画像を散り込む方法を選択するモーダルを表示
  void generateModal(BuildContext context) {
    // image_picker で取得した画像を _image に保存
    Future getImage(ImageSource source) async {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 180,
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // ライブラリから取り込む
                Expanded(
                  child: InkWell(
                    onTap: () {
                      getImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.photo,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        SizedBox(
                          width: 100,
                          child: Text('写真を読み込む'),
                        )
                      ],
                    ),
                  ),
                ),
                const Divider(height: 5, thickness: 3),
                // 写真を撮って取り込む
                Expanded(
                  child: InkWell(
                    onTap: () {
                      getImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        SizedBox(
                          width: 100,
                          child: Text('写真を撮る'),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}