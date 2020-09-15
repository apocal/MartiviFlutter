import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';

ImageProvider safeNetworkImage(String url) {
  if ((url?.length ?? 0) > 0) return NetworkImage(url);
  return AssetImage('assets/placeHolder.png');
}

class InnerShadow extends SingleChildRenderObjectWidget {
  const InnerShadow({
    Key key,
    this.shadows = const <Shadow>[],
    Widget child,
  }) : super(key: key, child: child);

  final List<Shadow> shadows;

  @override
  RenderObject createRenderObject(BuildContext context) {
    final renderObject = _RenderInnerShadow();
    updateRenderObject(context, renderObject);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderInnerShadow renderObject) {
    renderObject.shadows = shadows;
  }
}

class _RenderInnerShadow extends RenderProxyBox {
  List<Shadow> shadows;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final bounds = offset & size;
    final canvas = context.canvas;

    canvas.saveLayer(bounds, Paint());
    context.paintChild(child, offset);

    for (final shadow in shadows) {
      final shadowRect = bounds.inflate(shadow.blurSigma);
      final shadowPaint = Paint()
        ..blendMode = BlendMode.srcATop
        ..colorFilter = ColorFilter.mode(shadow.color, BlendMode.srcOut)
        ..imageFilter = ImageFilter.blur(
            sigmaX: shadow.blurSigma, sigmaY: shadow.blurSigma);
      canvas
        ..saveLayer(shadowRect, shadowPaint)
        ..translate(shadow.offset.dx, shadow.offset.dy);
      context.paintChild(child, offset);
      canvas.restore();
    }

    canvas.restore();
  }
}

class OkDialog extends StatelessWidget {
  const OkDialog({@required this.content, @required this.title});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: <Widget>[
        FlatButton(
          splashColor: kPrimary.withOpacity(.2),
          child: Text(
            AppLocalizations.of(context).translate('Ok'),
            style: TextStyle(color: kPrimary),
          ),
          onPressed: () {
            Navigator.pop(
                context, AppLocalizations.of(context).translate('Ok'));
          },
        )
      ],
      title: Text(title),
      content: Text(content),
    );
  }
}
