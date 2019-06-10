import 'package:flutter/material.dart';
import 'package:youtube_mp3/YoutubeMP3.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SLAYER Leecher',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.red[400]
      ),
      debugShowCheckedModeBanner: false,
      home: YoutubeMP3(),
    );
  }
}

