import 'package:absensi_apps/data/model/wallet.dart';
import 'package:absensi_apps/data/source/source_wallet.dart';
import 'package:get/get.dart';

class Cwallet extends GetxController {
  final _loading = false.obs;
  bool get loading => _loading.value;

  final _saldo = ''.obs;
  String get saldo => _saldo.value;
  final _pengeluaran = ''.obs;
  String get pengeluaran => _pengeluaran.value;
  final _pemasukan = ''.obs;
  String get pemasukan => _pemasukan.value;

  final _list = <Wallet>[].obs;
  List<Wallet> get list => _list;

  Future<void> getsaldo(String idUser) async {
    _loading.value = true;
    update();

    Map response = await SourceWallet.getsaldo(idUser);

    if (response['success']) {
      _saldo.value = response['data']['saldo'].toString();
    } else {
      // Handle error
    }

    _loading.value = false;
    update();
  }

  Future<void> getpengeluaran(String idUser) async {
    _loading.value = true;
    update();

    Map response = await SourceWallet.getpengeluaran(idUser);

    if (response['success']) {
      _pengeluaran.value = response['data']['pengeluaran'].toString();
    } else {
      // Handle error
    }

    _loading.value = false;
    update();
  }

  Future<void> getpemasukan(String idUser) async {
    _loading.value = true;
    update();

    Map response = await SourceWallet.getpemasukan(idUser);

    if (response['success']) {
      _pemasukan.value = response['data']['pemasukan'].toString();
    } else {
      // Handle error
    }

    _loading.value = false;
    update();
  }

  getList(idUSer) async {
    _loading.value = true;
    update();

    _list.value = await SourceWallet.history(idUSer);
    update();

    Future.delayed(const Duration(milliseconds: 900), () {
      _loading.value = false;
      update();
    });
  }
}
