import 'package:absensi_apps/config/api.dart';
import 'package:absensi_apps/config/app_request.dart';
import 'package:absensi_apps/data/model/wallet.dart';
import 'package:flutter/material.dart';

class SourceWallet {
  static Future<Map> getsaldo(String idUser) async {
    String url = '${Api.wallet}/saldo';
    Map? responseBody = await AppRequest.post(url, {
      'id_user': idUser,
    });
    if (responseBody == null) return {'success': false};
    return responseBody;
  }

  static Future<Map> getpengeluaran(String idUser) async {
    String url = '${Api.wallet}/pengeluaran';
    Map? responseBody = await AppRequest.post(url, {
      'id_user': idUser,
    });
    if (responseBody == null) return {'success': false};
    return responseBody;
  }

  static Future<Map> getpemasukan(String idUser) async {
    String url = '${Api.wallet}/pemasukan';
    Map? responseBody = await AppRequest.post(url, {
      'id_user': idUser,
    });
    if (responseBody == null) return {'success': false};
    return responseBody;
  }

  static Future<List<Wallet>> history(
    String idUser,
  ) async {
    // String url = '${Api.history}/history.php';
    String url = '${Api.wallet}/history';
    Map? responseBody = await AppRequest.post(url, {
      'id_user': idUser,
    });

    print(responseBody);

    if (responseBody == null) return [];

    if (responseBody['success']) {
      dynamic data = responseBody['data'];

      if (data is List) {
        return data.map((e) => Wallet.fromjson(e)).toList();
      } else if (data is Map<String, dynamic>) {
        // Handle single item
        return [Wallet.fromjson(data)];
      }
    }

    return [];
  }

  static Future<bool> transfer(
    String id,
    String nis,
    String total,
    String keterangan,
    BuildContext context,
  ) async {
    String url = '${Api.wallet}/transfer';
    Map? responseBody = await AppRequest.post(url, {
      'id_user': id,
      'nis': nis,
      'total': total,
      'details': keterangan,
    });

    if (responseBody == null) return false;

    // if (responseBody['success']) {
    //   DInfo.dialogSuccess(context, 'Berhasil menambahkan data');
    //   DInfo.closeDialog(context);
    //   Get.off(HomePage());
    //   // Navigator.pop(context);
    // } else {
    //   DInfo.dialogError(context, 'gagal menambah data');
    // }

    return responseBody['success'];
  }
}
