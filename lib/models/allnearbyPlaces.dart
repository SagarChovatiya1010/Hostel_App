import 'package:places_autocomplete/models/place.dart';

class AllNearbyPlaces {
  final String icon;
  final String name;
  final String vicinity;

  AllNearbyPlaces({this.icon,this.name,this.vicinity});

  factory AllNearbyPlaces.fromJson(Map<String, dynamic> json){
    return AllNearbyPlaces(
        icon:  json['icon'],
        name: json['name'],
        vicinity: json['vicinity'],
    );
  }
}