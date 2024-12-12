import 'package:datn/database/firestore/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:datn/model/user/user.dart' as model_user;


class UpdateEducation extends StatefulWidget {
  const UpdateEducation({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UpdateEducationState();
  }
}

class _UpdateEducationState extends State<UpdateEducation> {
  late TextEditingController universityController;
  late TextEditingController majorController;
  late TextEditingController yearController;

  @override
  void initState() {
    super.initState();
    initInfo();
  }

  initInfo() {
    // final model_user.User sendUser=Provider<model_user.User>(context);
    model_user.User sendUser =
        Provider.of<model_user.User>(context, listen: false);

    universityController = TextEditingController(
        text: (sendUser.education?.university != null)
            ? (sendUser.education!.university)
            : (''));
    majorController = TextEditingController(
        text: (sendUser.education?.major != null)
            ? (sendUser.education!.major)
            : (''));
    yearController = TextEditingController(
        text: (sendUser.education?.year != null)
            ? (sendUser.education!.year)
            : (''));
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
          // model_user.User user = Provider.of<model_user.User>(context);

          return Scaffold(
            appBar: AppBar(
              title: const Text('Trình độ học vấn'),
            ),
            body: SingleChildScrollView(
              child: Center(
                  child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        controller: universityController,
                        obscureText: false,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.background,
                          border: const OutlineInputBorder(),
                          labelText: 'Trường Đại Học',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.name,
                        controller: majorController,
                        obscureText: false,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.background,
                          border: const OutlineInputBorder(),
                          labelText: 'Ngành học',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        enabled: true,
                        keyboardType: TextInputType.name,
                        controller: yearController,
                        obscureText: false,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.background,
                          border: const OutlineInputBorder(),
                          labelText: 'Năm học',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      OutlinedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.primary),
                            foregroundColor: MaterialStateProperty.all(
                                Theme.of(context).colorScheme.background)),
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
                                      onPressed: () =>
                                          Navigator.pop(context, 'Cancel'),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        model_user.Education education =
                                            model_user.Education(
                                                university:
                                                    (universityController
                                                                .text !=
                                                            "")
                                                        ? universityController
                                                            .text
                                                        : null,
                                                major: (majorController.text !=
                                                        "")
                                                    ? majorController.text
                                                    : null,
                                                year: (yearController.text !=
                                                        "")
                                                    ? yearController.text
                                                    : null);
                                        firestoreService.updateEducation(
                                           education);
                                        Navigator.pop(context, 'OK');
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              });
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: Text(
                            'Cập nhật',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  ),
                ),
              )),
            ),
          );
        },
      ),
    );
  }
}
