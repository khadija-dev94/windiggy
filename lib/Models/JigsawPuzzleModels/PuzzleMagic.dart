import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui show instantiateImageCodec, Codec, Image;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:network_image_to_byte/network_image_to_byte.dart';
import 'ImageNode.dart';
import 'dart:ui' as ui;

class PuzzleMagic {
  ui.Image image;
  double eachWidth;
  double eachHeight;

  Size screenSize;
  double baseX;
  double baseY;

  int level;
  double eachBitmapWidth;

  Future<ui.Image> init(ui.Image byteImg, Size size, int level) async {
    this.image = byteImg;
    screenSize = size;
    this.level = level;
    eachWidth = screenSize.width / level;
    eachHeight = screenSize.height * 0.63 / level;
    baseX = 0.0;
    baseY = 0.0;
    eachBitmapWidth = (image.width / level);
    return image;
  }

  Future<Uint8List> _networkImageToByte(String imageStr) async {
    Uint8List byteImage = await networkImageToByte(imageStr);
    return byteImage;
  }

  Future<ui.Image> loadImage(String img) async {
    Uint8List image = await _networkImageToByte(img);

    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(image, (ui.Image img) {
      return completer.complete(img);
    });
    this.image = await completer.future;
    return completer.future;
  }

  List<ImageNode> doTask() {
    List<ImageNode> list = [];
    for (int j = 0; j < level; j++) {
      for (int i = 0; i < level; i++) {
        if (j * level + i < level * level - 1) {
          ImageNode node = ImageNode();
          node.rect = getOkRectF(i, j);
          node.index = j * level + i;
          makeBitmap(node);
          list.add(node);
        }
      }
    }
    return list;
  }

  Rect getOkRectF(int i, int j) {
    return Rect.fromLTWH(
        baseX + eachWidth * i, baseY + eachHeight * j, eachWidth, eachHeight);
  }

  void makeBitmap(ImageNode node) async {
    int i = node.getXIndex(level);
    int j = node.getYIndex(level);

    Rect rect = getShapeRect(i, j, eachBitmapWidth);
    rect = rect.shift(
        Offset(eachBitmapWidth.toDouble() * i, eachBitmapWidth.toDouble() * j));

    PictureRecorder recorder = PictureRecorder();
    double ww = eachBitmapWidth.toDouble();
    Canvas canvas = Canvas(recorder, Rect.fromLTWH(0.0, 0.0, ww, ww));

    Rect rect2 = Rect.fromLTRB(0.0, 0.0, rect.width, rect.height);

    Paint paint = Paint();
    canvas.drawImageRect(image, rect, rect2, paint);
    node.image = await recorder.endRecording().toImage(ww.floor(), ww.floor());
    node.rect = getOkRectF(i, j);
  }

  Rect getShapeRect(int i, int j, double width) {
    return Rect.fromLTRB(0.0, 0.0, width, width);
  }
}
