import 'package:flutter/material.dart';
import 'package:project2/backend/api_calls.dart';
import 'package:project2/create_schedule.dart';
import 'package:project2/home_page.dart';
import 'package:project2/misc/flutter_flow_theme.dart';
import 'package:project2/misc/utils.dart';
import 'package:project2/profile.dart';
import 'package:project2/trip_details.dart';

class TripHistory extends StatefulWidget {
  const TripHistory({super.key});

  @override
  State<TripHistory> createState() => _TripHistoryState();
}

class _TripHistoryState extends State<TripHistory> {
  bool _loading = false;
  String _formatDate(String givenDate) {
    // Parse the string into a DateTime object
    DateTime parsedDate = DateTime.parse(givenDate);

    // Format the DateTime into a readable string
    String formattedDate = DateFormat('yyyy/MM/dd HH:mm:ss').format(parsedDate);
    return formattedDate;
  }

  List<Map<String, dynamic>> _trips = [];
  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const HomePage(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
    else if (index == 1) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const CreateSchedule(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
    else if (index == 3) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation1, animation2) => const Profile(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
        ),
      );
    }
  }

  void fetchTrips() async {
    setState(() {
      _loading = true;
    });
    // Perform the API call
    try {
      final trips = await ApiCalls.getScheduleHistory();
      setState(() {
        _trips = trips;
        _loading = false;
      });
      _trips.sort((a, b) => (b['is_active'] ? 1 : 0).compareTo(a['is_active'] ? 1 : 0));
    } catch (e) {
      setState(() {
        _loading = false;
      });
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching trips: $e')),
      );
    }
  }

  void initState() {
    super.initState();
    fetchTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          title: Text('Trip History',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Poppins',
                  color: FlutterFlowTheme.of(context).primary)),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
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
        body: Container(
          height: MediaQuery.of(context).size.height * 0.92,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _trips.isEmpty
                          ? const Text('No trips found')
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _trips.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TripDetails(
                                          places: (_trips[index]['schedule']
                                                      as List<dynamic>?)
                                                  ?.map((e) =>
                                                      e as Map<String, dynamic>)
                                                  .toList() ??
                                              [], showContinueButton: false,
                                          title: _trips[index]['title'] ?? '',
                                  
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    padding: const EdgeInsets.all(10),
                                    height: MediaQuery.of(context).size.height *
                                        0.15,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color: _trips[index]['is_active']
                                            ? FlutterFlowTheme.of(context)
                                                .secondary
                                            : FlutterFlowTheme.of(context)
                                                .alternate,
                                        width: 3,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _trips[index]['title'] ??
                                              'Unknown Trip',
                                          style: FlutterFlowTheme.of(context)
                                              .titleLarge
                                              .override(
                                                fontFamily: 'Poppins',
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .primary,
                                              ),
                                        ),
                                        
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                _formatDate(_trips[index]
                                                        ['created_at']) ??
                                                    "Unknown time",
                                                style:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium)
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
          ),
        ));
  }
}
