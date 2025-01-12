import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:project2/backend/api_calls.dart';
import 'package:project2/choose_category.dart';
import 'package:place_picker_google/place_picker_google.dart';
import 'package:project2/misc/flutter_flow_theme.dart';
import 'package:project2/misc/icon_button.dart';
import 'package:project2/trip_details.dart';

class CreateSchedule extends StatefulWidget {
  const CreateSchedule({super.key});

  @override
  State<CreateSchedule> createState() => _CreateScheduleState();
}

class _CreateScheduleState extends State<CreateSchedule> {
  String _transportation = 'none';
  String _venue = 'none';
  List<String> _selectedVenues = [];
  TextEditingController _titleController = TextEditingController();
  String? locationName;
  
  double? latitude;
  
  double? longitude;
  
  LatLng? _currentLocation = const LatLng(0.0, 0.0);
  Future<void> _handleContinueButton(BuildContext context) async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Perform the API call
      final places = await ApiCalls.fetchPlaces(
        keywords: _selectedVenues,
        travelMode: _transportation == "walk" ? "walking" : "transit",
        latitude: latitude!,
        longitude: longitude!,

      );

      // Dismiss the loading indicator
      Navigator.pop(context);

      // Navigate to TripDetails with the API response
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripDetails(
            places: places,
            showContinueButton: true,
            title: _titleController.text,
          ),
        ),
      );
    } catch (e) {
      // Dismiss the loading indicator
      Navigator.pop(context);

      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching places: $e')),
      );
    }
  }
