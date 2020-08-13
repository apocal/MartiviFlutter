import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart' as Img;
import 'package:image_picker/image_picker.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/Address.dart';
import 'package:martivi/Models/FirestoreImage.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:martivi/Widgets/Widgets.dart';
import 'package:path/path.dart' as ppp;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ValueNotifier<bool> isUploading = ValueNotifier<bool>(false);
  ValueNotifier<bool> isUpdating = ValueNotifier<bool>(false);
  FirestoreImage profileImage = FirestoreImage();
  TextEditingController emailController = TextEditingController(text: '');
  TextEditingController passwordController = TextEditingController(text: '');
  TextEditingController nameController = TextEditingController(text: '');
  TextEditingController phoneController = TextEditingController(text: '');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var databaseUser = context.read<MainViewModel>().databaseUser.value;
    emailController.text = databaseUser.email;
    nameController.text = databaseUser.displayName;
    phoneController.text = databaseUser.phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('Profile')),
      ),
      body: Consumer2<MainViewModel, FirebaseUser>(
        builder: (context, viewModel, firebaseUser, child) {
          return ValueListenableBuilder<User>(
            valueListenable: viewModel.databaseUser,
            builder: (context, databaseUser, child) {
              return ValueListenableBuilder<bool>(
                valueListenable: isUpdating,
                builder: (context, value, child) => Stack(
                  children: [
                    child,
                    if (value)
                      Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
                        ),
                      )
                  ],
                ),
                child: Container(
                    padding:
                        EdgeInsets.only(top: 0, left: 8, right: 8, bottom: 8),
                    child: databaseUser != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      FlatButton(
                                        shape: CircleBorder(),
                                        padding: EdgeInsets.all(8),
                                        child: (profileImage
                                                        ?.downloadUrl?.length ??
                                                    0) >
                                                0
                                            ? Container(
                                                width: 100,
                                                height: 100,
                                                child: CircleAvatar(
                                                  backgroundImage: NetworkImage(
                                                      profileImage.downloadUrl),
                                                ),
                                              )
                                            : (databaseUser?.photoUrl?.length ??
                                                        0) >
                                                    0
                                                ? Container(
                                                    width: 100,
                                                    height: 100,
                                                    child: CircleAvatar(
                                                      backgroundImage:
                                                          NetworkImage(
                                                              databaseUser
                                                                  .photoUrl),
                                                    ),
                                                  )
                                                : Icon(
                                                    FontAwesome.user,
                                                    color: Colors.grey.shade600,
                                                    size: 50,
                                                  ),
                                        onPressed: () async {
                                          try {
                                            var pickedImage =
                                                await ImagePicker().getImage(
                                                    source:
                                                        ImageSource.gallery);
                                            if (pickedImage != null) {
                                              File file =
                                                  File(pickedImage.path);
                                              Img.Image image_temp =
                                                  Img.decodeImage(
                                                      file.readAsBytesSync());
                                              Img.Image resized_img =
                                                  Img.copyResize(image_temp,
                                                      width: 800,
                                                      height: image_temp
                                                              .height ~/
                                                          (image_temp.width /
                                                              800));
                                              var data = Img.encodeJpg(
                                                  resized_img,
                                                  quality: 60);
                                              String filename =
                                                  '${Uuid().v4()}${ppp.basename(file.path)}';
                                              isUploading.value = true;
                                              var imgRef = FirebaseStorage
                                                  .instance
                                                  .ref()
                                                  .child('images')
                                                  .child(filename);
                                              var uploadTask =
                                                  imgRef.putData(data);
                                              profileImage.refPath =
                                                  imgRef.path;
                                              var res =
                                                  await uploadTask.onComplete;
                                              if (!uploadTask.isSuccessful)
                                                throw Exception(AppLocalizations
                                                        .of(context)
                                                    .translate(
                                                        'File upload failed'));
                                              String url = await res.ref
                                                  .getDownloadURL();
                                              String refPath = imgRef.path;
                                              if (!((url?.length ?? 0) > 0)) {
                                                throw Exception(AppLocalizations
                                                        .of(context)
                                                    .translate(
                                                        'File upload failed'));
                                              }
                                              setState(() {
                                                profileImage.downloadUrl = url;
                                              });
                                            }
                                          } on PlatformException catch (e) {
                                            try {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return OkDialog(
                                                        title: AppLocalizations
                                                                .of(context)
                                                            .translate('Error'),
                                                        content: e.message);
                                                  });
                                            } catch (e) {}
                                          } catch (e) {
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return OkDialog(
                                                      title: AppLocalizations
                                                              .of(context)
                                                          .translate('Error'),
                                                      content: e.toString());
                                                });
                                          } finally {
                                            isUploading.value = false;
                                          }
                                        },
                                      ),
                                      if (viewModel.user != null) ...[
                                        Divider(
                                          height: 30,
                                        ),
                                        Text(
                                          firebaseUser == null
                                              ? AppLocalizations.of(context)
                                                  .translate('Unauthorized')
                                              : firebaseUser.isAnonymous
                                                  ? AppLocalizations.of(context)
                                                      .translate('Guest')
                                                  : (databaseUser.displayName
                                                                  ?.length ??
                                                              0) >
                                                          0
                                                      ? databaseUser.displayName
                                                      : databaseUser.email,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.grey.shade700),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          height: 60,
                                          child: TextField(
                                            controller: emailController,
                                            decoration:
                                                kOutlineInputText.copyWith(
                                                    hintText: AppLocalizations
                                                            .of(context)
                                                        .translate(
                                                            'Email / Username')),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          height: 60,
                                          child: TextField(
                                            obscureText: true,
                                            controller: passwordController,
                                            keyboardType:
                                                TextInputType.visiblePassword,
                                            decoration:
                                                kOutlineInputText.copyWith(
                                                    hintText: AppLocalizations
                                                            .of(context)
                                                        .translate('Password')),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          height: 60,
                                          child: TextField(
                                            controller: nameController,
                                            decoration:
                                                kOutlineInputText.copyWith(
                                                    hintText:
                                                        AppLocalizations.of(
                                                                context)
                                                            .translate('Name')),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          height: 60,
                                          child: TextField(
                                            controller: phoneController,
                                            keyboardType: TextInputType.number,
                                            decoration:
                                                kOutlineInputText.copyWith(
                                                    hintText: AppLocalizations
                                                            .of(context)
                                                        .translate('Phone')),
                                          ),
                                        ),
                                        Divider(
                                          height: 20,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)
                                              .translate('Addresses'),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Divider(),
                                        StreamBuilder<QuerySnapshot>(
                                          stream: Firestore.instance
                                              .collection('Addresses')
                                              .where('uid',
                                                  isEqualTo: databaseUser.uid)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (snapshot.data != null) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  ...snapshot.data.documents
                                                      .map((e) => Text(
                                                          e.data.toString())),
                                                  FlatButton(
                                                    splashColor: kPrimary
                                                        .withOpacity(0.2),
                                                    highlightColor: kPrimary
                                                        .withOpacity(.2),
                                                    onPressed: () {
                                                      Navigator.push<
                                                              UserAddress>(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                AddAddressPage(),
                                                          ));
                                                    },
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .translate(
                                                              'Add address'),
                                                      style: TextStyle(
                                                          color: kPrimary),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                            return Container();
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                              FlatButton(
                                onPressed: () async {
                                  try {
                                    setState(() {
                                      isUpdating.value = true;
                                    });

                                    Map<String, dynamic> updateData =
                                        Map<String, dynamic>();
                                    UserUpdateInfo uInfo;
                                    if ((profileImage?.downloadUrl?.length ??
                                            0) >
                                        0) {
                                      uInfo ??= UserUpdateInfo();
                                      uInfo.photoUrl = profileImage.downloadUrl;
                                      updateData['photoUrl'] =
                                          profileImage.downloadUrl;
                                      profileImage = null;
                                    }
                                    if ((emailController.text.length ?? 0) >
                                        0) {
                                      try {
                                        await firebaseUser
                                            .updateEmail(emailController.text);
                                        updateData['email'] =
                                            emailController.text;
                                      } on PlatformException catch (ee) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => OkDialog(
                                            title: AppLocalizations.of(context)
                                                .translate('Error'),
                                            content: ee.message,
                                          ),
                                        );
                                      }
                                    }
                                    if ((nameController.text.length ?? 0) > 0) {
                                      uInfo ??= UserUpdateInfo();
                                      uInfo.displayName = nameController.text;
                                      updateData['displayName'] =
                                          nameController.text;
                                    }
                                    if ((phoneController.text.length ?? 0) >
                                        0) {
                                      updateData['phoneNumber'] =
                                          phoneController.text;
                                    }
                                    if (updateData.length > 0) {
                                      await Firestore.instance
                                          .collection('/users')
                                          .document(databaseUser.uid)
                                          .updateData(updateData);
                                    }
                                    if ((passwordController.text.length ?? 0) >
                                        0) {
                                      await firebaseUser.updatePassword(
                                          passwordController.text);
                                    }
                                    if (uInfo != null) {
                                      await firebaseUser.updateProfile(uInfo);
                                      firebaseUser.reload();
                                    }
                                  } on PlatformException catch (ee) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => OkDialog(
                                        title: AppLocalizations.of(context)
                                            .translate('Error'),
                                        content: ee.message,
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      isUpdating.value = false;
                                    });
                                  }
                                },
                                child: Text(AppLocalizations.of(context)
                                    .translate('Apply changes')),
                              )
                            ],
                          )
                        : Container(
                            child: Text('Unauthorized'),
                          )),
              );
            },
          );
        },
      ),
    );
  }
}

