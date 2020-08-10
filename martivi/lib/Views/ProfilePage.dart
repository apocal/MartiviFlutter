import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('Profile')),
      ),
      body: Consumer2<MainViewModel, FirebaseUser>(
        builder: (context, viewModel, firebaseUser, child) {
          return Container(
              padding: EdgeInsets.all(8),
              child: firebaseUser != null
                  ? Container(
                      child: Column(
                        children: [
                          (firebaseUser?.photoUrl?.length??0)>0?CircleAvatar
                        ],
                      ),
                    )
                  : Container(
                      child: Text('Unauthorized'),
                    ));
        },
      ),
    );
  }
}
