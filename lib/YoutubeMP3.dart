import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_mp3/Models/YouTubeVideo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:toast/toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class YoutubeMP3 extends StatefulWidget {
  @override
  _YoutubeMP3State createState() => _YoutubeMP3State();
}

class _YoutubeMP3State extends State<YoutubeMP3> {
  TextEditingController videoURL = new TextEditingController();
  Result video;
  bool isFetching = false;
  bool fetchSuccess = false;
  bool isDownloading = false;
  bool downloadsuccess = false;
  String status = "Download ";
  String progress = "";

  Map<String, String> headers = {
    "X-Requested-With": "XMLHttpRequest",
  };

  Map<String, String> body;

  void insertBody(String videoURL) {
    body = {"url": videoURL, "ajax": "1"};
  }

  //----------------------------------Get Video Info

  Future<void> getInfo() async {
    insertBody(videoURL.text);
    setState(() {
      progress = "";
      status = "Download";
      downloadsuccess = false;
      isDownloading = false;
      isFetching = true;
      fetchSuccess = false;
    });
    try {
      var response = await http.post("https://y2mate.com/fr/analyze/ajax",
          body: body, headers: headers);

      video = Result.convertResult(response.body);
      setState(() {
        isFetching = false;
        fetchSuccess = true;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        isFetching = true;
        fetchSuccess = false;
      });
    }
    print("${video.thumbnail}\n${video.audioName}\n${video.vid}\n${video.id}");
  }

  //----------------------------------Get Download Link

  Future<void> directURI(
      String _id, String vid, String ajax, String ftype, String quality) async {
    setState(() {
      isDownloading = true;
      status = "Downloading ...";
    });
    try {
      var bodies = {
        "type": "youtube",
        "_id": _id,
        "v_id": vid,
        "ajax": ajax,
        "ftype": ftype.replaceAll(".", ""),
        "fquality": quality,
      };
      var response =
          await http.post("https://y2mate.com/fr/convert", body: bodies);
      print(response.body);
      if (response.body.contains("Error:")) {
        Toast.show(
          "Cant Download Now \n Please Try Later ...",
          context,
          duration: 4,
          textColor: Colors.white,
          gravity: Toast.BOTTOM,
        );
        setState(() {
          isDownloading = false;
        });
        return;
      }
      var directURL = RegExp(r'<a href=\\"(.*?)\\"')
          .firstMatch(response.body)
          .group(1)
          .replaceAll("\\", "");
      print("FIle Link :" + directURL);
      downloadVideo(directURL, video.audioName, video.ftype);
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      Toast.show(
        e.toString(),
        context,
        duration: 2,
        backgroundColor: Colors.red[300],
        textColor: Colors.black,
        gravity: Toast.BOTTOM,
      );
    }
  }

//----------------------------------Download Video
  Future<void> downloadVideo(
      String trackURL, String trackName, String format) async {
    try {
      Dio dio = Dio();

      var directory = await getApplicationDocumentsDirectory();
      print("${directory.path}/" + trackName + format);
      await dio.download(trackURL, "${directory.path}/" + trackName + format,
          onReceiveProgress: (rec, total) {
        setState(() {
          progress = ((rec / total) * 100).toStringAsFixed(0) + "%";
        });
      });

      setState(() {
        isDownloading = false;
        status = "Download Done ^_^";
        downloadsuccess = true;
      });
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      Toast.show(
        e.toString(),
        context,
        duration: 2,
        backgroundColor: Colors.red[300],
        textColor: Colors.black,
        gravity: Toast.BOTTOM,
      );
    }
  }

  void nothingHere() {
    print("Just Nothing");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: searchBar(),
        backgroundColor: Color.fromARGB(255, 30, 30, 30),
        centerTitle: true,
      ),
      body: bodyPart(),
    );
  }

  Widget bodyPart() {
    return Container(
      color: Color.fromARGB(255, 30, 30, 30),
      child: Center(
        child: isFetching
            ? progressScreen()
            : fetchSuccess
                ? downloadScreen()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Youtube MP3 Downloader",
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Text(
                        "By Go-Bizz",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Icon(
                        FontAwesomeIcons.youtube,
                        color: Colors.redAccent,
                        size: 45.0,
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget progressScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CircularProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(9.0),
          child: Text(
            'Getting Data ...',
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        )
      ],
    );
  }

  Widget downloadScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          height: 300.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(19.0),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Image(
                  image: NetworkImage(video.thumbnail),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              labelTitle("Title : ", video.audioName),
              SizedBox(
                height: 8.0,
              ),
              labelTitle("Duration : ", video.duration),
              SizedBox(
                height: 8.0,
              ),
              FlatButton(
                onPressed: () {
                  !downloadsuccess
                      ? directURI(video.id, video.vid, video.ajax, video.ftype,
                          video.fquality)
                      : nothingHere();
                },
                child: Container(
                  height: 40.0,
                  width: 200.0,
                  decoration: BoxDecoration(
                    color: downloadsuccess == true
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        50.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        status,
                        style: TextStyle(color: Colors.black, fontSize: 16.0),
                      ),
                      SizedBox(
                        width: 12.0,
                      ),
                      Icon(
                        isDownloading
                            ? FontAwesomeIcons.spinner
                            : downloadsuccess
                                ? FontAwesomeIcons.check
                                : FontAwesomeIcons.download,
                        color: Colors.black,
                        size: 20.0,
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  progress,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget labelTitle(String title, String inpute) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Text(
            title,
            style: TextStyle(
                color: Colors.redAccent,
                fontSize: 17.0,
                fontWeight: FontWeight.bold),
          ),
        ),
        Flexible(
          child: Text(
            inpute,
            style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
                fontWeight: FontWeight.normal),
          ),
        ),
      ],
    );
  }

  Widget searchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.0),
      margin: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: Color.fromARGB(100, 255, 255, 255),
        borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        ),
      ),
      child: Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            child: TextFormField(
              controller: videoURL,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Video URL ...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
                icon: IconButton(
                  onPressed: () {
                    getInfo();
                  },
                  icon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
