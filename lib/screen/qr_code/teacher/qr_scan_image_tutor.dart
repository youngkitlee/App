import 'dart:io';
import 'package:datn/screen/qr_code/student/info_learner.dart';
import 'package:datn/screen/tutor/update/tutor_update_info.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:scan/scan.dart';
import 'package:images_picker/images_picker.dart';
import 'package:datn/model/user/user.dart' as model_user;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:datn/database/firestore/firestore_service.dart';
import 'dart:convert';
import 'package:datn/screen/learner/search_tutor/tutor_show_info.dart';
import 'package:datn/screen/tutor/teaching/class_info_tutor.dart';

class QrScanImgTutor extends StatefulWidget {
  @override
  _QrScanImgTutorState createState() => _QrScanImgTutorState();
}

class _QrScanImgTutorState extends State<QrScanImgTutor> {
  String qrcode = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    model_user.User user = Provider.of<model_user.User>(context);
    FirebaseAuth auth = FirebaseAuth.instance;
    FirestoreService firestoreService = FirestoreService();
    void _initInfo(dynamic scanData) async {
      var dataScan = jsonDecode(scanData);
      if (dataScan['type'] == 'learner') {
        var userFetch = await firestoreService.getUserById(dataScan['uid']);
        if (userFetch != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return Provider.value(
                  value: user,
                  child: ShowInfoLearner(learner: userFetch));
            }),
          );
          return;
        }
      }
      if (dataScan['type'] == 'class') {
        var dataFetch = await firestoreService.getClassByIdLearner(dataScan['uid']);
        if (dataFetch != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Provider(
                create: (context) => dataFetch,
                builder: (context, child) => ClassInfoTutorScreen());
          }));
          return;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quét QR qua ảnh'),
      ),
      body: Column(
        children: [
          Wrap(
            children: [
              Padding(padding: EdgeInsets.all(10.0)),
              Center(
                child: ElevatedButton(
                  child: Text("Chọn ảnh quét QR"),
                  onPressed: () async {
                    List<Media>? res = await ImagesPicker.pick();
                    if (res != null) {
                      String? str = await Scan.parse(res[0].path);
                      if (str != null) {
                        setState(() {
                          qrcode = str;
                          if (qrcode != null) {
                            _initInfo(qrcode);
                          }
                        });
                      }
                    }
                  },
                ),
              )
            
            ],
          ),
        
        ],
      ),
    );
  }

}
