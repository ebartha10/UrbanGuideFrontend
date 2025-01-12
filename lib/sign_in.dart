import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:project2/backend/django_auth.dart';
import 'package:project2/create_schedule.dart';
import 'package:project2/home_page.dart';
import 'package:project2/main.dart';
import 'package:project2/misc/flutter_flow_theme.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  var _passwordVisibility = false;
  final DjangoBackend _backend = DjangoBackend();
  final _usernameTextController = TextEditingController();
  final _passwordTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          title: Text('Sign In - UrbanGuide',
              style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Poppins',
                  color: FlutterFlowTheme.of(context).primary)),
        ),
        body: Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: MediaQuery.sizeOf(context).height * 1.0,
          decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).primary),
          child: Form(
            child: SingleChildScrollView(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome Back,\nPlease enter your details.',
                      style: FlutterFlowTheme.of(context).titleLarge,
                    ),
                    Container(
                      margin: const EdgeInsets.all(12.0),
                      width: double.infinity,
                      child: TextFormField(
                        obscureText: false,
                        decoration: InputDecoration(
                            labelText: 'Username',
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
                        keyboardType: TextInputType.emailAddress,
                        controller: _usernameTextController,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(12.0),
                      width: double.infinity,
                      child: TextFormField(
                        obscureText: !_passwordVisibility,
                        decoration: InputDecoration(
                            labelText: 'Password',
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
                                borderRadius: BorderRadius.circular(10.0)),
                            suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  _passwordVisibility = !_passwordVisibility;
                                });
                              },
                              child: Icon(
                                _passwordVisibility
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color:
                                    FlutterFlowTheme.of(context).secondaryText,
                                size: 24.0,
                              ),
                            )),
                        style: FlutterFlowTheme.of(context).bodyLarge,
                        keyboardType: TextInputType.visiblePassword,
                        controller: _passwordTextController,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_usernameTextController.text.isNotEmpty ||
                            _passwordTextController.text.isNotEmpty) {
                          _backend
                              .login(_usernameTextController.text,
                                  _passwordTextController.text)
                              .then((value) {
                            if (value) {
                              Navigator.pushReplacement(

                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomePage()));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Invalid username or password')));
                            }
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Please fill in all fields')));
                        }
                      },
                      style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                              FlutterFlowTheme.of(context).secondary),
                          elevation: const WidgetStatePropertyAll(2.0)),
                      child: Text(
                        'Sign In',
                        style: FlutterFlowTheme.of(context).bodyLarge,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Don\'t have an account? ',
                        style: FlutterFlowTheme.of(context).bodyLarge,
                        children: [
                          TextSpan(
                              text: 'Register Here!',
                              style: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .override(
                                      fontFamily: 'Poppins',
                                      color:
                                          FlutterFlowTheme.of(context).secondary,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                    Shadow(
                                      offset: const Offset(3.0,
                                          3.0), // Horizontal and vertical offset
                                      blurRadius:
                                          6.0, // How blurry the shadow should be
                                      color: FlutterFlowTheme.of(context)
                                          .primaryBackground
                                          .withOpacity(0.5), // Shadow color
                                    ),
                                  ]),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const MyHomePage(
                                                title: 'Register - Urban Guide',
                                              )));
                                }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
