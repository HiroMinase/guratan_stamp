import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class StickerProvider with ChangeNotifier {
  // {
  //   0: { "fileName": "guratan.png", "xPosition": 20.0, "yPosition": 48.0 },
  //   1: { "fileName": "macaroni.png", "xPosition": 80.0, "yPosition": 160.0 },
  // }
  Map<int, Map> stampNamePositions = {};

  void syncStickerPositions(int widgetId, String fileName, double xPosition, double yPosition) {
    if (stampNamePositions.containsKey(widgetId)) {
      Map<String, dynamic> entryMap = {
        "fileName": fileName, "xPosition": xPosition, "yPosition": yPosition
      };

      stampNamePositions[widgetId] = entryMap;
    } else {
      Map<int, Map> entryMap = {
        widgetId: { "fileName": fileName, "xPosition": xPosition, "yPosition": yPosition }
      };

      stampNamePositions.addEntries(entryMap.entries);
    }

    notifyListeners();
  }
}