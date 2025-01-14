import 'package:absensi_apps/config/app_color.dart';
import 'package:absensi_apps/config/app_format.dart';
import 'package:absensi_apps/data/model/wallet.dart';
import 'package:absensi_apps/presentation/controller/c_user.dart';
import 'package:absensi_apps/presentation/controller/c_wallet.dart';
import 'package:absensi_apps/presentation/page/auth/login_page.dart';
import 'package:absensi_apps/presentation/page/homepage.dart';
import 'package:absensi_apps/presentation/page/payment/transfer.dart';
import 'package:d_view/d_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  int _selectedIndex = 1;
  bool _isLoading = false;
  final cWallet = Get.put(Cwallet());
  final cUser = Get.put(Cuser());

  bool showDetails = false;
  int selectedHistoryIndex = -1;

  final controllerIdHistory = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // Dummy data for saldo and history
  double saldo = 5000;
  List<Map<String, String>> history = [
    {
      'date': '2025-01-01',
      'description': 'Transfer ke User1',
      'amount': '-200'
    },
    {'date': '2025-01-02', 'description': 'Top-up', 'amount': '+5000'},
    {
      'date': '2025-01-03',
      'description': 'Transfer ke User2',
      'amount': '-1000'
    },
  ];

  Future<void> refresh() async {
    final userId = cUser.data.idUser ?? "";
    await cWallet.getsaldo(userId);
    await cWallet.getpemasukan(userId);
    await cWallet.getpengeluaran(userId);
    await cWallet.getList(
      userId,
    );

    setState(() {
      _isLoading = false;
    });
  }

  // Method to handle Transfer action
  void transfer() {
    // Implement transfer logic here
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Transfer berhasil!')));
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ZIEWalet'),
        backgroundColor: AppColor.primary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 8,
              margin: EdgeInsets.only(bottom: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Saldo',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp. ${cWallet.saldo}',
                          style: const TextStyle(
                              fontSize: 32,
                              color: AppColor.primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    // ElevatedButton(
                    //   onPressed: transfer,
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: AppColor.primary,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //   ),
                    //   child: const Text(
                    //     'Transfer',
                    //     style: TextStyle(color: Colors.white),
                    //   ),
                    // ),
                    TextButton.icon(
                      onPressed: () {
                        Get.to(Transfer());
                      },
                      icon: const Icon(Icons.transfer_within_a_station),
                      label: const Text('Transfer'),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          AppColor.primary,
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Card for Pengeluaran
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pengeluaran',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp. ${cWallet.pengeluaran}',
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.red,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                // Card for Pemasukan
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pemasukan',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp. ${cWallet.pemasukan}',
                          style: const TextStyle(
                              fontSize: 20,
                              color: Colors.green,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // History Section
            const Text('History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GetBuilder<Cwallet>(
              builder: (_) {
                if (_.loading) return DView.loadingCircle();
                if (_.list.isEmpty) return DView.empty('KOSONGG');
                return RefreshIndicator(
                  onRefresh: () async => refresh(),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _.list.length,
                    itemBuilder: (context, index) {
                      Wallet wallet = _.list[index];
                      return Column(
                        children: [
                          Card(
                            margin: const EdgeInsets.all(10.0),
                            elevation: 5.0,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  showDetails = !showDetails;
                                  selectedHistoryIndex = index;
                                  controllerIdHistory.text =
                                      wallet.id.toString()!;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        (wallet.jenis == 'uang keluar')
                                            ? const Icon(Icons.arrow_drop_down,
                                                color: Colors.green)
                                            : const Icon(Icons.arrow_drop_up,
                                                color: Colors.red),
                                        const SizedBox(width: 10.0),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              wallet.jenis!,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        (wallet.jenis == 'uang masuk')
                                            ? Text(
                                                '+ ${AppFormat.currency(wallet.nominal.toString()!)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                ),
                                              )
                                            : Text(
                                                '- ${AppFormat.currency(wallet.nominal.toString()!)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              ),
                                        Text(wallet.jenis!),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
