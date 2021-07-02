import 'package:flutter/material.dart';
import 'package:places_autocomplete/blocs/application_bloc.dart';
import 'package:places_autocomplete/services/places_service.dart';
import 'package:places_autocomplete/src/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value:PlacesService()),
        ChangeNotifierProvider.value(value:ApplicationBloc()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