Future<void> _getUserLocation() async {
    Location location = Location();

    // Request permission
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // Get the current location
    final userLocation = await location.getLocation();

    setState(() {
      _currentLocation =
          LatLng(userLocation.latitude!, userLocation.longitude!);
      
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        title: Text('Create Schedule',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                fontFamily: 'Poppins',
                color: FlutterFlowTheme.of(context).primary)),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.92,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding:
                  const EdgeInsetsDirectional.fromSTEB(24.0, 24.0, 0.0, 0.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Title',
                      style: FlutterFlowTheme.of(context).titleLarge,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                            labelText: 'Enter title',
                            labelStyle: FlutterFlowTheme.of(context).labelLarge,
                            filled: true,
                            fillColor:
                                FlutterFlowTheme.of(context).primaryBackground,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 3.0),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 3.0),
                                borderRadius: BorderRadius.circular(10.0)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 3.0),
                                borderRadius: BorderRadius.circular(10.0))),
                        style: FlutterFlowTheme.of(context).bodyLarge,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 24, 0, 0),
                      child: Text(
                        'Location',
                        style: FlutterFlowTheme.of(context).titleLarge,
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await _getUserLocation();
                        // Launch Place Picker
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlacePicker(
                              searchInputDecorationConfig: SearchInputDecorationConfig(
                                hintText: 'Search for a place',
                                hintStyle: FlutterFlowTheme.of(context).bodyLarge,
                                fillColor: FlutterFlowTheme.of(context).primaryBackground,
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).alternate,
                                    width: 3.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              nearbyPlaceItemStyle: TextStyle(
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 16.0,
                              ),
                              nearbyPlaceStyle: TextStyle(
                                color: FlutterFlowTheme.of(context).primaryText,
                                fontSize: 16.0,
                              ),
                              enableNearbyPlaces: true,

                              apiKey: dotenv.env['GOOGLE_MAPS_API_KEY']!,
                              onPlacePicked: (LocationResult result) {
                                setState(() {
                                  locationName = result.locality?.longName;
                                  latitude = result.latLng?.latitude;
                                  longitude = result.latLng?.longitude;
                                });
                                Navigator.pop(context);
                              },
                              myLocationEnabled: true,
                              showSearchInput: true,
                              initialLocation: _currentLocation,
                            ),
                          ),
                        );

                        if (result != null) {
                          setState(() {
                            locationName = result.formattedAddress;
                            latitude = result.geometry.location.lat;
                            longitude = result.geometry.location.lng;
                          });
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                                color: FlutterFlowTheme.of(context).alternate,
                                width: 3.0,
                                style: BorderStyle.solid)),
                        child: Text(
                          locationName ?? 'Choose Location',
                          style: FlutterFlowTheme.of(context).bodyLarge,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 24.0, 0.0, 0.0),
                      child: Text(
                        'Visiting duration',
                        style: FlutterFlowTheme.of(context).titleLarge,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextFormField(
                        obscureText: false,
                        decoration: InputDecoration(
                            labelText: 'Duration',
                            labelStyle: FlutterFlowTheme.of(context).labelLarge,
                            filled: true,
                            fillColor:
                                FlutterFlowTheme.of(context).primaryBackground,
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                    width: 3.0),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).primary,
                                    width: 3.0),
                                borderRadius: BorderRadius.circular(10.0)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: FlutterFlowTheme.of(context).error,
                                    width: 3.0),
                                borderRadius: BorderRadius.circular(10.0))),
                        style: FlutterFlowTheme.of(context).bodyLarge,
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 24.0, 0.0, 0.0),
                      child: Text(
                        'Transportation',
                        style: FlutterFlowTheme.of(context).titleLarge,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Wrap(
                          direction: Axis.horizontal,
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          runSpacing: 20.0,
                          spacing: 10.0,
                          children: [
                            FlutterFlowIconButton(
                              onPressed: () {
                                setState(() {
                                  _transportation = 'walk';
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                      content: Text(
                                        'Walking',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall,
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ));
                                });
                              },
                              icon: const Icon(Icons.man),
                              buttonSize: 64.0,
                              borderRadius: 10.0,
                              borderColor: _transportation == 'walk'
                                  ? FlutterFlowTheme.of(context).primaryText
                                  : FlutterFlowTheme.of(context).alternate,
                              borderWidth: 3.0,
                              fillColor: _transportation == 'walk'
                                  ? FlutterFlowTheme.of(context).primary
                                  : FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                            ),
                            FlutterFlowIconButton(
                              onPressed: () {
                                setState(() {
                                  _transportation = 'bus';
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                      content: Text(
                                        'Bus',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall,
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ));
                                });
                              },
                              icon: const Icon(
                                  Icons.emoji_transportation_rounded),
                              buttonSize: 64.0,
                              borderRadius: 10.0,
                              borderColor: _transportation == 'bus'
                                  ? FlutterFlowTheme.of(context).primaryText
                                  : FlutterFlowTheme.of(context).alternate,
                              borderWidth: 3.0,
                              fillColor: _transportation == 'bus'
                                  ? FlutterFlowTheme.of(context).primary
                                  : FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                            ),
                            FlutterFlowIconButton(
                              onPressed: () {
                                setState(() {
                                  _transportation = 'train';
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor:
                                          FlutterFlowTheme.of(context)
                                              .alternate,
                                      content: Text(
                                        'Train',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall,
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ));
                                });
                              },
                              icon: const Icon(Icons.train_rounded),
                              buttonSize: 64.0,
                              borderRadius: 10.0,
                              borderColor: _transportation == 'train'
                                  ? FlutterFlowTheme.of(context).primaryText
                                  : FlutterFlowTheme.of(context).alternate,
                              borderWidth: 3.0,
                              fillColor: _transportation == 'train'
                                  ? FlutterFlowTheme.of(context).primary
                                  : FlutterFlowTheme.of(context)
                                      .secondaryBackground,
                            )
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 24.0, 0.0, 0.0),
                      child: Text(
                        'Venue Category',
                        style: FlutterFlowTheme.of(context).titleLarge,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10.0,
                          runSpacing: 20.0,
                          children: [
                            FlutterFlowIconButton(
                              onPressed: () {
                                setState(() {
                                  _venue = 'museum';
                                  _selectedVenues.clear();
                                  _selectedVenues
                                      .add('Muzee și galerii de artă');
                                });
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).alternate,
                                    content: Text(
                                      'Museums',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall,
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ));
                              },
                              icon: const Icon(Icons.museum),
                              buttonSize: 64.0,
                              borderRadius: 10.0,
                              borderColor: _venue == 'museum'
                                  ? FlutterFlowTheme.of(context).primaryText
                                  : FlutterFlowTheme.of(context).alternate,
                              borderWidth: 3.0,
                              fillColor: _venue == 'museum'
                                  ? FlutterFlowTheme.of(context).primary
                                  : FlutterFlowTheme.of(context)
                                      .primaryBackground,
                            ),
                            FlutterFlowIconButton(
                              onPressed: () {
                                setState(() {
                                  _venue = 'art';
                                  _selectedVenues.clear();
                                  _selectedVenues
                                      .add('Muzee și galerii de artă');
                                });
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).alternate,
                                    content: Text(
                                      'Art Galleries',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall,
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ));
                              },
                              icon: const Icon(Icons.brush_rounded),
                              buttonSize: 64.0,
                              borderRadius: 10.0,
                              borderColor: _venue == 'art'
                                  ? FlutterFlowTheme.of(context).primaryText
                                  : FlutterFlowTheme.of(context).alternate,
                              borderWidth: 3.0,
                              fillColor: _venue == 'art'
                                  ? FlutterFlowTheme.of(context).primary
                                  : FlutterFlowTheme.of(context)
                                      .primaryBackground,
                            ),
                            FlutterFlowIconButton(
                              onPressed: () {
                                setState(() {
                                  _venue = 'memorials';
                                  _selectedVenues.clear();
                                  _selectedVenues
                                      .add('Muzee și galerii de artă');
                                });
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor:
                                        FlutterFlowTheme.of(context).alternate,
                                    content: Text(
                                      'Memorials',
                                      style: FlutterFlowTheme.of(context)
                                          .bodySmall,
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ));
                              },
                              icon: const Icon(Icons.home_rounded),
                              buttonSize: 64.0,
                              borderRadius: 10.0,
                              borderColor: _venue == 'memorials'
                                  ? FlutterFlowTheme.of(context).primaryText
                                  : FlutterFlowTheme.of(context).alternate,
                              borderWidth: 3.0,
                              fillColor: _venue == 'memorials'
                                  ? FlutterFlowTheme.of(context).primary
                                  : FlutterFlowTheme.of(context)
                                      .primaryBackground,
                            )
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 24.0, 0.0, 0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.height * 0.07,
                            child: OutlinedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ChooseCategory()));
                                if (result != null && result is List<String>) {
                                  setState(() {
                                    _selectedVenues = result;
                                  });
                                }
                              },
                              style: ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                      FlutterFlowTheme.of(context).primary),
                                  elevation: const WidgetStatePropertyAll(2.0),
                                  shape: WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0))),
                                  side: const WidgetStatePropertyAll(
                                      BorderSide.none)),
                              child: Text(
                                'Choose Other',
                                style: FlutterFlowTheme.of(context).titleMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.1,
              child: OutlinedButton(
                onPressed: () async {
                  await _handleContinueButton(context);
                },
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        FlutterFlowTheme.of(context).primary),
                    elevation: const WidgetStatePropertyAll(2.0),
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0))),
                    side: const WidgetStatePropertyAll(BorderSide.none)),
                child: Text(
                  'Continue',
                  style: FlutterFlowTheme.of(context).titleMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
