import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datn/database/firestore/firestore_service.dart';
import 'package:datn/database/storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datn/model/user/user.dart' as model_user;
import 'package:provider/provider.dart';
import '../../database/auth/firebase_auth_service.dart';

List<String> genders = ['Nam', 'Nữ', 'Khác'];

class UpdateInfoLearner extends StatefulWidget {
  const UpdateInfoLearner({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UpdateInfoLearnerState();
  }
}

class _UpdateInfoLearnerState extends State<UpdateInfoLearner> {
  String dropDownGender = genders.first;
  late TextEditingController nameController;
  late TextEditingController dateController;
  late TextEditingController phoneController;
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isEdit = false;
  FirebaseAuthService authService = FirebaseAuthService();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirestoreService firestoreService = FirestoreService();
  FirebaseStorageService firebaseStorageService = FirebaseStorageService();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    dateController.dispose();
    phoneController.dispose();
  }

  @override
  void initState() {
    super.initState();
    initUserInfo();
  }

  void initUserInfo() {
    model_user.User userInit =
        Provider.of<model_user.User>(context, listen: false);
    nameController = TextEditingController(text: userInit.displayName);
    dateController = TextEditingController(
        text: (userInit.born != null)
            // ? model_user.User.convertDateTime(userInit.born!)
            ? DateFormat('yyyy-MM-dd').format(userInit.born!.toDate())
            : '');
    phoneController = TextEditingController(text: userInit.phone);
  }

  @override
  Widget build(BuildContext context) {
    model_user.User user = Provider.of<model_user.User>(context);
    dropDownGender = (user.gender != null) ? user.gender! : 'Nam';
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Cập nhật thông tin người học'),
      ),
      body: Builder(
        builder: (BuildContext context) => SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: firebaseStorageService.uploadImage,
                    child: StreamBuilder<model_user.User>(
                        stream: firestoreService.user(auth.currentUser!.uid),
                        builder:
                            (context, AsyncSnapshot<model_user.User> snapshot) {
                          model_user.User? user = snapshot.data;
                          if (user != null) {
                            return CircleAvatar(
                                backgroundImage: (user.photoUrl != null)
                                    ? NetworkImage(user.photoUrl!)
                                    : const AssetImage('assets/bear.jpg')
                                        as ImageProvider,
                                radius: 50);
                          } else {
                            return const CircleAvatar(
                              backgroundImage: AssetImage('assets/bear.jpg'),
                              radius: 50,
                            );
                          }
                        }),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            isEdit = !isEdit;
                          });
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Sửaa')),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          readOnly: !isEdit,
                          keyboardType: TextInputType.name,
                          controller: nameController,
                          obscureText: false,
                          decoration: InputDecoration(
                            filled: isEdit,
                            border: const OutlineInputBorder(),
                            labelText: 'Họ và tên',
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          readOnly: !isEdit,
                          validator: (String? phoneNumber) {
                            if (phoneNumber == null || phoneNumber.isEmpty) {
                              return null;
                            } else {
                              // You may need to change this pattern to fit your requirement.
                              // I just copied the pattern from here: https://regexr.com/3c53v
                              const pattern =
                                  r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$';
                              final regExp = RegExp(pattern);

                              if (!regExp.hasMatch(phoneNumber)) {
                                return 'Không đúng định dạng';
                              }
                              return null;
                            }
                          },
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          obscureText: false,
                          decoration: InputDecoration(
                            filled: isEdit,
                            border: const OutlineInputBorder(),
                            labelText: 'Số điện thoại',
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          initialValue: auth.currentUser?.email,
                          readOnly: true,
                          keyboardType: TextInputType.emailAddress,
                          obscureText: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Địa chỉ email',
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text('Giới tính'),
                        const SizedBox(
                          height: 10,
                        ),
                        DropdownMenu<String>(
                          enabled: isEdit,
                          initialSelection: dropDownGender,
                          onSelected: (String? gender) {
                            dropDownGender = gender!;
                          },
                          dropdownMenuEntries: genders
                              .map((value) => DropdownMenuEntry<String>(
                                  value: value, label: value))
                              .toList(),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                            // validator: validateEmail,
                            controller: dateController,
                            readOnly: true,
                            keyboardType: TextInputType.datetime,
                            obscureText: false,
                            decoration: InputDecoration(
                              filled: isEdit,
                              border: const OutlineInputBorder(),
                              labelText: 'Sinh nhật',
                            ),
                            onTap: !isEdit
                                ? null
                                : () async {
                                    DateTime? pickedDate = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1950),
                                        lastDate: DateTime.now());
                                    if (pickedDate != null) {
                                      String formattedDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(pickedDate);
                                      dateController.text = formattedDate;
                                    }
                                  }),
                        const SizedBox(
                          height: 20,
                        ),
                        OutlinedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.primary),
                              foregroundColor: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.background)),
                          onPressed: isEdit
                              ? () {
                            if(dateController.text==null || dateController.text==''){
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hãy cập nhật ngày sinh")));
                            }else{

                            }
                                  firestoreService.updateInfo(
                                      nameController.text,
                                      phoneController.text,
                                      Timestamp.fromDate(
                                          DateTime.parse(dateController.text)),
                                      dropDownGender);
                                  setState(() {
                                    isEdit = false;
                                  });
                                }
                              : null,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: Text(
                              'Cập nhật',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
