import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:project2/backend/api_calls.dart';
import 'package:project2/create_schedule.dart';
import 'package:project2/misc/flutter_flow_theme.dart';
import 'package:project2/misc/utils.dart';
import 'package:project2/profile.dart';
import 'package:project2/trip_history.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:project2/venue_details.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GoogleMapController? _controller; // Make nullable
  final Set<Marker> _markers = {};
  LatLng? _currentLocation = LatLng(37.7749, -122.4194);
  Map<String, dynamic>? _nextVenue;
  String _scheduleId = '';
  bool _loadingNextVenue = true;
  final Set<Polyline> _polylines = {};
  String _remainingTime = '';
  @override
  void initState() {
    super.initState();

    _fetchNextVenue();
  }

  Future<void> _handleCheckIn(BuildContext context) async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Perform the API call
      final places =
          await ApiCalls.startVisit(_nextVenue!['name'], _scheduleId);

      // Dismiss the loading indicator
      Navigator.pop(context);

      // Rebuild the current page
      setState(() {
        _fetchNextVenue();
      });
    } catch (e) {
      // Dismiss the loading indicator
      Navigator.pop(context);

      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching places: $e')),
      );
    }
  }

  Future<void> _handleCheckOut(BuildContext context) async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Perform the API call
      final places = await ApiCalls.endVisit(_nextVenue!['name'], _scheduleId);

      // Dismiss the loading indicator
      Navigator.pop(context);

      // Rebuild the current page
      setState(() {
        _fetchNextVenue();
      });
    } catch (e) {
      // Dismiss the loading indicator
      Navigator.pop(context);

      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching places: $e')),
      );
    }
  }

  Future<void> _fetchNextVenue() async {
    setState(() {
      _loadingNextVenue = true;
      _markers.clear();
      _polylines.clear();
    });
    await _getUserLocation();
    try {
      final nextVenue = await ApiCalls.getNextVenue();
      setState(() {
        _nextVenue = nextVenue!['next_venue'];
        _scheduleId = nextVenue['schedule_id'];
        if (_nextVenue != null) {
          final venueLocation = LatLng(
            _nextVenue!['location']['lat'],
            _nextVenue!['location']['lng'],
          );

          _markers.add(
            Marker(
              markerId: MarkerId(_nextVenue!['name']),
              position: venueLocation,
              infoWindow: InfoWindow(
                title: _nextVenue!['name'],
                snippet: _nextVenue!['vicinity'],
              ),
            ),
          );

          // Fetch and draw directions
          if (_currentLocation != null) {
            _fetchDirections(_currentLocation!, venueLocation);
          }
        }
      });
    } catch (e) {
      _nextVenue = null;
      print("Error fetching next venue: $e");
    } finally {
      setState(() {
        _loadingNextVenue = false;
      });
    }
  }

  Future<void> _fetchDirections(LatLng origin, LatLng destination) async {
    final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    final String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      print("Api request completed with status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final polylineCoordinates = _decodePolyline(points);
          _remainingTime = data['routes'][0]['legs'][0]['duration']['text'];
          setState(() {
            _polylines.add(
              Polyline(
                polylineId: const PolylineId("route"),
                color: Colors.blue,
                width: 5,
                points: polylineCoordinates,
              ),
            );
          });
        }
      } else {
        print("Failed to fetch directions: ${response.body}");
      }
    } catch (e) {
      print("Error fetching directions: $e");
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int shift = 0;
      int result = 0;

      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      polyline.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return polyline;
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateSchedule()),
      );
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TripHistory()),
      );
    }
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Profile()),
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
      _markers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: "Your Location"),
        ),
      );
    });

    // Move the camera to the user's location
    if (_controller != null && _currentLocation != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;

    // Move the camera to the user's location when the map is created
    if (_currentLocation != null) {
      _controller!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
      );
    }
  }

  String _formatDate(String givenDate) {
    // Parse the string into a DateTime object
    DateTime parsedDate = DateTime.parse(givenDate);

    // Format the DateTime into a readable string
    String formattedDate = DateFormat('HH:mm:ss').format(parsedDate);
    return formattedDate;
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose of the GoogleMapController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Your Trips',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        selectedItemColor: FlutterFlowTheme.of(context).primary,
        unselectedItemColor: FlutterFlowTheme.of(context).secondaryText,
        onTap: _onItemTapped,
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: _currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _currentLocation!,
                      zoom: 14.0,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height * 0.4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome to UrbanGuide",
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        fontFamily: 'Poppins',
                        color: FlutterFlowTheme.of(context).primary,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate,
                      width: 3,
                    ),
                  ),
                  child: _loadingNextVenue
                      ? const Center(child: CircularProgressIndicator())
                      : _nextVenue == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "No next venue available.",
                                  style:
                                      FlutterFlowTheme.of(context).bodyMedium,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CreateSchedule()));
                                  },
                                  child: Text("Create a schedule", style: FlutterFlowTheme.of(context).bodyLarge,),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all<
                                            Color>(
                                        FlutterFlowTheme.of(context).primary),
                                    foregroundColor:
                                        WidgetStateProperty.all<Color>(
                                            FlutterFlowTheme.of(context)
                                                .primaryBackground),
                                    shape: WidgetStateProperty.all<
                                        RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    setState(() {
                                      _loadingNextVenue = true;
                                    });
                                    final venueDetails =
                                        await ApiCalls.getVenueDetails(
                                            _nextVenue!['place_id']);
                                    setState(() {
                                      _loadingNextVenue = false;
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VenueDetails(
                                          venueDetails: venueDetails,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.pin_drop_outlined,
                                        color: FlutterFlowTheme.of(context)
                                            .primary,
                                      ),
                                      Text(
                                          _nextVenue!['name'] ??
                                              'Unknown Place',
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge
                                              .override(
                                                fontFamily: 'Poppins',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              )),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Up next! ${_remainingTime} away',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.7,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.07,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          _nextVenue!['visit_start_time'] ==
                                                  null
                                              ? _handleCheckIn(context)
                                              : _handleCheckOut(context);
                                        },
                                        style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStatePropertyAll(
                                                    FlutterFlowTheme.of(context)
                                                        .primary),
                                            elevation:
                                                const WidgetStatePropertyAll(
                                                    2.0),
                                            shape: WidgetStatePropertyAll(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10.0))),
                                            side:
                                                WidgetStatePropertyAll(BorderSide(
                                                    width: 3.0,
                                                    color: FlutterFlowTheme.of(
                                                            context)
                                                        .alternate))),
                                        child: Text(
                                          _nextVenue!['visit_start_time'] ==
                                                  null
                                              ? 'Check In'
                                              : 'Check Out',
                                          style: FlutterFlowTheme.of(context)
                                              .titleMedium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                ),
                _nextVenue != null && _nextVenue!['visit_start_time'] != null
                    ? Text(
                        "Check in time: ${_formatDate(_nextVenue!['visit_start_time'])}",
                        style: FlutterFlowTheme.of(context).titleLarge.override(
                              fontFamily: 'Poppins',
                              color: FlutterFlowTheme.of(context).secondary,
                            ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          )
        ]),
      ),
    );
  }
}
