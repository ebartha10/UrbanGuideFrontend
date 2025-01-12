import 'dart:ffi';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project2/backend/django_auth.dart';
import 'package:project2/home_page.dart';
import 'package:project2/misc/utils.dart';
import 'package:project2/onboarding.dart';
import 'package:project2/sign_in.dart';
import 'package:project2/misc/flutter_flow_theme.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await FlutterFlowTheme.initialize();
  final backend = DjangoBackend();

  bool loggedIn = await backend.isLoggedIn();

  if (loggedIn) {
    print('User is logged in');
    await backend.refreshToken();
    // Navigate to the main app screen
  }
  runApp(MyApp());
  print(dotenv.env['GOOGLE_MAPS_API_KEY']);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;
  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });
  // This widget is the root of your application.
  final backend = DjangoBackend();
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLoginStatus(); 
  }

  Future<void> checkLoginStatus() async {
    final isLoggedIn = await backend.isLoggedIn();
    setState(() {
      loggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    FlutterFlowTheme.saveThemeMode(ThemeMode.system);
    _themeMode = ThemeMode.system;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.light,
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: WidgetStateProperty.all(false),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scrollbarTheme: ScrollbarThemeData(
          thumbVisibility: WidgetStateProperty.all(false),
        ),
      ),
      themeMode: _themeMode,
      home: loggedIn == true ? const HomePage() : const Onboarding(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _emailAddressTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    if (!RegExp(kTextValidatorEmailRegex).hasMatch(val)) {
      return 'Invalid email address';
    }
    return null;
  }

  String? _passwordTextControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return 'Field is required';
    }

    return null;
  }

  final _passwordTextController = TextEditingController();
  final _usernameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  bool _passwordVisibility = true;
  bool _passwordConfirmVisibility = true;
  final backend = DjangoBackend();
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          title: Text(widget.title,
              style: FlutterFlowTheme.of(context).titleLarge.override(
                  fontFamily: 'Poppins',
                  color: FlutterFlowTheme.of(context).primary)),
        ),
        body: Container(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: MediaQuery.sizeOf(context).height * 1.0,
          color: FlutterFlowTheme.of(context).secondaryBackground,
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Hello, do have a great journey.',
                    style: FlutterFlowTheme.of(context).titleLarge,
                  ),
                  Container(
                    margin: const EdgeInsets.all(12.0),
                    width: double.infinity,
                    child: TextFormField(
                      obscureText: false,
                      decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: FlutterFlowTheme.of(context).labelLarge,
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).primaryBackground,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).alternate,
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
                      keyboardType: TextInputType.name,
                      validator: (val) =>
                          _passwordTextControllerValidator(context, val),
                    ),
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
                                  color: FlutterFlowTheme.of(context).alternate,
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
                      keyboardType: TextInputType.text,
                      validator: (val) =>
                          _passwordTextControllerValidator(context, val),
                      controller: _usernameTextController,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(12.0),
                    width: double.infinity,
                    child: TextFormField(
                      obscureText: false,
                      decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: FlutterFlowTheme.of(context).labelLarge,
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).primaryBackground,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).alternate,
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
                      validator: (value) =>
                          _emailAddressTextControllerValidator(context, value),
                      controller: _emailTextController,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(12.0),
                    width: double.infinity,
                    child: TextFormField(
                      obscureText: _passwordVisibility,
                      decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: FlutterFlowTheme.of(context).labelLarge,
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).primaryBackground,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).alternate,
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
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 24.0,
                            ),
                          )),
                      style: FlutterFlowTheme.of(context).bodyLarge,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) =>
                          _passwordTextControllerValidator(context, value),
                      controller: _passwordTextController,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(12.0),
                    width: double.infinity,
                    child: TextFormField(
                      obscureText: _passwordConfirmVisibility,
                      decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: FlutterFlowTheme.of(context).labelLarge,
                          filled: true,
                          fillColor:
                              FlutterFlowTheme.of(context).primaryBackground,
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).alternate,
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
                                _passwordConfirmVisibility =
                                    !_passwordConfirmVisibility;
                              });
                            },
                            child: Icon(
                              _passwordConfirmVisibility
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: FlutterFlowTheme.of(context).secondaryText,
                              size: 24.0,
                            ),
                          )),
                      style: FlutterFlowTheme.of(context).bodyLarge,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) =>
                          _passwordTextControllerValidator(context, value),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (await backend.register(
                          _usernameTextController.text,
                          _passwordTextController.text,
                          _emailTextController.text,
                        )) {
                          
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Failed to create account')));
                        }
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            FlutterFlowTheme.of(context).primary),
                        elevation: const WidgetStatePropertyAll(2.0)),
                    child: Text(
                      'Create Account',
                      style: FlutterFlowTheme.of(context).bodyLarge,
                      
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: 'Already a member? ',
                      style: FlutterFlowTheme.of(context).bodyLarge,
                      children: [
                        TextSpan(
                            text: 'Sign in!',
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                    fontFamily: 'Poppins',
                                    color: FlutterFlowTheme.of(context).primary,
                                    fontWeight: FontWeight.bold),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const SignIn()));
                              }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
