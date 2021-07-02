import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:places_autocomplete/blocs/application_bloc.dart';
import 'package:places_autocomplete/models/allnearbyPlaces.dart';
import 'package:places_autocomplete/models/place.dart';
import 'dart:convert' as convert;
import 'package:places_autocomplete/models/place_search.dart';
class PlacesService with ChangeNotifier{
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
}
