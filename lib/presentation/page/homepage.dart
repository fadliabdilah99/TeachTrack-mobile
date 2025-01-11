import 'dart:io';
import 'package:absensi_apps/config/api.dart';
import 'package:absensi_apps/config/app_color.dart';
import 'package:absensi_apps/presentation/controller/c_user.dart';
import 'package:absensi_apps/presentation/page/auth/login_page.dart';
import 'package:absensi_apps/presentation/page/payment/wallet.dart';
import 'package:d_info/d_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 0;

  LocationData? _locationData;
  File? _foto;
  bool _isLoading = false;
  final cUser = Get.put(Cuser());
  // String _statusAbsensi = '';

  /// Mengambil lokasi pengguna
  Future<void> _getLocation() async {
    final location = Location();

    if (!await location.serviceEnabled() && !await location.requestService()) {
      return;
    }

    if (await location.hasPermission() == PermissionStatus.denied &&
        await location.requestPermission() != PermissionStatus.granted) {
      return;
    }

    final locationData = await location.getLocation();
    setState(() {
      _locationData = locationData;
    });
  }

  /// Mengambil foto menggunakan kamera
  Future<void> _getPhoto() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _foto = File(pickedFile.path);
      });
    }
  }

  /// Mengirim data absensi ke API
  Future<void> _submitAbsensi() async {
    if (_locationData == null || _foto == null) {
      _showSnackBar('Pastikan lokasi dan foto sudah diambil!');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(Api.absen), // Sesuaikan URL API Anda
      )
        ..fields['user_id'] = cUser.data.idUser
            .toString() // Ganti sesuai user ID dari sistem Anda
        ..fields['latitude'] = _locationData!.latitude.toString()
        ..fields['longitude'] = _locationData!.longitude.toString()
        ..files.add(await http.MultipartFile.fromPath('foto', _foto!.path));

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // setState(() {
        //   _statusAbsensi = "telah absen";
        // });
        DInfo.dialogSuccess(context, 'Berhasil melakukan absensi!');
        DInfo.closeDialog(context, actionAfterClose: () {
          Get.offAll(() => ProfilePage());
        });

        // Update status absensi pada data user setelah berhasil absen
        cUser.data.updateStatus("sudah absen"); // Memperbarui status absensi
      } else {
        _showSnackBar('Gagal melakukan absensi!');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan!');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> refresh() async {
    final userId = cUser.data.idUser ?? "";
    await cUser.getstatus(userId);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refresh();
    }
  }

  /// Menampilkan pesan snack bar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Section
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColor.primary,
                    Color.fromARGB(255, 138, 138, 182)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              child: Column(
                children: [
                  const Text(
                    'Available',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cUser.status == 'sudah absen'
                          ? Colors.green
                          : AppColor.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: Obx(() {
                        return Text(
                          cUser.status.toString(),
                          style: TextStyle(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontSize: 16,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _foto != null ? FileImage(_foto!) : null,
                    backgroundColor: const Color.fromARGB(255, 223, 223, 223),
                    child: _foto == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: AppColor.primary,
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    cUser.data.name.toString(),
                    style: TextStyle(
                      color: AppColor.light,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Obx(() {
                    return Text(
                      cUser.data.kelas.toString(),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      StatWidget(label: 'Follows', value: '235'),
                      StatWidget(label: 'Views', value: '935'),
                      StatWidget(label: 'Vouches', value: '64'),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_locationData != null)
                      Column(
                        children: [
                          Text(
                            'Lokasi: ${_locationData!.latitude}, ${_locationData!.longitude}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColor.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                    // Check if time is between 6 and 8 AM, and the user has not checked in yet
                    if (DateTime.now().hour >= 6 &&
                        DateTime.now().hour <= 8 &&
                        cUser.status != 'sudah absen') ...[
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton.icon(
                          onPressed: _getLocation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(color: Colors.white70),
                            ),
                          ),
                          icon: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Get Location',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _getPhoto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.secondary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide(color: Colors.white70),
                            ),
                          ),
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Take Pict',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.maxFinite,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _submitAbsensi,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'send',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ],

                    if (cUser.status == 'sudah absen') ...[
                      const Center(
                        child: Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 100,
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Terimakasih telah mengisi absen',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (DateTime.now().hour <= 6 &&
                        cUser.status != 'sudah absen') ...[
                      const Center(
                        child: Icon(
                          Icons.hourglass_empty,
                          color: Color.fromARGB(255, 211, 219, 9),
                          size: 100,
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Absen pukul 6 pagi',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 211, 219, 96),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (DateTime.now().hour >= 8 &&
                        cUser.status != 'sudah absen') ...[
                      const Center(
                        child: Icon(
                          Icons.error,
                          color: Color.fromARGB(255, 219, 9, 9),
                          size: 100,
                        ),
                      ),
                      const Center(
                        child: Text(
                          'Mohon Maaf Jam Absen Sudah Tutup',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 219, 96, 96),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ]),
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
          borderRadius: BorderRadius.only(
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
                        color: const Color.fromARGB(255, 216, 216, 216).withOpacity(0.5),
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
          break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  WalletPage(),
            ),
          );
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>  LoginPage(),
            ),
          );
          break;
      }
    });
  }
}

class StatWidget extends StatelessWidget {
  final String label;
  final String value;

  const StatWidget({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class SkillIcon extends StatelessWidget {
  final IconData icon;

  const SkillIcon({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.purple.shade100,
      radius: 30,
      child: Icon(
        icon,
        color: Colors.purple,
        size: 30,
      ),
    );
  }
}
