import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:martivi/Constants/Constants.dart';
import 'package:martivi/Localizations/app_localizations.dart';
import 'package:martivi/Models/Address.dart';
import 'package:martivi/Models/CustomStep.dart';
import 'package:martivi/Models/Order.dart';
import 'package:martivi/Models/Product.dart';
import 'package:martivi/Models/User.dart';
import 'package:martivi/Models/enums.dart';
import 'package:martivi/Uitls/ExportInvoice.dart';
import 'package:martivi/ViewModels/MainViewModel.dart';
import 'package:martivi/Views/UserPage.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'UnipayCheckoutPage.dart';

class OrderDetailPage extends StatefulWidget {
  final Order orderR;
  OrderDetailPage({this.orderR});

  @override
  _OrderDetailPageState createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  ValueNotifier<bool> paymentStatusChecking=ValueNotifier(false);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection('/orders')
          .document(widget.orderR.documentId)
          .snapshots(),
      builder: (context, snapshot) {
        Order order;
        if (snapshot.data?.data != null) {
          order = Order.fromJson(snapshot.data.data);
          order.documentId = snapshot.data.documentID;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${AppLocalizations.of(context).translate('Order')} ${AppLocalizations.of(context).translate('id')}: ${widget.orderR.orderId?.toString() ?? ''}',
              style: TextStyle(color: kIcons),
            ),
          ),
          body: snapshot.data?.data == null
              ? snapshot.connectionState == ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(kPrimary),
                      ),
                    )
                  : Center(
                      child: Text('No data'),
                    )
              : SingleChildScrollView(
                  child: Consumer<MainViewModel>(builder: (context, viewModel, child) => ValueListenableBuilder<User>(valueListenable: viewModel.databaseUser,builder: (context, databaseUser, child) =>  Column(
                    children: [
                      ExpansionTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                                '${order.products.length} ${AppLocalizations.of(context).translate('Product')} | ₾${order.products.fold(0, (previousValue, element) => previousValue + element.price * element.quantity)}'),
                          ],
                        ),
                        leading: Text('Ordered products'),
                        children: order.products
                            .map((e) => OrderedProductWidget(
                          productForm: e,
                        ))
                            .toList(),
                      ),
                      StreamBuilder<DocumentSnapshot>(
                        stream: Firestore.instance
                            .collection('/users')
                            .document(order.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            User user = User.fromMap(snapshot.data.data);
                            return ExpansionTile(
                              title: Text(AppLocalizations.of(context)
                                  .translate('User')),
                              subtitle: Text(user.displayName ??
                                  user.email ??
                                  (user.isAnonymous
                                      ? AppLocalizations.of(context)
                                      .translate('Guest')
                                      : AppLocalizations.of(context)
                                      .translate('Unknown'))),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Material(
                                    type: MaterialType.transparency,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UserPage(
                                                user: user,
                                              ),
                                            ));
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                        children: [
                                          (user?.photoUrl?.length ?? 0) > 0
                                              ? Container(
                                            width: 100,
                                            height: MediaQuery.of(context)
                                                .size
                                                .height /
                                                4,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(
                                                        user.photoUrl))),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                      colors: [
                                                        Colors.black54,
                                                        Colors.black54,
                                                        Colors.transparent
                                                      ],
                                                      begin: Alignment
                                                          .bottomCenter,
                                                      end: Alignment
                                                          .topCenter,
                                                      stops: [
                                                        0,
                                                        .15,
                                                        .5
                                                      ])),
                                              child: Container(
                                                  padding:
                                                  EdgeInsets.all(12),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .end,
                                                    children: [
                                                      Text(
                                                        user.displayName ??
                                                            (user.isAnonymous
                                                                ? AppLocalizations.of(
                                                                context)
                                                                .translate(
                                                                'Guest')
                                                                : ''),
                                                        style: TextStyle(
                                                            fontWeight:
                                                            FontWeight
                                                                .bold,
                                                            color: kIcons,
                                                            fontSize: 24),
                                                      ),
                                                      Text(
                                                        user.email ?? '',
                                                        style: TextStyle(
                                                            color:
                                                            kIcons),
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          )
                                              : Column(
                                            children: [
                                              Icon(
                                                FontAwesome.user,
                                                color:
                                                Colors.grey.shade600,
                                                size: 60,
                                              ),
                                              Text(user.displayName ??
                                                  (user.isAnonymous
                                                      ? AppLocalizations
                                                      .of(context)
                                                      .translate(
                                                      'Guest')
                                                      : '')),
                                            ],
                                          ),
                                          Divider(
                                            height: 30,
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.info_outline,
                                                      color:
                                                      Colors.grey.shade600,
                                                    ),
                                                    SizedBox(
                                                      width: 20,
                                                    ),
                                                    Flexible(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(
                                                            AppLocalizations.of(
                                                                context)
                                                                .translate(
                                                                'User info'),
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey
                                                                    .shade700),
                                                          ),
                                                          Divider(),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                            children: [
                                                              Text(AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'User type')),
                                                              Text(AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(EnumToString
                                                                  .parse(user
                                                                  .role)))
                                                            ],
                                                          ),
                                                          Divider(),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                            children: [
                                                              Text(AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'User name')),
                                                              Text(user
                                                                  .displayName ??
                                                                  (user.isAnonymous
                                                                      ? AppLocalizations.of(
                                                                      context)
                                                                      .translate(
                                                                      'Guest')
                                                                      : '')),
                                                            ],
                                                          ),
                                                          Divider(),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                            children: [
                                                              Text(AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'E-mail')),
                                                              SelectableText(
                                                                  user.email ??
                                                                      ''),
                                                            ],
                                                          ),
                                                          Divider(),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                            children: [
                                                              Text(AppLocalizations
                                                                  .of(
                                                                  context)
                                                                  .translate(
                                                                  'Phone')),
                                                              SelectableText(
                                                                user.phoneNumber ??
                                                                    '',
                                                                onTap:
                                                                    () async {
                                                                  if (await canLaunch(
                                                                      'tel:${user.phoneNumber}')) {
                                                                    launch(
                                                                        'tel:${user.phoneNumber}');
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            );
                          } else {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(kPrimary),
                                ),
                              );
                            } else
                              return SizedBox();
                          }
                        },
                      ),
                      ExpansionTile(
                        title: Text(AppLocalizations.of(context)
                            .translate('Delivery address')),
                        subtitle: Text(order.deliveryAddress.addressName),
                        children: [
                          Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 4, top: 4, right: 4, bottom: 4),
                                child: Material(
                                  borderRadius: BorderRadius.circular(4),
                                  elevation: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Text(AppLocalizations.of(context)
                                                .translate('Name')),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 24),
                                              child: Text(
                                                  order.deliveryAddress.name),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Text(AppLocalizations.of(context)
                                                .translate('Phone')),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 24),
                                              child: Text(order.deliveryAddress
                                                  .mobileNumber),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.start,
                                          children: [
                                            Text(AppLocalizations.of(context)
                                                .translate('Address')),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 24),
                                              child: Text(order
                                                  .deliveryAddress.address),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(3),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MapWidget(
                                    address: order.deliveryAddress,
                                    onMapTap: (pos) {
                                      Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            opaque: false,
                                            pageBuilder: (context, animation,
                                                secondaryAnimation) {
                                              return Material(
                                                type: MaterialType.transparency,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 5,
                                                      right: 5,
                                                      top: 110,
                                                      bottom: 5),
                                                  child: MapWidget(
                                                    address:
                                                    order.deliveryAddress,
                                                    onMapTap: (pos) {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ));
                                    },
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Material(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2)),
                                elevation: 4,
                                color: Colors.grey.shade300,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    children: [
                                      Text(AppLocalizations.of(context)
                                          .translate('Order status')),
                                      Text(AppLocalizations.of(context).translate(
                                          EnumToString.parse(order
                                              .deliveryStatusSteps.entries
                                              .firstWhere(
                                                  (element) => element.value.isActive)
                                              .key))),
                                    ],
                                  ),
                                )),
                            ValueListenableBuilder(valueListenable: paymentStatusChecking,child: Material(color: Colors.grey.shade300,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2)),
                              child: RawMaterialButton(shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2)),onPressed:databaseUser.role==UserType.admin? ()async{

                                if(paymentStatusChecking.value)return;
                                try{
                                  paymentStatusChecking.value=true;
                                  await http.post(
                                      '${viewModel.prefs.getString('ServerBaseAddress')}CheckoutResult',
                                      body: jsonEncode(order.toCheckoutJson(context)),
                                      headers: {
                                        'Content-Type': 'application/json'
                                      });
                                }
                                catch(e){

                                }
                                finally
                                {
                                  paymentStatusChecking.value=false;
                                }

                              }:()async{
                                if(paymentStatusChecking.value)return;
                                try{
                                  paymentStatusChecking.value=true;
                                  var res = await http.post(
                                      '${viewModel.prefs.getString('ServerBaseAddress')}Api/Orders/CheckoutFlutter',
                                      body: jsonEncode(order.toCheckoutJson(context)),
                                      headers: {
                                        'Content-Type': 'application/json'
                                      });
                                  if (res.statusCode == 200) {
                                    var decoded = jsonDecode(res.body)
                                    as Map<String, dynamic>;
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UnipayCheckoutPage(order: order,
                                                  createOrderResult:
                                                  decoded,
                                                )));
                                  }
                                }
                                catch(e){
print(e);
                                }
                                finally
                                {
                                  paymentStatusChecking.value=false;
                                }
                              },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    children: [
                                      Text(AppLocalizations.of(context)
                                          .translate('Payment status')),
                                      Text(AppLocalizations.of(context).translate(
                                          EnumToString.parse(order.paymentStatus))),
                                    ],
                                  ),
                                ),
                              ),
                            ),builder: (context, value, child) {
                              return  Stack(
                                children: [
                                  child,
                                  if(paymentStatusChecking.value)Positioned.fill(child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(kPrimary),)))
                                ],
                              );
                            },),

                          ],
                        ),
                      ),
                      DeliveryStatusSteps(
                        order: order,
                      ),
