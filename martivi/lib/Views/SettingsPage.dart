import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/Settings.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('Settings')),
      ),
      body: Consumer<MainViewModel>(
        builder: (context, viewModel, child) {
          Settings settings = viewModel.settings.value;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(AppLocalizations.of(context).translate('General')),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.do_not_disturb,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(AppLocalizations.of(context)
                            .translate('Stop ordering')),
                      ],
                    ),
                    Switch(
                      value: settings.stopOrdering ?? false,
                      activeColor: kPrimary,
                      onChanged: (value) {
                        setState(() {
                          settings.stopOrdering = value;
                        });
                      },
                    ),
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.vertical_align_top,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(AppLocalizations.of(context)
                            .translate('Maximum order price'))
                      ],
                    ),
                    Container(width: 20, child: TextField())
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.vertical_align_bottom,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(AppLocalizations.of(context)
                            .translate('Minimum order price')),
                      ],
                    )
                  ],
                ),
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            FontAwesome.truck,
                            color: Colors.grey.shade700,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).translate(
                                  'Delivery fee under maximum order price'),
                              maxLines: null,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                FlatButton(
                  child: Text(
                    AppLocalizations.of(context).translate('Apply changes'),
                    style: TextStyle(color: kPrimary),
                  ),
                  onPressed: () {
                    Firestore.instance
                        .collection('/settings')
                        .document('settings')
                        .setData(settings.toJson());
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
