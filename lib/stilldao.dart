import 'package:ev_flutter_acvty_recog_1/still.dart';

import 'VeritabaniYardimcisi.dart';

class Stilldao {
  Future<List<Still>> getAllStill() async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();

    List<Map<String, dynamic>> maps = await db.rawQuery("SELECT * FROM still");

    return List.generate(maps.length, (i) {
      var satir = maps[i];
      return Still(satir["still_id"], satir["still_latitude"], satir["still_longitude"]);
    });
  }

  Future<void> saveStill(String latitude, String longitude) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    var bilgiler = Map<String, dynamic>();
    bilgiler["still_latitude"];
    bilgiler["still_longitude"];
    await db.insert("still", bilgiler);
  }
}