if(databaseUser?.role==UserType.admin) FlatButton(child: Text(AppLocalizations.of(context).translate('Export pdf')),onPressed: ()async {
 var res = await exportInvoice(pageFormat: PdfPageFormat.a4,order: order,bContext: context);
 final Directory appDocDir = await getApplicationDocumentsDirectory();
 final String appDocPath = appDocDir.path;
 final File f = File(appDocPath+'/'+'doc.pdf');
 await f.writeAsBytes(res);
 OpenFile.open(f.path);
},),

                    ],
                  )),),
                ),
        );
      },
    );
  }
}

class DeliveryStatusSteps extends StatefulWidget {
  final Order order;
  DeliveryStatusSteps({this.order});
  @override
  _DeliveryStatusStepsState createState() => _DeliveryStatusStepsState();
}

class _DeliveryStatusStepsState extends State<DeliveryStatusSteps> {
  List<CustomStep> steps;

  @override
  Widget build(BuildContext context) {
    return Consumer<MainViewModel>(
      builder: (context, viewModel, child) => ValueListenableBuilder<User>(
        valueListenable: viewModel.databaseUser,
        builder: (context, databaseUser, child) {
          steps = [
            if (widget.order.deliveryStatusSteps.containsKey(DeliveryStatus.Pending))
              CustomStep(
                  status: DeliveryStatus.Pending,subtitle:Text(DateFormat.yMd().add_Hms().format((widget
                              .order
                              .deliveryStatusSteps[DeliveryStatus.Pending]
                              .creationTimestamp as Timestamp)
                          ?.toDate() ??
                      DateTime(0000))),
                  content: Text(''),
                  state: widget.order
                      .deliveryStatusSteps[DeliveryStatus.Pending].stepState,
                  isActive: widget.order
                      .deliveryStatusSteps[DeliveryStatus.Pending].isActive,
                  title: Text(AppLocalizations.of(context)
                      .translate(EnumToString.parse(DeliveryStatus.Pending)))),
            if (widget.order.deliveryStatusSteps
                .containsKey(DeliveryStatus.Accepted))
              CustomStep(
                  status: DeliveryStatus.Accepted,subtitle:Text(widget
              .order
              .deliveryStatusSteps[DeliveryStatus.Accepted]
              .creationTimestamp==null?'': DateFormat.yMd().add_Hms().format((widget
                              .order
                              .deliveryStatusSteps[DeliveryStatus.Accepted]
                              .creationTimestamp as Timestamp)
                          ?.toDate() ??
                      DateTime(0000))),
                  content: Text(''),
                  state: widget.order
                      .deliveryStatusSteps[DeliveryStatus.Accepted].stepState,
                  isActive: widget.order
                      .deliveryStatusSteps[DeliveryStatus.Accepted].isActive,
                  title: Text(
                      AppLocalizations.of(context).translate(EnumToString.parse(DeliveryStatus.Accepted)))),
            if (widget.order.deliveryStatusSteps
                .containsKey(DeliveryStatus.Completed))
              CustomStep(
                  status: DeliveryStatus.Completed,
                  content: Text(''),subtitle: Text(widget
              .order
              .deliveryStatusSteps[DeliveryStatus.Completed]
              .creationTimestamp==null?'': DateFormat.yMd().add_Hms().format((widget
                              .order
                              .deliveryStatusSteps[DeliveryStatus.Completed]
                              .creationTimestamp as Timestamp)
                          ?.toDate() ??
                      DateTime(0000))),
                  state: widget.order
                      .deliveryStatusSteps[DeliveryStatus.Completed].stepState,
                  isActive: widget.order
                      .deliveryStatusSteps[DeliveryStatus.Completed].isActive,
                  title: Text(
                      AppLocalizations.of(context).translate(EnumToString.parse(DeliveryStatus.Completed)))),
            if (widget.order.deliveryStatusSteps
                .containsKey(DeliveryStatus.Canceled))
              CustomStep(
                  status: DeliveryStatus.Canceled,
                  content: Text(DateFormat.yMd().add_Hms().format((widget
                              .order
                              .deliveryStatusSteps[DeliveryStatus.Canceled]
                              .creationTimestamp as Timestamp)
                          ?.toDate() ??
                      DateTime(0000))),
                  state: widget.order
                      .deliveryStatusSteps[DeliveryStatus.Canceled].stepState,
                  isActive: widget.order
                      .deliveryStatusSteps[DeliveryStatus.Canceled].isActive,
                  title: Text(
                      AppLocalizations.of(context).translate(EnumToString.parse(DeliveryStatus.Canceled)))),
          ];
          return Stepper(key: Key(Random.secure().nextDouble().toString()), currentStep:steps.indexOf(steps.firstWhere((element) => element.isActive)),
            onStepTapped: databaseUser?.role == UserType.admin
                ? (index) {
                    widget.order.deliveryStatusSteps.entries.forEach((element) {
                      element.value.isActive = false;
                      switch (steps[index].status) {
                        case DeliveryStatus.Pending:
                          {
                            widget
                                .order
                                .deliveryStatusSteps[DeliveryStatus.Pending]
                                .stepState = StepState.complete;
                            widget
                                .order
                                .deliveryStatusSteps[DeliveryStatus.Accepted]
                                .stepState = StepState.indexed;
                            widget
                                .order
                                .deliveryStatusSteps[DeliveryStatus.Completed]
                                .stepState = StepState.indexed;
                            break;
                          }
                        case DeliveryStatus.Accepted:
                          {
                             widget
                                .order
                                .deliveryStatusSteps[DeliveryStatus.Pending]
                                .stepState = StepState.complete;
                            widget
                                .order
                                .deliveryStatusSteps[DeliveryStatus.Accepted]
                                .stepState = StepState.complete;
                            widget
                                .order
                                .deliveryStatusSteps[DeliveryStatus.Completed]
                                .stepState = StepState.indexed;

                            break;
                          }
                        case DeliveryStatus.Completed:
                          {
                             widget
                                .order
                                .deliveryStatusSteps[DeliveryStatus.Pending]
                                .stepState = StepState.complete;
                            widget
                                .order
                                .deliveryStatusSteps[DeliveryStatus.Accepted]
                                .stepState = StepState.complete;
                            widget
                                .order
                                .deliveryStatusSteps[DeliveryStatus.Completed]
                                .stepState = StepState.complete;

                            break;
                          }
                        case DeliveryStatus.Canceled:
                          {
                             widget
                                .order
                                .deliveryStatusSteps[DeliveryStatus.Pending]
                                .stepState = StepState.indexed;
                            widget
                                .order
                                .deliveryStatusSteps[DeliveryStatus.Accepted]
                                .stepState = StepState.indexed;
                            widget
                                .order
                                .deliveryStatusSteps[DeliveryStatus.Completed]
                                .stepState = StepState.indexed;
                             widget
                                .order
                                .deliveryStatusSteps[DeliveryStatus.Canceled]
                                .stepState = StepState.error;
                            break;
                          }
                      }
                    });

                    if(steps[index].status!=DeliveryStatus.Canceled)
                      {
                        if (widget.order.deliveryStatusSteps
                            .containsKey(DeliveryStatus.Canceled)) {
                          widget.order.deliveryStatusSteps
                              .remove(DeliveryStatus.Canceled);
                        }
                      }

                    widget.order.deliveryStatusSteps[steps[index].status].creationTimestamp??=FieldValue.serverTimestamp();
                    widget.order.deliveryStatusSteps[steps[index].status]
                        .isActive = true;
                    widget.order.deliveryStatusSteps[steps[index].status]
                        .stepState = StepState.complete;
                    Firestore.instance
                        .collection('/orders')
                        .document(widget.order.documentId)
                        .updateData({
                      'deliveryStatusSteps': widget.order.deliveryStatusSteps
                          .map((key, value) =>
                              MapEntry(EnumToString.parse(key), value.toJson()))
                    });
                  }
                : null,
            controlsBuilder: (context, {onStepCancel, onStepContinue}) {
              return Container(
                child: Row(children: [
                 if(databaseUser?.role==UserType.admin&&widget.order.deliveryStatusSteps[DeliveryStatus.Canceled]?.isActive!=true) FlatButton(child: Text(AppLocalizations.of(context).translate('Cancel')),onPressed: (){
                                   widget.order.deliveryStatusSteps.forEach((key, value) {
                                     value.isActive=false;
                                   });
                                   widget.order.deliveryStatusSteps[DeliveryStatus.Canceled]=DeliveryStatusStep(creationTimestamp: FieldValue.serverTimestamp(),isActive: true,stepState: StepState.error);
                    Firestore.instance
                        .collection('/orders')
                        .document(widget.order.documentId)
                        .updateData({
                      'deliveryStatusSteps': widget.order.deliveryStatusSteps
                          .map((key, value) =>
                              MapEntry(EnumToString.parse(key), value.toJson()))
                    });
                 },)
                ],),
              );
            },
            steps: steps,
          );
        },
      ),
    );
  }
}

