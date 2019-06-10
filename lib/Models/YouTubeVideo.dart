class Result {
  String id;
  String vid;
  String ajax;
  String ftype;
  String fquality;
  String audioName;
  String thumbnail;
  String duration;

  Result(
      {this.id,
      this.vid,
      this.ajax,
      this.ftype,
      this.fquality,
      this.audioName,
      this.thumbnail,
      this.duration});

  Result.convertResult(String inpute) {
    id = RegExp(r"\\n_id: '(.*?)',").firstMatch(inpute).group(1);
    vid = RegExp(r"v_id: '(.*?)',").firstMatch(inpute).group(1);
    audioName = RegExp(r"data_vtitle = \\" "(.*?)\\" ";").firstMatch(inpute).group(1).replaceAll(RegExp('"\\"|"'), "");
    thumbnail = RegExp(r'<img src=\\"(.*?)\\"').firstMatch(inpute).group(1).replaceAll("\\", "");
    duration = RegExp(r'>Duration:.(.*?)<').firstMatch(inpute).group(1);
    fquality = "128";
    ajax = "1";
    ftype = ".mp3";
  }
}
