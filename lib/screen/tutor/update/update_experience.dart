import 'package:datn/database/firestore/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:datn/model/user/user.dart' as model_user;


class UpdateExperience extends StatefulWidget {
  const UpdateExperience({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UpdateExperienceState();
  }
}

class _UpdateExperienceState extends State<UpdateExperience> {
  late TextEditingController experienceController;

  @override
  void initState() {
    super.initState();
    experienceController = TextEditingController();
    initInfo();
  }

  initInfo() {
    model_user.User sendUser =
        Provider.of<model_user.User>(context, listen: false);
    experienceController.text =
        (sendUser.experience != null) ? sendUser.experience! : "";
  }

  @override
  Widget build(BuildContext context) {
    FirestoreService firestoreService = FirestoreService();
    FirebaseAuth auth = FirebaseAuth.instance;
    return MultiProvider(
      providers: [
        StreamProvider<model_user.User>(
            create: (context) => firestoreService.user(auth.currentUser!.uid),
            initialData: model_user.User())
      ],
      child: Builder(
        builder: (context) {
          model_user.User user = Provider.of<model_user.User>(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Kinh nghiệm'),
            ),
            body: SingleChildScrollView(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          TextField(
                            controller: experienceController,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: OutlinedButton(
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('Xác nhận'),
                                          content: const Text(
                                              'Bạn chắc chắn với sự thay đổi này?'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  context, 'Cancel'),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                firestoreService
                                                    .updateExperience(
                                                        experienceController
                                                            .text);
                                                Navigator.pop(context, 'OK');
                                              },
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: const Text('Cập nhật')),
                          ),
                          const SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
