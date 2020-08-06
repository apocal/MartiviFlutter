import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/ChatMessage.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:provider/provider.dart';

import 'ContactPage.dart';

class UserPage extends StatelessWidget {
  TextEditingController sendMessageController = TextEditingController();
  final User user;
  UserPage({this.user});
  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (context, value, child) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(user.isAnonymous
                  ? AppLocalizations.of(context).translate('Guest')
                  : user.email),
              bottom: TabBar(
                indicatorColor: Colors.white,
                tabs: <Widget>[
                  Tab(
                    text: AppLocalizations.of(context).translate('Profile'),
                  ),
                  Tab(
                    text: AppLocalizations.of(context).translate('Contact'),
                  )
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                Container(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: user.messages,
                          builder: (context, value, child) {
                            return ListView.builder(
                              itemCount: user.messages.value.length,
                              itemBuilder: (context, index) {
                                return MessageWidget(
                                    message: user.messages.value[index]);
                              },
                            );
                          },
                        ),
                      ),
                      TextField(
                        controller: sendMessageController,
                        decoration: InputDecoration(
                            suffixIcon: Material(
                          child: InkWell(
                            onTap: () {
                              if (!((sendMessageController?.text?.length ?? 0) >
                                  0)) return;
                              Firestore.instance
                                  .collection('/messages')
                                  .document()
                                  .setData(ChatMessage(
                                          pair: 'admin${user.uid}',
                                          message:
                                              sendMessageController.value.text,
                                          senderUserId: 'admin',
                                          targetUserId: user.uid)
                                      .toJson());
                              Firestore.instance
                                  .collection('/newmessages')
                                  .document('to${user.uid}FromAdmin')
                                  .setData({'hasNewMessages': true});
                              sendMessageController.clear();
                            },
                            child: Icon(Icons.send),
                          ),
                        )),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
