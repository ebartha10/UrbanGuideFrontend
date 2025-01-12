import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project2/misc/flutter_flow_theme.dart';

class ChooseCategory extends StatefulWidget {
  const ChooseCategory({super.key});

  @override
  State<ChooseCategory> createState() => _ChooseCategoryState();
}

class _ChooseCategoryState extends State<ChooseCategory> {
  Map<String, dynamic> categoriesData = {};
  Map<String, bool> selectedItems = {};
// Load JSON from local asset
  Future<void> loadCategories() async {
    final String response =
        await rootBundle.loadString('assets/json/venue_categories.json');
    final data = await json.decode(response);
    setState(() {
      categoriesData = data;
      // Initialize checkbox states for all subcategories
      for (var section in ['daytime', 'nighttime']) {
        for (var category in data[section]['categories']) {
          selectedItems[category['title']] = false;
          for (var subcategory in category['subcategories']) {
            selectedItems[subcategory] = false;
          }
        }
      }
    });
  }

  // Widget to render title and rows for categories
  Widget buildCategorySection(String title, List categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: FlutterFlowTheme.of(context).titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...categories.map((category) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title for the main category
              Container(
                decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary,
                    borderRadius: BorderRadius.circular(10.0)),
                padding: const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: Text(
                        category['title'],
                        style: FlutterFlowTheme.of(context).bodyLarge,
                      ),
                    ),
                    Transform.scale(
                      scale: 1.5,
                      child: Checkbox(
                        checkColor: FlutterFlowTheme.of(context).primaryText,
                        activeColor:
                            FlutterFlowTheme.of(context).primaryBackground,
                        value: selectedItems[category['title']] ?? false,
                        onChanged: (value) {
                          setState(() {
                            selectedItems[category['title']] = value ?? false;
                            for (var subcategory in category['subcategories']) {
                              selectedItems[subcategory] = value ?? false;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              // Subcategories as rows with checkboxes
              ...category['subcategories'].map<Widget>((subcategory) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 0.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: FlutterFlowTheme.of(context).alternate,
                    border: Border.all(
                        width: 3.0,
                        color:
                            FlutterFlowTheme.of(context).secondaryBackground),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Text(
                            subcategory,
                            style: FlutterFlowTheme.of(context).bodyMedium,
                          ),
                        ),
                        Checkbox(
                          checkColor: FlutterFlowTheme.of(context).primaryText,
                          activeColor: FlutterFlowTheme.of(context).primary,
                          value: selectedItems[subcategory] ?? false,
                          onChanged: (value) {
                            setState(() {
                              selectedItems[subcategory] = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 10),
            ],
          );
        }),
      ],
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        title: Text('Chooose Venue Categories',
            style: FlutterFlowTheme.of(context).titleLarge.override(
                fontFamily: 'Poppins',
                color: FlutterFlowTheme.of(context).primary)),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.92,
        margin: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  buildCategorySection(
                    categoriesData['daytime']['title'],
                    categoriesData['daytime']['categories'],
                  ),
                  const SizedBox(height: 20),
                  // Render nighttime section
                  buildCategorySection(
                    categoriesData['nighttime']['title'],
                    categoriesData['nighttime']['categories'],
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.07,
                child: OutlinedButton(
                  onPressed: () {
                    final selectedVenues = selectedItems.entries
                        .where((entry) => entry.value)
                        .map((entry) => entry.key)
                        .toList();
                    Navigator.pop(context, selectedVenues);
                  },
                  style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                          FlutterFlowTheme.of(context).primary),
                      elevation: const WidgetStatePropertyAll(2.0),
                      
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                      side: WidgetStatePropertyAll(BorderSide(width: 3.0, color: FlutterFlowTheme.of(context).alternate))),
                  child: Text(
                    'Finish',
                    style: FlutterFlowTheme.of(context).titleMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
