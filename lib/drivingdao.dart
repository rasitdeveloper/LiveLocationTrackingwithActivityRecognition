import 'package:ev_flutter_acvty_recog_1/driving.dart';

import 'VeritabaniYardimcisi.dart';

class Drivingdao {
  Future<List<Driving>> getAllDriving() async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();

    List<Map<String, dynamic>> maps = await db.rawQuery("SELECT * FROM driving");

    return List.generate(maps.length, (i) {
      var satir = maps[i];
      return Driving(satir["driving_id"], satir["driving_latitude"], satir["driving_longitude"]);
    });
  }

  Future<void> save_driving(String latitude, String longitude) async {
    var db = await VeritabaniYardimcisi.veritabaniErisim();
    var bilgiler = Map<String, dynamic>();
    bilgiler["driving_latitude"];
    bilgiler["driving_longitude"];
    await db.insert("driving", bilgiler);
  }
}