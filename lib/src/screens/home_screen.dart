import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:places_autocomplete/blocs/application_bloc.dart';
import 'package:places_autocomplete/horizontal_list.dart';
import 'package:places_autocomplete/models/place.dart';
import 'package:places_autocomplete/services/places_service.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _mapController = Completer();
  StreamSubscription locationSubscription;
  StreamSubscription boundsSubscription;
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String nearby = "";
  int radius = 0;
  List<dynamic> data = [];
  // final Set<Marker> markers = {};
  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   var latlon = Provider.of<ApplicationBloc>(context, listen: false)
  //       .selectedLocationStatic;
  //   Provider.of<PlacesService>(context, listen: false).nearbyPlaces(
  //     nearby,
  //     radius,
  //     latlon,
  //   );
  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    // print("kyare kyare");
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    //Listen for selected Location
    locationSubscription =
        applicationBloc.selectedLocation.stream.listen((place) {
      if (place != null) {
        print("init ni andar");
        print(place.name);
        _locationController.text = place.name;
        _goToPlace(place);
      } else{
        print("init ni andar");
        _locationController.text = "";
      }
    });

    applicationBloc.bounds.stream.listen((bounds) async {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    });
    super.initState();
  }

  @override
  void dispose() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    applicationBloc.dispose();
    _locationController.dispose();
    locationSubscription.cancel();
    boundsSubscription.cancel();
    super.dispose();
  }

  void submit() async {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();
    print(nearby);
    print(radius);
    print("sagar checking");
    // if (isValid) {
    // bool isValid = _formKey.currentState.validate();
    var latlon = Provider.of<ApplicationBloc>(context, listen: false)
        .selectedLocationStatic;
    print("latlon joto");
    print(latlon);
    if (isValid) {
      _formKey.currentState.save();

      List<dynamic> items =
          await Provider.of<ApplicationBloc>(context, listen: false).nearbyPlaces(
        // nearby,
        radius,
        latlon,
      );
      Set<Marker> mrk = {};
      for (var i = 0; i < items.length; i++) {
        mrk.add(Marker(
          markerId: MarkerId(i.toString()),
          infoWindow: InfoWindow(
              title: '${items[i]["name"]}     ',
              snippet: '${items[i]["vicinity"]}  '),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: LatLng(items[i]["geometry"]["location"]["lat"],
              items[i]["geometry"]["location"]["lng"]),
        ));
      }
      print(mrk);
      Provider.of<ApplicationBloc>(context, listen: false).addmarker(
        mrk,
      );
      // setState(() {

      // });
      //await Provider.of<PlacesService>(context,listen:false).nearbyPlaces();
      // print("All nearby places ");
      // print(data);
      // print(data[0]["icon"]);
      // print(data[0]["vicinity"]);
      // print("jainam");
    }

    // Navigator.of(context).pushNamed(HomePage.routename);
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    print(applicationBloc.searchResults);
    return Scaffold(
      body: (applicationBloc.currentLocation == null)
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                  child: TextField(
                    controller: _locationController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: '  Search by City',
                      suffixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => applicationBloc.searchPlaces(value),
                    onTap: () => applicationBloc.clearSelectedLocation(),
                  ),
                ),

                Stack(
                  children: [
                    Column(
                        children: [
                          
                          Container(
                            height: 310.0,
                            child: GoogleMap(
                              mapType: MapType.normal,
                              myLocationEnabled: true,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                    applicationBloc.currentLocation.latitude,
                                    applicationBloc.currentLocation.longitude),
                                zoom: 14,
                              ),
                              onMapCreated: (GoogleMapController controller){
                                _mapController.complete(controller);
                               
                              },
                              markers: Set<Marker>.of(applicationBloc.markers),
                            ),
                          ),
                          

                        ],
                      
                    ),
                    ListTile(
                            //contentPadding: EdgeInsets.all(<some value here>),//change for side padding
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                RaisedButton(
                                  onPressed: () {},
                                  child: Text("Clear"),
                                  color: Colors.blueAccent,
                                  textColor: Colors.white,
                                ),
                                RaisedButton(
                                  onPressed: () {},
                                  child: Text("Filter"),
                                  color: Colors.blueAccent,
                                  textColor: Colors.white,
                                ),
                              ],
                            ),
                          ),
                    if (applicationBloc.searchResults != null &&
                        applicationBloc.searchResults.length != 0)
                      Container(
                          height: 300.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.6),
                              backgroundBlendMode: BlendMode.darken)),
                    if (applicationBloc.searchResults != null)
                      Container(
                        height: 300.0,
                        child: ListView.builder(
                            itemCount: applicationBloc.searchResults.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(
                                  applicationBloc
                                      .searchResults[index].description,
                                  style: TextStyle(color: Colors.white),
                                ),
                                onTap: () {
                                  print("ontap");
                                  print(applicationBloc.searchResults[index].placeId);
                                  applicationBloc.setSelectedLocation(
                                      applicationBloc
                                          .searchResults[index].placeId);
                                },
                              );
                            }),
                      ),
                      
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(left: 8.0, top: 15),
                  child: Text(
                    'Find Nearest Restaurant',
                    style:
                        TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, right: 15),
                  child: Form(
                    key: _formKey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 250,
                          child: Column(
                            children: [
                              // TextFormField(
                              //   key: ValueKey('nearby'),
                              //   validator: (value) {
                              //     if (value.isEmpty) {
                              //       return 'Enter valid Name!';
                              //     }
                              //     return null;
                              //   },
                              //   keyboardType: TextInputType.text,
                              //   decoration: InputDecoration(
                              //     // prefixIcon: Image.asset(
                              //     //   "assets/images/person-24px (1).png",
                              //     // ),
                              //     labelText: 'Name',
                              //   ),
                              //   onSaved: (value) {
                              //     nearby = value;
                              //   },
                              // ),
                              TextFormField(
                                key: ValueKey('radius'),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Enter valid radius!';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  // prefixIcon: Image.asset(
                                  //   "assets/images/person-24px (1).png",
                                  // ),
                                  labelText: 'Radius in meters',
                                ),
                                onSaved: (value) {
                                  radius = int.parse(value);
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 15),
                          child: InkWell(
                              onTap: submit,
                              child: Container(
                                height: 75,
                                width: 75,
                                decoration: BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.near_me,
                                  size: 35,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 10,
                // ),
                // if (data.length != 0)
                //   Container(
                //     padding: const EdgeInsets.only(
                //       left: 10.0,
                //       bottom: 10,
                //       top: 20,
                //     ),
                //     alignment: Alignment.centerLeft,
                //     child: Text(
                //       'Top Picks For You',
                //       style: TextStyle(
                //           fontSize: 20.0, fontWeight: FontWeight.bold),
                //     ),
                //   ),
                // Consumer<PlacesService>(
                //     // stream: null,
                //     builder: (context, data,_) {
                //   return Container(
                //     height: 170.0,
                //     padding: EdgeInsets.symmetric(vertical: 10),
                //     child: ListView.builder(
                //       scrollDirection: Axis.horizontal,
                //       itemBuilder: (context, index) {
                //         return HorizontalList(
                //           image_location: data.items[index]["icon"],
                //           image_caption: data.items[index]["name"],
                //           image_vicinity: data.items[index]["vicinity"],
                //           rating: data.items[index]["rating"].toString(),
                //         );
                //       },
                //       itemCount: data.items.length,
                //     ),
                //   );
                // }),
                Container(
                    height: 170.0,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return HorizontalList(
                          image_location: applicationBloc.items[index]["icon"],
                          image_caption: applicationBloc.items[index]["name"],
                          image_vicinity: applicationBloc.items[index]["vicinity"],
                          rating: applicationBloc.items[index]["rating"].toString(),
                        );
                      },
                      itemCount: applicationBloc.items.length,
                    ),
                  )
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[300],
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.near_me),
            label: 'Go To',
          ),
        ],
      ),
    );
  }

  Future<void> _goToPlace(Place place) async {
    print("google maps ni andae");
    print(place.name);
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                place.geometry.location.lat, place.geometry.location.lng),
            zoom: 14.0),
      ),
    );
  }
}
