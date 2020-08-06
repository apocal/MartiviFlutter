import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/ChatMessage.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:provider/provider.dart';

class MessageWidget extends StatelessWidget {
  final ChatMessage message;
  MessageWidget({this.message});
  @override
  Widget build(BuildContext context) {
    return Text(message.message);
  }
}

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  TextEditingController sendMessageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer2<MainViewModel, FirebaseUser>(
      builder: (context, viewModel, firebaseUser, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.of(context).translate('Contact us')),
          ),
          body: firebaseUser != null
              ? ValueListenableBuilder<User>(
                  valueListenable: viewModel.databaseUser,
                  builder: (context, value, child) {
                    if (value?.role == null) {
                      return Text('Please authorize');
                    }
                    switch (value.role) {
                      case UserType.user:
                        {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                Expanded(
                                  child: ValueListenableBuilder(
                                    valueListenable: viewModel.userMessages,
                                    builder: (context, value, child) {
                                      return ListView.builder(
                                        itemCount:
                                            viewModel.userMessages.value.length,
                                        itemBuilder: (context, index) {
                                          viewModel.newMessages.value = false;
                                          return MessageWidget(
                                              message: viewModel
                                                  .userMessages.value[index]);
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
                                        if (!((sendMessageController
                                                    ?.text?.length ??
                                                0) >
                                            0)) return;
                                        Firestore.instance
                                            .collection('/messages')
                                            .document()
                                            .setData(ChatMessage(
                                                    pair:
                                                        'admin${firebaseUser.uid}',
                                                    message:
                                                        sendMessageController
                                                            .value.text,
                                                    senderUserId:
                                                        firebaseUser.uid,
                                                    targetUserId: 'admin')
                                                .toJson());
                                        Firestore.instance
                                            .collection('/newmessages')
                                            .document(
                                                'toAdminFrom${firebaseUser.uid}')
                                            .setData({'hasNewMessages': true});
                                        sendMessageController.clear();
                                      },
                                      child: Icon(Icons.send),
                                    ),
                                  )),
                                )
                              ],
                            ),
                          );
                          break;
                        }
                      case UserType.admin:
                        {
                          return (Container());
                          break;
                        }
                      default:
                        {
                          return Container();
                        }
                    }
                  },
                )
              : Container(child: Text("Please authorize")),
        );
      },
    );
  }
}
