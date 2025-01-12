import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:project2/fullscreenImage.dart';
import 'package:project2/misc/flutter_flow_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class VenueDetails extends StatefulWidget {
  const VenueDetails({super.key, required this.venueDetails});
  final Map<String, dynamic> venueDetails;
  @override
  State<VenueDetails> createState() => _VenueDetailsState();
}

class _VenueDetailsState extends State<VenueDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          title: Text(widget.venueDetails['name'],
              style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Poppins',
                  color: FlutterFlowTheme.of(context).primary)),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height * 0.92,
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: CarouselView(
                    onTap: (value) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  FullScreenImage(photo: widget.venueDetails['photos'][value])));
                    },
                    scrollDirection: Axis.horizontal,
                    itemExtent: 300.0,
                    children: (widget.venueDetails['photos'] as List<dynamic>)
                        .map((photo) => Image.network(
                              photo,
                              height: MediaQuery.of(context).size.height * 0.2,
                              width: 100.0,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            (loadingProgress
                                                    .expectedTotalBytes ??
                                                1)
                                        : null,
                                  ),
                                );
                              },
                            ))
                        .toList(),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate,
                      width: 3,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.venueDetails['formatted_address'] ??
                            'No address',
                        style: FlutterFlowTheme.of(context).bodyLarge,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Rating: ${widget.venueDetails['rating']}',
                              style: FlutterFlowTheme.of(context).bodyMedium),
                          const Icon(Icons.star, color: Colors.amber),
                        ],
                      ),
                      Text('Description:',
                          style: FlutterFlowTheme.of(context).titleLarge),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Text(
                            widget.venueDetails['description'] ??
                                'No description',
                            style: FlutterFlowTheme.of(context).bodyMedium),
                      ),
                      Divider(
                        height: 10,
                        thickness: 2,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                      Text('Phone: ${widget.venueDetails['phone'] ?? 'N/A'}',
                          style: FlutterFlowTheme.of(context).bodyMedium),
                      Divider(
                        height: 10,
                        thickness: 2,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                      Text(
                          'Website: ${widget.venueDetails['website'] ?? 'N/A'}',
                          style: FlutterFlowTheme.of(context).bodyMedium),
                      Divider(
                        height: 10,
                        thickness: 2,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                      Text(
                          'Price: ${widget.venueDetails['price_level'] ?? 'N/A'}',
                          style: FlutterFlowTheme.of(context).bodyMedium),
                      Divider(
                        height: 10,
                        thickness: 2,
                        color: FlutterFlowTheme.of(context).alternate,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Google Maps URL: ',
                              style: FlutterFlowTheme.of(context).bodyLarge),
                          TextButton(
                            onPressed: () {
                              // Open the URL in the browser
                              launchUrl(Uri.parse(
                                  widget.venueDetails['google_maps_url']));
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  WidgetStateProperty.all(Colors.blue),
                              padding:
                                  WidgetStateProperty.all(EdgeInsets.all(10)),
                              shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                            ),
                            child: Text('Tap to Open',
                                style: FlutterFlowTheme.of(context).bodyMedium),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: CarouselView(
                    scrollDirection: Axis.horizontal,
                    itemExtent: 300.0,
                    children: (widget.venueDetails['reviews'] as List<dynamic>)
                        .cast<Map<String, dynamic>>()
                        .map((photo) => Container(
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context)
                                    .secondaryBackground,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 3,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(photo['author_name'] ?? 'No author',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium),
                                      Row(
                                        children: [
                                          Text(photo['rating'].toString(),
                                              style:
                                                  FlutterFlowTheme.of(context)
                                                      .bodyMedium),
                                          const Icon(Icons.star,
                                              color: Colors.amber),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    height: 10,
                                    thickness: 2,
                                    color:
                                        FlutterFlowTheme.of(context).alternate,
                                  ),
                                  Container(
                                    child: Text(
                                      photo['text'] ?? 'No review',
                                      style: FlutterFlowTheme.of(context)
                                          .bodyMedium,
                                      textAlign: TextAlign.center,
                                      maxLines: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
