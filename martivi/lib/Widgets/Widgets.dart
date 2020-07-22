import 'package:flutter/material.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';

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