class MapWidget extends StatelessWidget {
  final Function(LatLng) onMapTap;
  final UserAddress address;
  const MapWidget({this.address, this.onMapTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height / 2.2,
      padding: EdgeInsets.only(left: 8, right: 8),
      child: Column(
        children: [
          Expanded(child: Builder(
            builder: (context) {
              Completer<GoogleMapController> _controller = Completer();
              return ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(4),
                child: GoogleMap(
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onTap: onMapTap,
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                  },
                  initialCameraPosition: CameraPosition(
                      bearing: 180,
                      tilt: 0,
                      zoom: 18,
                      target: LatLng(address.coordinates.latitude,
                          address.coordinates.longitude)),
                  markers: address.coordinates != null
                      ? Set<Marker>.from([
                          Marker(
                            position: LatLng(address.coordinates.latitude,
                                address.coordinates.longitude),
                            markerId: MarkerId(AppLocalizations.of(context)
                                .translate('Delivery address')),
                            infoWindow: InfoWindow(
                              title: AppLocalizations.of(context)
                                  .translate('Delivery address'),
                            ),
                            visible: true,
                          )
                        ])
                      : null,
                  mapType: MapType.hybrid,
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}

class OrderedProductWidget extends StatelessWidget {
  final ProductForm productForm;
  OrderedProductWidget({this.productForm});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 140,
          width: 160,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              image: DecorationImage(
                fit: BoxFit.cover,
                image:
                    NetworkImage(productForm?.images?.first?.downloadUrl ?? ''),
              )),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                productForm.localizedFormName[
                    AppLocalizations.of(context).locale.languageCode],
                style: TextStyle(
                    fontFamily: "Sans",
                    color: Colors.black87,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                productForm.localizedFormDescription[
                    AppLocalizations.of(context).locale.languageCode],
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.0,
                ),
              ),
              Text(
               '${AppLocalizations.of(context).translate('Quantity')}: ${productForm.quantity}',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.0,
                ),
              ),
              Text(
                '₾${productForm.price.toString()}',
                style: TextStyle(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
