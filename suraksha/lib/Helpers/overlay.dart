import 'package:flutter/material.dart';
import 'package:system_alert_window/system_alert_window.dart';

SystemWindowHeader overlayheader = SystemWindowHeader(
    title: SystemWindowText(
        text: "Cancel Alert", fontSize: 15, textColor: Colors.black45),
    padding: SystemWindowPadding.setSymmetricPadding(10, 10),
    buttonPosition: ButtonPosition.TRAILING);

SystemWindowBody overlaybody = SystemWindowBody(
  rows: [
    EachRow(
      columns: [
        EachColumn(
          text: SystemWindowText(
              text: 'Tap \"Cancel\" immediately to cancel the alert ',
              fontSize: 12,
              textColor: Colors.black45),
        )
      ],
      gravity: ContentGravity.CENTER,
    ),
  ],
  padding: SystemWindowPadding(left: 16, right: 16, bottom: 12, top: 12),
);

SystemWindowFooter overlaayfooter = SystemWindowFooter(
    buttons: [
      SystemWindowButton(
        text: SystemWindowText(
            text: "Cancel Alert", fontSize: 12, textColor: Colors.white),
        tag: "cancel_alert",
        width: 0,
        padding: SystemWindowPadding(left: 10, right: 10, bottom: 10, top: 10),
        height: SystemWindowButton.WRAP_CONTENT,
        decoration: SystemWindowDecoration(
            startColor: Color.fromRGBO(143, 148, 251, 1),
            endColor: Color.fromRGBO(143, 148, 251, .6),
            borderWidth: 0,
            borderRadius: 30.0),
      )
    ],
    padding: SystemWindowPadding(left: 16, right: 16, bottom: 12),
    decoration: SystemWindowDecoration(startColor: Colors.white),
    buttonsPosition: ButtonPosition.CENTER);
