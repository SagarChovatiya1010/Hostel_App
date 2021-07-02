import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:places_autocomplete/models/geometry.dart';
import 'package:places_autocomplete/models/location.dart';
import 'package:places_autocomplete/models/place.dart';
import 'package:places_autocomplete/models/place_search.dart';
import 'package:places_autocomplete/services/geolocator_service.dart';
import 'package:places_autocomplete/services/marker_service.dart';
import 'package:places_autocomplete/services/places_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:places_autocomplete/blocs/application_bloc.dart';
import 'package:places_autocomplete/models/allnearbyPlaces.dart';
import 'package:places_autocomplete/models/place.dart';
import 'dart:convert' as convert;
import 'package:places_autocomplete/models/place_search.dart';
class ApplicationBloc with ChangeNotifier {
  final geoLocatorService = GeolocatorService();
  final placesService = PlacesService();
  final markerService = MarkerService();
  Position currentLocation;
  String placeType;
  List<PlaceSearch> searchResults;
  List<Place> placeResults;
  StreamController<Place> selectedLocation = StreamController<Place>();
  StreamController<LatLngBounds> bounds = StreamController<LatLngBounds>();
  Place selectedLocationStatic;
  Set<Marker> markers = {};

  ApplicationBloc() {
    setCurrentLocation();
  }



  final key = 'AIzaSyARl4-bejEhfIUJb7aypDljMwvUeBmZxOo';
  List<dynamic> items = [];
  Future<List<PlaceSearch>> getAutocomplete(String search) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=(cities)&key=$key';
    var response = await http.get(url);
    // print(response.body);
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((place) => PlaceSearch.fromJson(place)).toList();
  }
   Future<Place> getPlace(String placeId) async {
    var url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$key';
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResult = json['result'] as Map<String,dynamic>;
    return Place.fromJson(jsonResult);
  }
   Future<List<Place>> getPlaces(double lat, double lng,String placeType) async {
    var url = 'https://maps.googleapis.com/maps/api/place/textsearch/json?location=$lat,$lng&type=$placeType&rankby=distance&key=$key';
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['results'] as List;
    return jsonResults.map((place) => Place.fromJson(place)).toList();
  }
   Future<dynamic> nearbyPlaces(int radius, Place latlon) async {
    var lat = latlon.geometry.location.lat;
    var lng = latlon.geometry.location.lng;
    print("lat lon $lat  $lng");
    // print("nearby $nearby");
    print("radius $radius");
    var url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=$radius&type=restaurant&key=$key';
    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    print("nearby places");
    //print(json);
    items = json['results'] as List;
    print("nearby-by");
    
    notifyListeners();
    return items;
    //print(items);
    // return jsonResults.map((place) => Place.fromJson(place)).toList();
  }

  // List<dynamic> allNearbyPlaces(){
  //   print("Inside placesServices - allnearby");
  //   print(items);
  //   return items;
  // }
  // Future<void> allNearbyPlaces(String nearby, int radius, Place latlon) async {
  //   var lat = latlon.geometry.location.lat;
  //   var lng = latlon.geometry.location.lng;
  //   print("lat lon $lat  $lng");
  //   print("nearby $nearby");
  //   print("radius $radius");
  //   var url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&radius=$radius&type=$nearby&key=$key';
  //   var response = await http.get(url);
  //   var json = convert.jsonDecode(response.body);
  //   print("nearby places");
  //   print(json);
  //   var jsonResults = json['results'] as List;
  //   return jsonResults.map((place) => AllNearbyPlaces.fromJson(place)).toList();
  // }


  setCurrentLocation() async {
    currentLocation = await geoLocatorService.getCurrentLocation();
    selectedLocationStatic = Place(
      name: null,
      geometry: Geometry(
        location: Location(
            lat: currentLocation.latitude, lng: currentLocation.longitude),
      ),
    );
    notifyListeners();
  }
  addmarker(Set<Marker>mrk){
    markers.addAll(mrk);
    notifyListeners();
  }
  searchPlaces(String searchTerm) async {
    searchResults = await placesService.getAutocomplete(searchTerm);
    notifyListeners();
  }

  clearSelectedLocation() {
    selectedLocation.add(null);
    selectedLocationStatic = null;
    searchResults = null;
    placeType = null;
    notifyListeners();
  }

  setSelectedLocation(String placeId) async {
    var sLocation = await placesService.getPlace(placeId);
    print("setselected ni andar");
    // print(sLocation);
    // print(sLocation.name);
    // print(selectedLocation.);
    selectedLocation.add(sLocation);
    // print(selectedLocation.stream.listen((event) {print("pachi");print(event.name);}));
    selectedLocationStatic = sLocation;
    searchResults = null;
    // notifyListeners();
    markers.add(Marker(
      markerId: MarkerId(placeId),
      infoWindow: InfoWindow(
          title: '${sLocation.name}     ', snippet: '${sLocation.vicinity}  '),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: LatLng(
          sLocation.geometry.location.lat, sLocation.geometry.location.lng),
    ));
    // print("setselected ni andar");
    // print(markers);
    //print(selectedLocation.stream.listen((event) {print("stream ni andar");print(event.name);}));
    notifyListeners();
  }

  // togglePlaceType(String value, bool selected) async {
  //   if (selected) {
  //     placeType = value;
  //   } else {
  //     placeType = null;
  //   }

  //   if (placeType != null) {
  //     var places = await placesService.getPlaces(
  //         selectedLocationStatic.geometry.location.lat,
  //         selectedLocationStatic.geometry.location.lng,
  //         placeType);
  //     markers = {};
  //     if (places.length > 0) {
  //       var newMarker = markerService.createMarkerFromPlace(places[0], false);
  //       markers.add(newMarker);
  //     }

  //     var locationMarker =
  //         markerService.createMarkerFromPlace(selectedLocationStatic, true);
  //     markers.add(locationMarker);

  //     var _bounds = markerService.bounds(Set<Marker>.of(markers));
  //     bounds.add(_bounds);

  //     notifyListeners();
  //   }
  //   @override
  //   void dispose() {
  //     selectedLocation.close();
  //     bounds.close();
  //     super.dispose();
  //   }
  // }
}
