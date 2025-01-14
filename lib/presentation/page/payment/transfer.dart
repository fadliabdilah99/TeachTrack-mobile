import 'package:absensi_apps/config/app_color.dart';
import 'package:absensi_apps/data/model/wallet.dart';
import 'package:absensi_apps/data/source/source_wallet.dart';
import 'package:absensi_apps/presentation/controller/c_user.dart';
import 'package:absensi_apps/presentation/page/payment/wallet.dart';
import 'package:d_info/d_info.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ignore: camel_case_types
class Transfer extends StatefulWidget {
  const Transfer({super.key});

  @override
  State<Transfer> createState() => TransferState();
}

// ignore: camel_case_types
class TransferState extends State<Transfer> {
  String? selectedType;

  final cUser = Get.put(Cuser());

  final controllerid = TextEditingController();
  final controllernis = TextEditingController();
  final controllertotal = TextEditingController();
  final controllerketerangan = TextEditingController();
  final formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (cUser.data.idUser is! int) {
      print(
          "idUser is not an integer, resetting to default value or handling it accordingly.");
    }
  }

  void history() async {
    try {
      bool success = await SourceWallet.transfer(
        cUser.data.idUser.toString(), // Mengonversi idUser ke dalam string
        controllernis.text,
        controllertotal.text,
        controllerketerangan.text,
        context,
      );
      if (success) {
        DInfo.dialogSuccess(context, 'Berhasil menambakan data');
        DInfo.closeDialog(context, actionAfterClose: () {
          Get.off(() => const WalletPage());
        });
      } else {
        DInfo.dialogError(context, 'Gagal memasukkan data');
      }
    } catch (e) {
      print('Error: $e');
      // ignore: use_build_context_synchronously
      DInfo.dialogError(context, 'Terjadi kesalahan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColor.primary,
        // elevation: 4, // Set the elevation to add a shadow
        title: const Text(
          "Transfer",
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColor.secondary,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Form(
                key: formkey,
                child: Column(
                  children: [
                    DView.height(10),
                    Visibility(
                      visible: false,
                      child: TextFormField(
                        controller: controllerid,
                        decoration: const InputDecoration(
                          hintText: 'id',
                        ),
                        onChanged: (value) {
                          setState(() {
                            cUser.data.idUser = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: controllernis,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap isi nis';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        hintText: 'NIS penerima',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        prefixIcon: const Icon(
                          Icons.library_books_sharp,
                          color: AppColor.primary,
                        ),
                      ),
                    ),
                    DView.height(10),
                    TextFormField(
                      controller: controllertotal,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap isi Total';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        hintText: 'nominal',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        prefixIcon: const Icon(
                          Icons.monetization_on,
                          color: AppColor.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      maxLines: 4,
                      controller: controllerketerangan,
                      // obscureText: true,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        hintText: 'keterangan',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 16.0),
                        prefixIcon: const Icon(
                          Icons.book,
                          color: AppColor.primary,
                        ),
                      ),
                    ),
                    DView.height(30),
                    ElevatedButton(
                      onPressed: () {
                        if (formkey.currentState?.validate() ?? false) {
                          history();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        minimumSize: const Size(500, 50),
                      ),
                      child: const Text('Tambahkan',
                          style: TextStyle(color: AppColor.secondary)),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
