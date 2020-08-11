import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/FirestoreImage.dart';
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
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        (firebaseUser?.photoUrl?.length ?? 0) > 0
                            ? CircleAvatar(
                                backgroundImage:
                                    NetworkImage(firebaseUser.photoUrl),
                              )
                            : IconButton(
                                iconSize: 50,
                                onPressed: () async {
                                  FirestoreImage image = FirestoreImage();
                                  var pickedImage = await ImagePicker()
                                      .getImage(source: ImageSource.gallery);
                                  if (pickedImage != null) {}
                                },
                                icon: Icon(
                                  FontAwesome.user,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                        if (viewModel.user != null) ...[
                          Divider(
                            height: 30,
                          ),
                          Text(
                            viewModel.user.email,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            height: 60,
                            child: TextField(
                              decoration: kOutlineInputText.copyWith(
                                  hintText: AppLocalizations.of(context)
                                      .translate('Name')),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            height: 60,
                            child: TextField(
                              decoration: kOutlineInputText.copyWith(
                                  hintText: AppLocalizations.of(context)
                                      .translate('Phone')),
                            ),
                          ),
                          Divider(
                            height: 20,
                          ),
                          Text(
                            AppLocalizations.of(context).translate('Addresses'),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Divider(),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: Firestore.instance
                                  .collection('Addresses')
                                  .where('uid', isEqualTo: firebaseUser.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return ListView.builder(
                                    itemCount:
                                        snapshot.data.documents.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index <
                                          snapshot.data.documents.length)
                                        return Text(snapshot
                                            .data.documents[index].data
                                            .toString());
                                      else
                                        return FlatButton(
                                          splashColor:
                                              kPrimary.withOpacity(0.2),
                                          highlightColor:
                                              kPrimary.withOpacity(.2),
                                          onPressed: () {},
                                          child: Text(
                                            AppLocalizations.of(context)
                                                .translate('Add'),
                                            style: TextStyle(color: kPrimary),
                                          ),
                                        );
                                    },
                                  );
                                }
                                return Container();
                              },
                            ),
                          ),
                        ],
                      ],
                    )
                  : Container(
                      child: Text('Unauthorized'),
                    ));
        },
      ),
    );
  }
}
