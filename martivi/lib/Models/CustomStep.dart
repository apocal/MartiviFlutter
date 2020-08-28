import 'package:flutter/material.dart';
import 'package:martivi/Models/enums.dart';

class CustomStep extends Step {
  final DeliveryStatus status;
  CustomStep({this.status, content, state, isActive, title,subtitle})
      : super(content: content, state: state, isActive: isActive, title: title,subtitle:subtitle);
}
