import 'package:ev_flutter_acvty_recog_1/on_foot.dart';

import 'VeritabaniYardimcisi.dart';

class On_footdao {
  Future<List<On_foot>> getAllOnFoot() async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();

    List<Map<String, dynamic>> maps = await db.rawQuery("SELECT * FROM on_foot");

    return List.generate(maps.length, (i) {
      var satir = maps[i];
      return On_foot(satir["on_foot_id"], satir["on_foot_latitude"], satir["on_foot_longitude"]);
    });
  }

  Future<void> save_on_foot(String latitude, String longitude) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    var bilgiler = Map<String, dynamic>();
    bilgiler["on_foot_latitude"];
    bilgiler["on_foot_longitude"];
    await db.insert("on_foot", bilgiler);
  }
}