class AddAddressPage extends StatelessWidget {
  Completer<GoogleMapController> _controller = Completer();
  ValueNotifier<bool> isLocationGranted = ValueNotifier(false);
  ValueNotifier<bool> isLocationEnabled = ValueNotifier(false);
  ValueNotifier<LatLng> markedPosition = ValueNotifier(null);
  ValueNotifier<String> markedPositionDisplayname = ValueNotifier(null);
  @override
  void checkPermissions() {
    Permission.location.serviceStatus
        .then((value) => isLocationEnabled.value = value.isEnabled);
    Permission.location.status.then((value) {
      isLocationGranted.value = value.isGranted;
      if (!value.isGranted) {
        Permission.location.request().then((value) {
          print(value);
          isLocationGranted.value = value.isGranted;
        });
      }
    });
  }

  Future<void> gotoPosition(CameraPosition camPos, BuildContext context) async {
    try {
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(camPos));
      markedPosition.value = camPos.target;
      Geolocator()
          .placemarkFromCoordinates(
              camPos.target.latitude, camPos.target.longitude)
          .then((value) {
        if (value?.first != null) {
          markedPositionDisplayname.value =
              '${value.first.country}, ${value.first.administrativeArea}, ${value.first.thoroughfare}\n ${AppLocalizations.of(context).translate('longitude')}: ${value.first.position.longitude} ${AppLocalizations.of(context).translate('latitude')}: ${value.first.position.latitude}';
        } else {
          markedPositionDisplayname.value = null;
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Widget build(BuildContext context) {
    checkPermissions();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('Add address')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12),
                      height: 40,
                      child: TextField(
                        decoration: kOutlineInputText.copyWith(
                            hintText: AppLocalizations.of(context)
                                .translate('Address name(Home, Work..)')),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12),
                      height: 40,
                      child: TextField(
                        decoration: kOutlineInputText.copyWith(
                            hintText:
                                AppLocalizations.of(context).translate('Name')),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12),
                      height: 40,
                      child: TextField(
                        decoration: kOutlineInputText.copyWith(
                            hintText: AppLocalizations.of(context)
                                .translate('Address')),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12),
                      height: 40,
                      child: TextField(
                        decoration: kOutlineInputText.copyWith(
                            hintText: AppLocalizations.of(context)
                                .translate('Phone')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 12),
                      child: ValueListenableBuilder<String>(
                          valueListenable: markedPositionDisplayname,
                          builder: (context, value, child) => Text(
                                value ??
                                    AppLocalizations.of(context)
                                        .translate('Map address'),
                              )),
                    ),
                    Expanded(
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isLocationEnabled,
                        builder: (context, isLocationEnabled, child) {
                          return ValueListenableBuilder<bool>(
                            valueListenable: isLocationGranted,
                            builder: (context, value, child) {
                              return Stack(
                                children: [
                                  ValueListenableBuilder<LatLng>(
                                    valueListenable: markedPosition,
                                    builder: (context, marker, child) =>
                                        GoogleMap(
                                      markers: marker != null
                                          ? Set<Marker>.from([
                                              Marker(
                                                position: marker,
                                                markerId: MarkerId(
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            'Delivery address')),
                                                infoWindow: InfoWindow(
                                                  title: AppLocalizations.of(
                                                          context)
                                                      .translate(
                                                          'Delivery address'),
                                                ),
                                                visible: true,
                                              )
                                            ])
                                          : null,
                                      onMapCreated: (controller) =>
                                          _controller.complete(controller),
                                      onTap: (argument) {
                                        gotoPosition(
                                            CameraPosition(
                                              target: argument,
                                              bearing: 180,
                                              tilt: 0,
                                              zoom: 18,
                                            ),
                                            context);
                                      },
                                      myLocationEnabled: value,
                                      mapType: MapType.hybrid,
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(41.638645, 42.987036),
                                        bearing: 180,
                                        tilt: 0,
                                        zoom: 18,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      if (!value)
                                        Container(
                                          child: Text(AppLocalizations.of(
                                                  context)
                                              .translate(
                                                  'Location permission not granted')),
                                          decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(1))),
                                        ),
                                      if (!isLocationEnabled)
                                        Container(
                                          child: Text(
                                              AppLocalizations.of(context)
                                                  .translate(
                                                      'Location not enabled')),
                                          decoration: BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(1))),
                                        ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(),
            FlatButton(
              child: Text(AppLocalizations.of(context).translate('Add')),
              onPressed: () {
                checkPermissions();
              },
            )
          ],
        ),
      ),
    );
  }
}
