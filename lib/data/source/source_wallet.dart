import 'package:absensi_apps/config/api.dart';
import 'package:absensi_apps/config/app_request.dart';

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
}