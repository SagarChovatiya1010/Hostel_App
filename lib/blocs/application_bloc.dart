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
