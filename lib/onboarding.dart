import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:project2/main.dart';
import 'package:project2/misc/flutter_flow_theme.dart';
import 'package:project2/sign_in.dart';

class Onboarding extends StatelessWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        height: MediaQuery.sizeOf(context).height * 1.0,
        color: FlutterFlowTheme.of(context).primary,
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Image.asset(
                'assets/images/onboarding.png',
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 100,
                        height: 100,
                      ),
                      Text(
                        'Urban Guide',
                        style: FlutterFlowTheme.of(context).displaySmall,
                      ),
                      Text(
                        'Your Pocket Tourism Guide',
                        style: FlutterFlowTheme.of(context).titleLarge,
                      )
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SignIn()));
                          },
                          style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  FlutterFlowTheme.of(context).primary),
                              elevation: const WidgetStatePropertyAll(2.0),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                              side: const WidgetStatePropertyAll(BorderSide.none)),
                          child: Text(
                            'Sign In',
                            style: FlutterFlowTheme.of(context).titleMedium,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MyHomePage(
                                          title: 'Register - Urban Guide',
                                        )));
                          },
                          style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(
                                  FlutterFlowTheme.of(context)
                                      .secondaryBackground),
                              elevation: const WidgetStatePropertyAll(2.0),
                              shape: WidgetStatePropertyAll(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                              side: const WidgetStatePropertyAll(BorderSide.none)),
                          child: Text(
                            'Sign Up',
                            style: FlutterFlowTheme.of(context).titleMedium,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
