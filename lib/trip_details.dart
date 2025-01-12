import 'package:flutter/material.dart';
import 'package:project2/backend/api_calls.dart';
import 'package:project2/home_page.dart';
import 'package:project2/misc/flutter_flow_theme.dart';
import 'package:project2/venue_details.dart';

class TripDetails extends StatefulWidget {
  const TripDetails(
      {super.key, required this.places, required this.showContinueButton, required this.title});
  final List<Map<String, dynamic>> places;
  final bool showContinueButton;
  final String title;
  @override
  State<TripDetails> createState() => _TripDetailsState();
}

class _TripDetailsState extends State<TripDetails> {
  Future<void> _handleContinueButton(BuildContext context) async {
    // Show a loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Perform the API call
      final places = await ApiCalls.createSchedule(
        widget.places,
        widget.title,
      );

      // Dismiss the loading indicator
      Navigator.pop(context);

      // Navigate to TripDetails with the API response
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          title: Text('Trip Details',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Poppins',
                  color: FlutterFlowTheme.of(context).primary)),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height * 0.92,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: widget.places.map((item) {
                    if (item['type'] == 'venue') {
                      // Render a venue
                      return GestureDetector(
                        onTap: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                                child: CircularProgressIndicator()),
                          );

                          try {
                            // Perform the API call
                            final venuedetails = await ApiCalls.getVenueDetails(
                              item['place_id'],
                            );

                            // Dismiss the loading indicator
                            Navigator.pop(context);

                            // Navigate to VenueDetails with the API response
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VenueDetails(venueDetails: venuedetails,),
                              ),
                            );
                          } catch (e) {
                            // Dismiss the loading indicator
                            Navigator.pop(context);

                            // Show an error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Error fetching places: $e')),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: item['visit_start_time'] != null
                                  ? Colors.green
                                  : FlutterFlowTheme.of(context).alternate,
                              width: 3,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.pin_drop_outlined,
                                    color: FlutterFlowTheme.of(context).primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    child: Text(
                                      item['name'] ?? 'Unknown Place',
                                      style: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .override(
                                            fontFamily: 'Poppins',
                                            color: FlutterFlowTheme.of(context)
                                                .primary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "${item['start_time']} - ${item['end_time']}" ??
                                        "Unknown time",
                                    style:
                                        FlutterFlowTheme.of(context).bodyMedium,
                                  ),
                                ],
                              ),
                              Text(
                                item['vicinity'] ?? 'Unknown Location',
                                style: FlutterFlowTheme.of(context).bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (item['type'] == 'travel') {
                      // Render a travel step
                      return Container(
                        margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                        padding: const EdgeInsets.all(10),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: FlutterFlowTheme.of(context).alternate,
                            width: 3,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons
                                      .directions_walk_rounded, // Change icon based on mode
                                  color: FlutterFlowTheme.of(context).primary,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: MediaQuery.of(context).size.width * 0.7,
                                  child: Text(
                                    "${item['travel_mode']} to ${item['to']}",
                                    style: FlutterFlowTheme.of(context).bodyLarge,
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            Text(
                              "${item['travel_time']}",
                              style: FlutterFlowTheme.of(context).bodyLarge,
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Fallback for unknown item types
                      return const SizedBox.shrink();
                    }
                  }).toList(),
                ),
                widget.showContinueButton == true
                    ? SizedBox(
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
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                              side: const WidgetStatePropertyAll(
                                  BorderSide.none)),
                          child: Text(
                            'Continue',
                            style: FlutterFlowTheme.of(context).titleMedium,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ));
  }
}
