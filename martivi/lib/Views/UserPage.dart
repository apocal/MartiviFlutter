import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/ChatMessage.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:provider/provider.dart';

import 'ContactPage.dart';

class UserPage extends StatefulWidget {
  final User user;
  UserPage({this.user});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  ScrollController scrollController = ScrollController();
  TextEditingController sendMessageController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (context, value, child) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.user.isAnonymous
                  ? AppLocalizations.of(context).translate('Guest')
                  : widget.user.email),
              bottom: TabBar(
                indicatorColor: Colors.white,
                tabs: <Widget>[
                  Tab(
                    text: AppLocalizations.of(context).translate('Contact'),
                  ),
                  Tab(
                    text: AppLocalizations.of(context).translate('Profile'),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24.0, right: 24.0, bottom: 24.0),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: widget.user.messages,
                          builder: (context, value, child) {
                            return ListView.builder(
                              controller: scrollController,
                              itemCount: widget.user.messages.value.length,
                              itemBuilder: (context, index) {
                                return MessageWidget(
                                    currentUser: widget.user,
                                    message: widget.user.messages.value[index]);
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
                                          serverTime:
                                              FieldValue.serverTimestamp(),
                                          pair: 'admin${widget.user.uid}',
                                          message:
                                              sendMessageController.value.text,
                                          senderUserId: 'admin',
                                          targetUserId: widget.user.uid)
                                      .toJson());
                              Firestore.instance
                                  .collection('/newmessages')
                                  .document('to${widget.user.uid}FromAdmin')
                                  .setData({'hasNewMessages': true});
                              sendMessageController.clear();
                              scrollController.jumpTo(
                                  scrollController.position.maxScrollExtent);
                            },
                            child: Icon(Icons.send),
                          ),
                        )),
                      )
                    ],
                  ),
                ),
                Container(),
              ],
            ),
          ),
        );
      },
    );
  }
}