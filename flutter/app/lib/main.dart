import 'package:flutter/material.dart';

void main() {
  runApp(new MaterialApp(
    home: new MyStatelessWidget()
  ));
}

class MyStatelessWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("Ringsalot"),

            backgroundColor: Colors.yellow),
      backgroundColor: Colors.green,

      body: new Container(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Cards(
              title: new Text("Ringtones",
                style: new TextStyle(fontFamily: 'Times New Roman',
                    fontSize: 25.0),),
              icon: new Icon(Icons.music_note, size: 55.0, color: Colors.deepOrangeAccent,)
            ),
            new Cards(
              title: new Text("Notifications",
                style: new TextStyle(fontFamily: 'Times New Roman',
                  fontSize: 25.0),),
              icon: new Icon(Icons.message, size: 50.0, color: Colors.deepPurpleAccent,)
            ),

          ]
        )
      )
    );
  }
}

class Cards extends StatelessWidget {
  Cards({this.title, this.icon});

  final Widget title;
  final Widget icon;
  @override
  Widget build(BuildContext context){
    return new Container(
      padding: new EdgeInsets.symmetric(vertical: 50.0, horizontal: 50.0),
      child: new Card(
        child: new Container(
          padding: new EdgeInsets.all(30.0),
          child: new Column(
            children: <Widget>[
              this.title,
              this.icon
            ]
          )
        )
      )
    );
  }
}
