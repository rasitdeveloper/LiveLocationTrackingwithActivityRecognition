import 'dart:async';

import 'package:activity_recognition_flutter/activity_recognition_flutter.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as glocate;
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'on_footdao.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {


  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  double boylam = 0.0;
  double enlem = 0.0;

  var entry;
  var confidence;
  var zoom = 4;
  var temp_latitude;
  var temp_longitude;
  late double distanceInMeters;

  Location get location => _location;
  late LatLng _locationPosition;
  LatLng get locationPosition => _locationPosition;

  bool locationServiceActive = true;

  late Stream<ActivityEvent> activityStream;
  ActivityEvent latestActivity = ActivityEvent.empty();
  List<ActivityEvent> _events = [];
  ActivityRecognition activityRecognition = ActivityRecognition.instance;

  late BitmapDescriptor currentLocationIcon;

  Completer<GoogleMapController> haritaKontrol = Completer();
  var baslangicKonum = CameraPosition(target: LatLng(38.7412482, 26.1844276), zoom: 4);
  List<Marker> isaretler = <Marker>[];
  Map<PolylineId, Polyline> _polylines = {};

  Location _location = new Location();

  Set<Polyline> get polylines => _polylines.values.toSet();

  @override
  void initState () {
    // TODO: implement initState
    super.initState();
    konumAl();
    initalization();
    _startTracking();
  }

  void konumAl() async {
    temp_latitude = await glocate.Geolocator.getCurrentPosition(desiredAccuracy: glocate.LocationAccuracy.high);
    temp_longitude = await glocate.Geolocator.getCurrentPosition(desiredAccuracy: glocate.LocationAccuracy.high);
  }

  void _startTracking() {
    activityStream =
        activityRecognition.startStream(runForegroundService: true);
    activityStream.listen(onData);
  }

  void onData(ActivityEvent activityEvent) {
    print(activityEvent.toString());
    setState(() {
      _events.add(activityEvent);
      latestActivity = activityEvent;
    });
  }

  initalization() async{
    await getUserLocation();
  }

  getUserLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    _serviceEnabled = await location.serviceEnabled();
    if(!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if(!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if(_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if(_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    location.onLocationChanged.listen((LocationData currentLocation) async {


      GoogleMapController controlller = await haritaKontrol.future;
      _locationPosition = LatLng(currentLocation.latitude!.toDouble(), currentLocation.longitude!.toDouble());

      if(_events.isNotEmpty) {
        entry = _events.last;
        if (entry.type == ActivityType.STILL) {
          makeIconStill(context);
        } else if (entry.type == ActivityType.IN_VEHICLE) {
          distanceInMeters = glocate.Geolocator.distanceBetween(_locationPosition.latitude, _locationPosition.longitude, temp_latitude, temp_longitude);
          if(distanceInMeters > 200) {
            temp_latitude = _locationPosition.latitude;
            temp_longitude = _locationPosition.longitude;
            On_footdao().save_on_foot(temp_latitude, temp_longitude);
            const PolylineId polylineId = PolylineId("group");
            late Polyline polyline;
            if(_polylines.containsKey(polylineId)) {
              final tmp = _polylines[polylineId]!;
              polyline = tmp.copyWith(
                pointsParam: [...tmp.points, LatLng(_locationPosition.latitude, _locationPosition.longitude)],
              );
            } else {
              polyline = Polyline(
                  polylineId: polylineId,
                  points: [LatLng(_locationPosition.latitude, _locationPosition.longitude)],
                  width: 3,
                  color: Colors.green
              );
            }
          }
        } else if (entry.type == ActivityType.ON_FOOT) {
          distanceInMeters = glocate.Geolocator.distanceBetween(_locationPosition.latitude, _locationPosition.longitude, temp_latitude, temp_longitude);
          if(distanceInMeters > 100) {
            temp_latitude = _locationPosition.latitude;
            temp_longitude = _locationPosition.longitude;
            On_footdao().save_on_foot(temp_latitude, temp_longitude);
            const PolylineId polylineId = PolylineId("group");
            late Polyline polyline;
            if(_polylines.containsKey(polylineId)) {
              final tmp = _polylines[polylineId]!;
              polyline = tmp.copyWith(
                pointsParam: [...tmp.points, LatLng(_locationPosition.latitude, _locationPosition.longitude)],
              );
            } else {
              polyline = Polyline(
                  polylineId: polylineId,
                  points: [LatLng(_locationPosition.latitude, _locationPosition.longitude)],
                  width: 3,
                  color: Colors.grey
              );
            }
          }
        }
      }

      var gidilecekIsaret = Marker(
          markerId: (entry.type == ActivityType.STILL) ? MarkerId("1") : (entry.type == ActivityType.IN_VEHICLE) ? MarkerId("2") : MarkerId("3"),
          position: LatLng(_locationPosition.latitude, _locationPosition.longitude),
          infoWindow: InfoWindow(snippet: "Suan ki Konum"),
          icon: currentLocationIcon
      );
      print(_locationPosition);
      setState(() {
        isaretler.add(gidilecekIsaret);
        // var gidilecekKonum = CameraPosition(target: LatLng(_locationPosition.latitude, _locationPosition.longitude), zoom: 12 );
        // controlller.animateCamera(CameraUpdate.newCameraPosition(gidilecekKonum));
        enlem = _locationPosition.latitude;
        boylam = _locationPosition.longitude;
      });
    });

  }

  makeIcon(context) {
    ImageConfiguration configuration = createLocalImageConfiguration(context);
    BitmapDescriptor.fromAssetImage(configuration, "assets/currentLocation.png").then((icon) => {
      currentLocationIcon = icon
    });
  }

  makeIconDriving(context) {
    ImageConfiguration configuration = createLocalImageConfiguration(context);
    BitmapDescriptor.fromAssetImage(configuration, "assets/driving.png").then((icon) => {
      currentLocationIcon = icon
    });
  }

  makeIconOnFoot(context) {
    ImageConfiguration configuration = createLocalImageConfiguration(context);
    BitmapDescriptor.fromAssetImage(configuration, "assets/on_foot.png").then((icon) => {
      currentLocationIcon = icon
    });
  }

  makeIconStill(context) {
    ImageConfiguration configuration = createLocalImageConfiguration(context);
    BitmapDescriptor.fromAssetImage(configuration, "assets/still.png").then((icon) => {
      currentLocationIcon = icon
    });
  }


  @override
  Widget build(BuildContext context) {
    if(_events.isEmpty)
      makeIcon(context);
    else {
      entry = _events.last;
      confidence = _events.last.confidence;

      if (entry.type == ActivityType.STILL) {
        makeIconStill(context);
      } else if (entry.type == ActivityType.IN_VEHICLE) {
        makeIconDriving(context);
      } else if (entry.type == ActivityType.ON_FOOT) {
        makeIconOnFoot(context);
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("is_flutter_location_tracker_1_main.dart", style: TextStyle(fontSize: 14),),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 300,
              height: 200,
              child: GoogleMap(
                mapType: MapType.normal,
                zoomGesturesEnabled: true,
                tiltGesturesEnabled: false,
                polylines: polylines,
                initialCameraPosition: baslangicKonum,
                markers: Set<Marker>.of(isaretler),
                onMapCreated: (GoogleMapController controller) {
                  haritaKontrol.complete(controller);
                },
              ),
            ),
            Text("boylam: $boylam", style: TextStyle(fontSize: 24),),
            Text("enlem: $enlem", style: TextStyle(fontSize: 24),),
            Text("$entry", style: TextStyle(fontSize: 18),),
          ],
        ),
      ),
    );
  }
}