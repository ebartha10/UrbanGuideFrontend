import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String photo;

  const FullScreenImage({Key? key, required this.photo}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context); // Close full screen on tap
        },
        child: Center(
          child: Image.network(
            photo,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}