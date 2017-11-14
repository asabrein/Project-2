import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';

typedef void OnError(Exception exception);

const kUrl1 = "http://k003.kiwi6.com/hotlink/i3s3kfxbl2/Ringtone-1.mp3";
const kUrl2 = "http://k003.kiwi6.com/hotlink/mcdbu7xj6b/Ringtone-2.mp3";
const kUrl3 = "http://k003.kiwi6.com/hotlink/hxslavjg3g/Ringtone-3.mp3";
const kUrl4 = "http://k003.kiwi6.com/hotlink/ovabrtixxa/Ringtone-4.mp3";
const kUrl5 = "http://k003.kiwi6.com/hotlink/zqduji0lt1/Ringtone-5.mp3";

void main() {

  AppBar appBar = new AppBar(title: new Text("Ringsalot"));
  runApp(new MaterialApp(home: new Scaffold(appBar: appBar,
      body: new AudioList())));
}

class AudioList extends StatefulWidget {
  @override
  _AudioListState createState() => new _AudioListState();
}

class _AudioListState extends State<AudioList> {

  AudioPlayer audioPlayer;

  List<Widget> audioEntries;

  @override
  Widget build(BuildContext context) {
    return new ListView(
      shrinkWrap: true,
      children: audioEntries
    );
  }

  void stopAllAudio() {
    for (var entry in this.audioEntries) {
      //entry.stop();
    }
  }

  @override
  void initState() {
    super.initState();
    initAudioPlayer();

    audioEntries =  <Widget>[
      new AudioEntry(kUrl1, audioPlayer, stopAllAudio),
      new AudioEntry(kUrl2,audioPlayer, stopAllAudio),
      new AudioEntry(kUrl3,audioPlayer, stopAllAudio),
      new AudioEntry(kUrl4,audioPlayer, stopAllAudio),
      new AudioEntry(kUrl5,audioPlayer, stopAllAudio)
    ];
  }



  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();

    audioPlayer.setDurationHandler((d) => setState(() {
      print('_AudioAppState.setDurationHandler => d ${d}');
      duration = d;
    }));

    audioPlayer.setPositionHandler((p) => setState(() {
      print('_AudioAppState.setPositionHandler => p ${p}');
      position = p;
    }));

    audioPlayer.setCompletionHandler(() {
      onComplete();
      setState(() {
        position = duration;
      });
    });

    audioPlayer.setErrorHandler((msg) {
      print('audioPlayer error : $msg');
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

}

enum PlayerState { stopped, playing, paused }

class AudioEntry extends StatefulWidget {
    final String myKUrl;
    final AudioPlayer player;
    final Function stopAllMusic;

    AudioEntry(this.myKUrl, this.player, this.stopAllMusic);

    @override
    _AudioEntryState createState() => new _AudioEntryState(this.myKUrl, this.player, this.stopAllMusic);
  }

class _AudioEntryState extends State<AudioEntry> {
  final String myKUrl;
  final AudioPlayer player;
  final Function stopAllMusic;

  _AudioEntryState(this.myKUrl, this.player, this.stopAllMusic);

  Duration duration;
  Duration position;

  AudioPlayer audioPlayer;

  String localFilePath;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  Future play() async {
    stopAllMusic();

    //await this.player.stop();
    final result = await this.player.play(this.myKUrl);
    if (result == 1) setState(() => playerState = PlayerState.playing);

  }

  Future _playLocal() async{
    final result = await this.player.play(localFilePath, isLocal: true);
    if (result == 1) setState(() => playerState = PlayerState.playing);
  }

  Future pause() async {
    final result = await this.player.pause();
    if (result == 1) setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    final result = await this.player.stop();
    if (result == 1)
      setState(() {
        playerState = PlayerState.stopped;
        position = new Duration();
      });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  @override
  void dispose() {
    super.dispose();
    this.player.stop();
  }

  Future<Uint8List> _loadFileBytes(String url, {OnError onError}) async {
    Uint8List bytes;
    try {
      bytes = await readBytes(url);
    } on ClientException {
      rethrow;
    }
    return bytes;
  }

  Future _loadFile() async {
    var filename = this.myKUrl.split("/").removeLast();

    final bytes = await _loadFileBytes(this.myKUrl,
        onError: (Exception exception) =>
            print('_MyHomePageState._loadVideo => exception ${exception}'));

    final dir = await getApplicationDocumentsDirectory();
    final file = new File('/storage/emulated/0/Download/${filename}');

    await file.writeAsBytes(bytes);
    if (await file.exists())
      setState(() {
        localFilePath = file.path;
      });

    print("file downloaded");
  }

  @override
  Widget build(BuildContext context) {
    var filename = this.myKUrl.split("/").removeLast();
    filename = filename.substring(0, filename.length > 20 ? 20 : filename.length);
    return new Center(
        child: new Material(
            elevation: 2.0,
            color: Colors.grey[200],
            child: new Column(children: [
              new Material(
                  child: new Container(
                      padding: new EdgeInsets.all(16.0),
                      child:
                        new Column(mainAxisSize: MainAxisSize.min, children: [

                          new Row(mainAxisSize: MainAxisSize.min, children: [
                            new Text("${filename ?? ''}",
                                style: new TextStyle(fontSize: 24.0)),
                            new IconButton(
                                onPressed: () => _loadFile(),
                                iconSize: 40.0,
                                icon: new Icon(Icons.file_download),
                                color: Colors.cyan),
                            new IconButton(
                                onPressed: () => share(this.myKUrl),
                                iconSize: 40.0,
                                icon: new Icon(Icons.share),
                                color: Colors.cyan),
                          ]),

                          new Row(mainAxisSize: MainAxisSize.min, children: [
                            new IconButton(
                                onPressed: isPlaying ? null : () => play(),
                                iconSize: 64.0,
                                icon: new Icon(Icons.play_arrow),
                                color: Colors.cyan),
                            new IconButton(
                                onPressed: isPlaying ? () => pause() : null,
                                iconSize: 64.0,
                                icon: new Icon(Icons.pause),
                                color: Colors.cyan),
                            new IconButton(
                                onPressed:
                                    isPlaying || isPaused ? () => stop() : null,
                                iconSize: 64.0,
                                icon: new Icon(Icons.stop),
                                color: Colors.cyan),
                            new Padding(
                                padding: new EdgeInsets.all(12.0),
                                child: new Stack(children: [
                                  new CircularProgressIndicator(
                                      value: 1.0,
                                      valueColor: new AlwaysStoppedAnimation(
                                          Colors.grey[300])),
                                  new CircularProgressIndicator(
                                    value: position != null &&
                                        position.inMilliseconds > 0
                                        ? position.inMilliseconds /
                                        duration.inMilliseconds
                                        : 0.0,
                                    valueColor:
                                    new AlwaysStoppedAnimation(Colors.cyan),
                                  ),
                                ])),
                        ])
                      ]))),
              localFilePath != null ? new Text(localFilePath) : new Container(),
              /*new Row(children: [
                new RaisedButton(
                  onPressed: () => _loadFile(),
                  child: new Text('Download'),
                ),
                new RaisedButton(
                  onPressed: () => _playLocal(),
                  child: new Text('play local'),
                ),
              ])*/
            ])));
  }
}

