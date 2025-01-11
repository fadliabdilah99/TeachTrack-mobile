import 'package:absensi_apps/config/app_color.dart';
import 'package:absensi_apps/presentation/controller/c_user.dart';
import 'package:absensi_apps/presentation/controller/c_wallet.dart';
import 'package:absensi_apps/presentation/page/auth/login_page.dart';
import 'package:absensi_apps/presentation/page/homepage.dart';
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
                    ElevatedButton(
                      onPressed: transfer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Transfer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
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
            Container(
              padding: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.only(top: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(history[index]['description']!),
                      subtitle: Text('Tanggal: ${history[index]['date']}'),
                      trailing: Text('Rp. ${history[index]['amount']}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColor.primary
                  .withOpacity(0.7), // Gradasi halus untuk latar belakang
              AppColor.primary.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(
                30), // Membuat sudut atas bulat untuk gaya yang lebih lembut
            topRight: Radius.circular(30),
          ),
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _selectedIndex == 0
                      ? AppColor.chart
                      : Colors.transparent, // Efek perubahan warna saat dipilih
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (_selectedIndex == 0)
                      BoxShadow(
                        color: const Color.fromARGB(255, 216, 216, 216)
                            .withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                  ],
                ),
                child: const Icon(
                  Icons.home_sharp,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1
                      ? Colors.greenAccent
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (_selectedIndex == 1)
                      BoxShadow(
                        color: Colors.greenAccent.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                  ],
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _selectedIndex == 2
                      ? Colors.purpleAccent
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (_selectedIndex == 2)
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                  ],
                ),
                child: const Icon(
                  Icons.shopping_bag_rounded,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              label: 'shop',
            ),
          ],
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          elevation:
              12, // Menambahkan bayangan lebih dalam pada BottomNavigationBar
          showUnselectedLabels:
              true, // Menampilkan label pada item yang tidak dipilih
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      switch (_selectedIndex) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(),
            ),
          );
          break;
        case 1:
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
          break;
      }
    });
  }
}
