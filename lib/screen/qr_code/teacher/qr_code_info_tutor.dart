import 'dart:io';

import 'package:datn/screen/qr_code/student/qr_scan_image_learner.dart';
import 'package:datn/screen/qr_code/teacher/qr_scan_image_tutor.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:datn/screen/qr_code/student/qr_screen_scanner_info_learner.dart';
import 'package:datn/screen/qr_code/teacher/qr_screen_scanner_info_tutor.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scan/scan.dart';
import 'package:images_picker/images_picker.dart';
import 'package:datn/model/user/user.dart' as model_user;
import 'dart:convert';
import 'package:datn/screen/qr_code/components/qr_code_view.dart';

class QrCodeInfoTutor extends StatefulWidget {
  @override
  _QrCodeInfoTutorState createState() => _QrCodeInfoTutorState();
}

class _QrCodeInfoTutorState extends State<QrCodeInfoTutor> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    model_user.User user = Provider.of<model_user.User>(context);
    var info = {"uid": user.uid, "type": 'tutor'};
    String jsonInfo = user.uid != null ? jsonEncode(info) : "";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Wrap(
            children: [
              Center(child: Text('Mã QR của tôi')),
              Center(child: QRCodeView(text: jsonInfo)),
              Center(
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return Provider.value(
                            value: user,
                            child: const DashBoardQrScannerTutor());
                      }),
                    );
                  },
                  icon: const Text('Quét Qr qua camera'),
                ),
              ),
              Center(
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) {
                        return Provider.value(
                            value: user, child: QrScanImgTutor());
                      }),
                    );
                  },
                  icon: const Text('Quét Qr qua ảnh'),
                ),
              )
            ],
          ),
         
        ],
      ),
    );
  }
}
